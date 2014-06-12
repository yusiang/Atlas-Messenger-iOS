//
//  LYRReconciliationOperation.m
//  LayerKit
//
//  Created by Klemen Verdnik on 08/05/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRReconciliationOperation.h"
#import "LYRSynchronizationDataSource.h"
#import "LYRSyncableChange.h"
#import "LYRSynchronizationErrors.h"
#import "LYRCreateStreamOperation.h"
#import "LYRUUIDData.h"
#import "LYRConversation+Internal.h"

@interface LYRReconciliationOperation ()
@property (nonatomic, readwrite) NSUInteger changes;
@property (nonatomic, readonly) LYRSynchronizationDataSource *dataSource;
@property (nonatomic, readwrite) NSError *error;
@property (nonatomic, weak, readonly) id<LYROperationDelegate> delegate;
@end

@implementation LYRReconciliationOperation

- (id)initWithDataSource:(LYRSynchronizationDataSource *)dataSource delegate:(id<LYROperationDelegate>)delegate
{
    self = [super init];
    if (self) {
        _dataSource = dataSource;
        _changes = 0;
        _delegate = delegate;
    }
    return self;
}

- (void)main
{
    __block NSError *error;
    LYRLogDebug(@"<%@:%d> starting...", [self class], (int)self);
    [self.dataSource performTransactionWithBlock:^(FMDatabase *db, BOOL *shouldRollback) {
        BOOL success;
        // Fetch all the syncable changes
        NSSet *fetchedSyncableChanges = [self.dataSource syncableChangesInDatabase:db error:&error];
        if (!fetchedSyncableChanges) { *shouldRollback = YES; return; }

        // First we need to process all syncable changes that
        // produce new conversations./Users/chipxsd/Pictures/iPhoto Library.photolibrary/Masters/2014/05/27/20140527-143809/theboss.jpg
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tableName == %@", LYRSyncableChangeTableNameConversations];
        NSSet *syncableChangesOfNewConversations = [fetchedSyncableChanges filteredSetUsingPredicate:predicate];

        NSMutableSet *persistedStreams = [NSMutableSet set];
        for (LYRSyncableChange *syncableChange in syncableChangesOfNewConversations) {
            LYRStream *stream = [LYRStream stream];
            // Persist the newly created operation
            success = [[self dataSource] persistStreams:[NSSet setWithObject:stream] toDatabase:db error:&error];
            if (!success) return;
            // Also persist conversation's `stream_database_identifier` relationship
            NSMapTable *conversationDBIDByStreamId = [NSMapTable strongToStrongObjectsMapTable];
            [conversationDBIDByStreamId setObject:@(stream.databaseIdentifier) forKey:@(syncableChange.rowIdentifier)];
            success = [[self dataSource] persistConversationsStreamForeignKeysByIdentifiers:conversationDBIDByStreamId toDatabase:db error:&error];
            if (!success) return;
            [persistedStreams addObject:stream];
            // Delete the syncable change that was successfully reconciled
            if (success) {
                success = [[self dataSource] deleteSyncableChanges:[NSSet setWithObject:syncableChange] inDatabase:db error:&error];
                self.changes++;
                if (!success) return;
            }
        }

        // Prepare an array of syncable changes ordered by its rowID (`changeIdentifier`)
        NSMutableSet *filteredSyncableChanges = [fetchedSyncableChanges mutableCopy];
        [filteredSyncableChanges minusSet:syncableChangesOfNewConversations];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"changeIdentifier" ascending:YES];
        NSArray *sortedSyncableChanges = [filteredSyncableChanges sortedArrayUsingDescriptors:@[sortDescriptor]];

        // Loop to all fetched syncable changes and generate
        // an event for each syncable change.
        NSMutableDictionary *eventSequencesForStreamDatabaseIds = [NSMutableDictionary dictionary];
        for (LYRSyncableChange *syncableChange in sortedSyncableChanges) {
            LYREvent *event = [self eventFromSyncableChange:syncableChange database:db error:&error];
            if (!event) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"Failed to create an event for syncable change", @"syncableChange":syncableChange};
                error = [NSError errorWithDomain:LYRErrorDomain code:LYRSynchronizationErrorUnprocessableSyncableChange userInfo:userInfo];
                *shouldRollback = YES;
                return;
            }
            event.client_seq = (uint32_t)[eventSequencesForStreamDatabaseIds[@(event.streamDatabaseIdentifier)] integerValue];
            eventSequencesForStreamDatabaseIds[@(event.streamDatabaseIdentifier)] = @(event.client_seq + 1);
            success = [self.dataSource persistEvents:[NSSet setWithObject:event] toDatabase:db error:&error];
            if (!success) { *shouldRollback = YES; return; }
            success = [self applyEvent:event forSyncableChange:syncableChange toDatabase:db error:&error];
            if (!success) { *shouldRollback = YES; return; }
            success = [self.dataSource deleteSyncableChanges:[NSSet setWithObject:syncableChange] inDatabase:db error:&error];
            if (!success) { *shouldRollback = YES; return; }
            self.changes++;
        }
    }];
    self.error = error;
    if (self.error) [self.delegate operation:self shouldFailDueToError:self.error];
    LYRLogDebug(@"<%@:%d> done", [self class], (int)self);
}

- (LYREvent *)eventFromSyncableChange:(LYRSyncableChange *)syncableChange database:(FMDatabase *)db error:(out NSError *__autoreleasing *)error
{
    LYREvent *event;
    NSError *internalError;
    if ([syncableChange.tableName isEqualToString:LYRSyncableChangeTableNameConversationParticipants]) {
        event = [[self dataSource] eventFromParticipantSyncableChange:syncableChange inDatabase:db error:&internalError];
    } else if ([syncableChange.tableName isEqualToString:LYRSyncableChangeTableNameMessages]) {
        event = [[self dataSource] eventFromMessageSyncableChange:syncableChange inDatabase:db error:&internalError];
    } else {
        // Unhandled syncable change
        return nil;
    }
    if (internalError && error) *error = internalError;
    return event;
}

- (BOOL)applyEvent:(LYREvent *)event forSyncableChange:(LYRSyncableChange *)syncableChange toDatabase:(FMDatabase *)db error:(out NSError *__autoreleasing *)error
{
    BOOL success = NO;
    NSError *internalError;
    LYRStream *stream = [[self dataSource] streamForDatabaseIdentifier:event.streamDatabaseIdentifier inDatabase:db error:&internalError];
    if (!stream && (internalError && error)) { *error = internalError; return NO; }
    switch (event.type) {
        case EventType_MEMBER_ADDED: {
            [[stream member_ids] addObject:event.member_id];
            success = [[self dataSource] persistStreams:[NSSet setWithObject:stream] toDatabase:db error:&internalError];
            break;
        }
        case EventType_MEMBER_REMOVED: {
            [[stream member_ids] removeObject:event.member_id];
            success = [[self dataSource] persistStreams:[NSSet setWithObject:stream] toDatabase:db error:&internalError];
            break;
        }
        case EventType_MESSAGE: {
            success = [[self dataSource] persistMessageEventDatabaseIdentifier:event.databaseIdentifier forMessageDatabaseIdentifier:syncableChange.rowIdentifier toDatabase:db error:&internalError];
            break;
        }
        case EventType_APPLICATION:
        case EventType_METADATA_ADDED:
        case EventType_METADATA_REMOVED:
        case EventType_MESSAGE_DELIVERED:
        case EventType_MESSAGE_READ:
            success = YES;
        default:
            break;
    }
    if (internalError && error) *error = internalError;
    return success;
}

@end
