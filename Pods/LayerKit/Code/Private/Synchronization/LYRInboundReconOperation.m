//
//  LYRInboundReconOperation.m
//  LayerKit
//
//  Created by Klemen Verdnik on 12/05/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRInboundReconOperation.h"
#import "LYRUUIDData.h"
#import "LYRConversation.h"
#import "LYRConversation+Internal.h"
#import "LYRMessage.h"
#import "LYRMessage+Internal.h"
#import "LYRMessagePart.h"
#import "LYRMessagePart+Internal.h"

@interface LYRInboundReconOperation ()
@property (nonatomic, readwrite) NSUInteger changes;
@property (nonatomic, readonly) NSURL *baseURL;
@property (nonatomic, readonly) NSURLSession *URLSession;
@property (nonatomic, readonly) LYRSynchronizationDataSource *dataSource;
@property (nonatomic, readwrite) NSError *error;
@property (nonatomic, weak, readonly) id<LYROperationDelegate> delegate;
@end

@implementation LYRInboundReconOperation

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
    NSMutableDictionary *conversationsByIdentifiersToReindex = [NSMutableDictionary dictionary];
    [self.dataSource performTransactionWithBlock:^(FMDatabase *db, BOOL *shouldRollback) {
        BOOL success = NO;
        // Find all streams that don't have corresponding
        // conversation records in the database
        NSSet *unprocessedStreams = [self.dataSource unprocessedStreamsInDatabase:db error:&error];
        if (!unprocessedStreams) {
            *shouldRollback = YES;
            return;
        }

        for (LYRStream *stream in unprocessedStreams) {
            LYRConversation *conversation = [LYRConversation conversationWithIdentifier:stream.streamUUID participants:nil];
            conversation.streamDatabaseIdentifier = stream.databaseIdentifier;
            success = [self.dataSource persistConversations:[NSSet setWithObject:conversation] toDatabase:db error:&error];
            if (!success) {
                *shouldRollback = YES;
                return;
            }
        }

        // Fetch all the syncable changes
        NSSet *fetchedUnprocessedEvents = [self.dataSource unprocessedEventsInDatabase:db error:&error];
        if (!fetchedUnprocessedEvents) {
            *shouldRollback = YES;
            return;
        }

        LYRLogDebug(@"<%@:%d> will process %lu events", [self class], (int)self, (unsigned long)fetchedUnprocessedEvents.count);

        NSInteger numberOfProcessedEvents = 0;

        for (LYREvent *event in fetchedUnprocessedEvents) {
            switch (event.type) {
                case EventType_MEMBER_ADDED: {
                    LYRStream *stream = [self.dataSource streamForIdentifier:event.streamUUID inDatabase:db error:&error];
                    if (!stream) {
                        success = NO;
                        break;
                    }
                    [stream.member_ids addObject:event.member_id];
                    success = [self.dataSource persistStreams:[NSSet setWithObject:stream] toDatabase:db error:&error];
                    if (!success) break;
                    success &= [self.dataSource persistAddParticipant:event.member_id seq:event.seq date:[NSDate dateWithTimeIntervalSince1970:event.timestamp] conversationIdentifier:event.streamUUID toDatabase:db error:&error];
                    break;
                }
                case EventType_MEMBER_REMOVED: {
                    LYRStream *stream = [self.dataSource streamForIdentifier:event.streamUUID inDatabase:db error:&error];
                    if (!stream) {
                        success = NO;
                        break;
                    }
                    [stream.member_ids removeObject:event.member_id];
                    success = [self.dataSource persistStreams:[NSSet setWithObject:stream] toDatabase:db error:&error];
                    if (!success) break;
                    success = [self.dataSource persistRemoveParticipant:event.member_id seq:event.seq date:[NSDate dateWithTimeIntervalSince1970:event.timestamp] conversationIdentifier:event.streamUUID toDatabase:db error:&error];
                    break;
                }
                case EventType_MESSAGE: {
                    NSOrderedSet *conversations = [self.dataSource conversationsForIdentifiers:[NSOrderedSet orderedSetWithObject:event.streamUUID] inDatabase:db error:&error];
                    if (!conversations || !conversations.count) {
                        success = NO;
                        break;
                    }

                    NSMutableArray *messageParts = [NSMutableArray array];
                    for (NSString *MIMEType in event.content_types) {
                        NSInteger indexOfMessagePart = [event.content_types indexOfObject:MIMEType];
                        NSData *data;
                        if (event.inline_content_parts.count < indexOfMessagePart) data = [NSData data];
                        else data = [event.inline_content_parts objectAtIndex:indexOfMessagePart];
                        LYRMessagePart *messagePart = [LYRMessagePart messagePartWithMIMEType:MIMEType data:data];
                        [messageParts addObject:messagePart];
                    }

                    LYRConversation *conversation = [conversations firstObject];
                    LYRMessage *message = [LYRMessage messageWithDatabaseIdentifier:LYRSequenceNotDefined];
                    message.conversation = conversation;
                    message.parts = messageParts.copy;
                    message.seq = event.seq;
                    message.sentAt = [NSDate dateWithTimeIntervalSince1970:event.timestamp];
                    message.receivedAt = [NSDate date];
                    message.sentByUserID = event.creator_id;
                    message.metadata = event.metadata.copy;
                    message.eventDatabaseIdentifier = event.databaseIdentifier;

                    success = [self.dataSource persistMessage:message toDatabase:db error:&error];
                    
                    // Add conversation affected by the new message
                    // for later reindexing.
                    [conversationsByIdentifiersToReindex setObject:conversation forKey:conversation.identifier];
                    break;
                }
                default:
                    success = NO;
                    break;
            }
            if (success) {
                success = [self.dataSource deleteUnprocessedEvents:[NSSet setWithObject:event] inDatabase:db error:&error];
                if (!success) {
                    *shouldRollback = YES;
                    return;
                } else numberOfProcessedEvents++;
            }
        }
        LYRLogDebug(@"<%@:%d> processed %ld events", [self class], (int)self, (long)numberOfProcessedEvents);
        
        // Reindex all affected conversations
        for (LYRConversation *conversation in conversationsByIdentifiersToReindex.allValues) {
            success = [self.dataSource reindexConversation:conversation inDatabase:db error:&error];
            if (!success) {
                *shouldRollback = YES;
                return;
            }
        }
    }];
    self.error = error;
    if (self.error) [self.delegate operation:self shouldFailDueToError:self.error];
    LYRLogDebug(@"<%@:%d> done", [self class], (int)self);
}

@end
