//
//  LYRSynchronizationOperation.m
//  LayerKit
//
//  Created by Blake Watters on 4/30/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRSynchronizationOperation.h"
#import "LYRCreateStreamOperation.h"
#import "LYRPublishEventsOperation.h"
#import "LYRGetStreamsOperation.h"
#import "LYRGetEventsOperation.h"
#import "LYRReconciliationOperation.h"
#import "LYRInboundReconOperation.h"
#import "LYRUUIDData.h"
#import "LYRHTTPResponseSerializer.h"

@interface LYRSynchronizationOperation ()
@property (nonatomic, readonly) NSURL *baseURL;
@property (nonatomic, readonly) NSURLSession *URLSession;
@property (nonatomic, readonly) LYRSynchronizationDataSource *dataSource;
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

NSMutableIndexSet *mutableIndexWithLatestSequence(LYRSequence latestSequence)
{
    NSRange sequenceRange = NSMakeRange(0, (uint32_t)(latestSequence+1));
    NSMutableIndexSet *sequencesToRequest = [NSMutableIndexSet indexSetWithIndexesInRange:sequenceRange];
    return sequencesToRequest;
}

BOOL isErrorUnrecoverable(NSError *error)
{
    if ([error.domain isEqualToString:LYRHTTPErrorDomain] && error.code == LYRHTTPErrorRemoteSystemRejection) return YES;
    
    return NO;
}

@implementation LYRSynchronizationOperation

- (id)initWithBaseURL:(NSURL *)baseURL URLSession:(NSURLSession *)URLSession dataSource:(LYRSynchronizationDataSource *)dataSource delegate:(id<LYROperationDelegate>)delegate
{
    if (!baseURL) [NSException raise:NSInvalidArgumentException format:@"`baseURL` cannot be `nil`."];
    if (!URLSession) [NSException raise:NSInvalidArgumentException format:@"`URLSession` cannot be `nil`."];
    if (!dataSource) [NSException raise:NSInvalidArgumentException format:@"`dataSource` cannot be `nil`."];
    self = [super initWithDelegate:delegate];
    if (self) {
        _baseURL = baseURL;
        _URLSession = URLSession;
        _dataSource = dataSource;
        _operationQueue = [NSOperationQueue new];
        [self.operationQueue setName:[NSString stringWithFormat:@"<%@:%p> LayerKit Synchronization Queue", [self class], self]];
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Failed to call designated initializer: Call `%@` instead.",
                                           NSStringFromSelector(@selector(initWithBaseURL:URLSession:dataSource:))]
                                 userInfo:nil];
}

- (void)execute
{
    [self reconcileAppToLayerWithCompletion:^{
        [self postPendingStreams];
    }];
    
    /**
     NOTE: There is a potential race condition here. It is possible for event publication and fetching of missing events
     to conflict with each other due to concurrent execution. To combat this case, we will not fetch missing events for any
     streams that are currently being published.
     */
    NSSet *publishableEvents = [self publishableEvents];
    NSArray *publishableMembershipEvents = [[publishableEvents allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.type IN %@", @[@(EventType_MEMBER_ADDED), @(EventType_MEMBER_REMOVED)]]];
    NSArray *publishableEventsExcludingMembership = [[publishableEvents allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (self.type IN %@)", @[@(EventType_MEMBER_ADDED), @(EventType_MEMBER_REMOVED)]]];
    
    NSSet *streamIDsBeingPublished = [self publishPendingEvents:[NSSet setWithArray:publishableEventsExcludingMembership] completion:^(NSSet *publishedStreamIDs) {
        // Fetch any missing events for our just published streams
        [self fetchMissingEventsForStreamsWithIDs:publishedStreamIDs];
    }];
    
    /**
     NOTE: Another potential race condition. Before refreshing streams, we need to make sure that events that mutat
     membership info are posted prior to refresh streams operation, otherwise server might give us an out-of-date
     list of members.
     */
    [self publishPendingEvents:[NSSet setWithArray:publishableMembershipEvents] completion:^(NSSet *publishedStreamIDs) {
        NSSet *mergedSetOfStreamIDS = [streamIDsBeingPublished setByAddingObjectsFromSet:publishedStreamIDs];
        [self refreshStreamsWithCompletion:^(NSArray *streams) {
            NSMutableSet *streamIDsToFetchMissingEvents = [NSMutableSet setWithArray:[streams valueForKey:@"streamUUID"]];
            [streamIDsToFetchMissingEvents minusSet:streamIDsBeingPublished];
            [self fetchMissingEventsForStreamsWithIDs:streamIDsToFetchMissingEvents];
        }];
    }];
    [self.operationQueue waitUntilAllOperationsAreFinished];
    [self reconcileLayerToApp];
    [self.stateMachine finish];
}

- (void)reconcileAppToLayerWithCompletion:(void (^)(void))completion
{
    LYRReconciliationOperation *reconciliationOperation = [[LYRReconciliationOperation alloc] initWithDataSource:self.dataSource delegate:self.delegate];
    [reconciliationOperation start];
    [reconciliationOperation waitUntilFinished];
    // Post streams only if there weren't any errors or reconciled events
    if (![reconciliationOperation error] && completion) completion();
}

- (void)reconcileLayerToApp
{
    LYRInboundReconOperation *inboundReconOperation = [[LYRInboundReconOperation alloc] initWithDataSource:self.dataSource delegate:self.delegate];
    [inboundReconOperation start];
    [inboundReconOperation waitUntilFinished];
}

- (void)postPendingStreams
{
    // Publish any pending streams
    __block NSError *error = nil;
    __block BOOL success = NO;
    __block NSSet *unpublishedStreams;
    __block NSMutableSet *streamsToDelete = [NSMutableSet set];
    LYRLogDebug(@"publishing pending streams...");
    // TODO: should create and then post events to stream concurrently
    [self.dataSource performTransactionWithBlock:^(FMDatabase *db, BOOL *shouldRollback) {
        unpublishedStreams = [self.dataSource unpostedStreamsInDatabase:db error:&error];
        if (!unpublishedStreams) { success = NO; return; }
        LYRLogDebug(@"about to publish %lu stream(s)", (unsigned long)unpublishedStreams.count);
        for (LYRStream *stream in unpublishedStreams) {
            LYRCreateStreamOperation *createStreamOperation = [[LYRCreateStreamOperation alloc] initWithBaseURL:self.baseURL URLSession:self.URLSession delegate:self.delegate];
            [createStreamOperation start];
            [createStreamOperation waitUntilFinished];
            if (!createStreamOperation.error) {
                stream.stream_id = [[createStreamOperation stream] stream_id];
                if (!stream.stream_id) @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Received a null stream_id back from the server when posting a new stream" userInfo:@{@"stream":stream}];
                LYRLogDebug(@"adding stream_id:%@ to existing stream", stream.streamUUID.UUIDString);
                success = [self.dataSource persistStreams:[NSSet setWithObject:stream] toDatabase:db error:&error];
            } else {
                LYRLogError(@"error when posting create stream for stream database identifier:%u request %@", stream.databaseIdentifier, createStreamOperation.error);
                if (isErrorUnrecoverable(createStreamOperation.error)) {
                    // Should delete the object that's causing the unrecoverable
                    // error from the data source.
                    [streamsToDelete addObject:stream];
                }
            }
        }
    }];
    
    if (streamsToDelete.count) {
        // We have to delete the stream outside a transaction,
        // because 'ON DELETE CASCADE' with PRAGMA foreign_keys = ON doesn't work in transactions.
        [self.dataSource inDatabase:^(FMDatabase *db) {
            [self.dataSource deleteStreams:streamsToDelete fromDatabase:db error:&error];
        }];
    }
}

- (NSSet *)publishableEvents
{
    __block NSError *error = nil;
    __block NSSet *unpublishedEvents;
    [self.dataSource performTransactionWithBlock:^(FMDatabase *db, BOOL *shouldRollback) {
        unpublishedEvents = [self.dataSource publishableEventsInDatabase:db error:&error];
        if (!unpublishedEvents) *shouldRollback = YES;
    }];
    if (!unpublishedEvents) {
        self.error = error;
        [self.stateMachine finish];
        return nil;
    }
    return unpublishedEvents;
}

- (NSSet *)publishPendingEvents:(NSSet *)events completion:(void (^)(NSSet *streamIDs))completion
{
    // Publish any pending events
    NSSet *streamIDs = [NSSet set];
    if ([events count]) {
        LYRLogDebug(@"<%@:%p> Publishing %ld local Events...", [self class], self, (unsigned long)[events count]);
        NSMutableDictionary *eventsByStreamID = [NSMutableDictionary new];
        for (LYREvent *event in events) {
            if (!eventsByStreamID[event.streamUUID]) eventsByStreamID[event.streamUUID] = [NSMutableSet new];
            [eventsByStreamID[event.streamUUID] addObject:event];
            LYRLogDebug(@"will publish event:%@", event);
        }
        
        streamIDs = [NSSet setWithArray:[eventsByStreamID allKeys]];
        LYRPublishEventsOperation *publishEventsOperation = [[LYRPublishEventsOperation alloc] initWithBaseURL:self.baseURL URLSession:self.URLSession eventsByStreamID:eventsByStreamID delegate:self.delegate];
        NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            if (publishEventsOperation.sequencesByEvent) {
                [self persistSequencesByEvent:publishEventsOperation.sequencesByEvent];
            }
            if (completion) completion(streamIDs);
        }];
        [blockOperation addDependency:publishEventsOperation];
        [self.operationQueue addOperation:publishEventsOperation];
        [self.operationQueue addOperation:blockOperation];
    } else {
        if (completion) completion([NSSet set]);
    }
    return streamIDs;
}

- (void)persistSequencesByEvent:(NSMapTable *)sequencesByEvent
{
    LYRLogDebug(@"<%@:%p> Persisting sequences for %@ published Events...", [self class], self, [sequencesByEvent valueForKeyPath:@"allValues.@count.@sum"]);
    __block NSError *error = nil;
    __block BOOL success = NO;
    
    [self.dataSource performTransactionWithBlock:^(FMDatabase *db, BOOL *shouldRollback) {
        success = [self.dataSource persistSequencesByEvent:sequencesByEvent toDatabase:db error:&error];
        if (!success) *shouldRollback = YES;
    }];
    if (!success) {
        LYRLogError(@"<%@:%p> Failed persisting sequences for events: %@", [self class], self, error);
    }
}

- (void)refreshStreamsWithCompletion:(void (^)(NSArray *streams))completion
{
    LYRGetStreamsOperation *refreshStreamsOperation = [[LYRGetStreamsOperation alloc] initWithBaseURL:self.baseURL URLSession:self.URLSession userID:[NSUUID UUID] delegate:self.delegate];
    __weak typeof(self)weakSelf = self;
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        if (refreshStreamsOperation.streams) {
            LYRLogDebug(@"received %lu stream(s)", (unsigned long)refreshStreamsOperation.streams.count);
            NSMutableSet *persistableStreams = [NSMutableSet setWithCapacity:[refreshStreamsOperation.streams count]];
            for (LYRStream *stream in refreshStreamsOperation.streams) {
                [persistableStreams addObject:stream];
                LYRLogVerbose(@"received stream:%@ with latest seq:%d", LYRUUIDFromData(stream.stream_id).UUIDString, stream.seq);
            }
            __block NSError *error = nil;
            __block BOOL success = NO;
            [self.dataSource performTransactionWithBlock:^(FMDatabase *db, BOOL *shouldRollback) {
                success = [weakSelf.dataSource persistStreams:persistableStreams toDatabase:db error:&error];
                if (!success) *shouldRollback = YES;
            }];
            if (success) {
                if (completion) completion(refreshStreamsOperation.streams);
            } else {
                LYRLogError(@"<%@:%p> Failed persisting streams: %@", [self class], self, error);
            }
        }
    }];
    [blockOperation addDependency:refreshStreamsOperation];
    [self.operationQueue addOperation:refreshStreamsOperation];
    [self.operationQueue addOperation:blockOperation];
}

- (void)fetchMissingEventsForStreamsWithIDs:(NSSet *)streamIDs
{
    if (![streamIDs count]) return;
    
    __block NSError *error = nil;

    // Generate a @{stream_uuid:server_sequence} based on refreshed streams (that should be the latest sequence number data)
    __block NSMapTable *sequencesByStream = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality
                                                                      valueOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality capacity:0];
    __block NSSet *streams;
    [self.dataSource performTransactionWithBlock:^(FMDatabase *db, BOOL *shouldRollback) {
        streams = [self.dataSource streamsWithIDs:streamIDs inDatabase:db error:&error];
        if (!streams) {
            *shouldRollback = YES;
            LYRLogError(@"<%@:%p> Failed retrieving streams with ID %@: %@", [self class], self, streamIDs, error);
            return;
        }
        for (LYRStream *stream in streams) {
            NSIndexSet *existingSequences = [self.dataSource sequencesForStream:stream inDatabase:db error:&error];
            if (existingSequences) {
                NSMutableIndexSet *sequencesToRequest = mutableIndexWithLatestSequence(stream.seq);
                [sequencesToRequest removeIndexes:existingSequences];
                [sequencesByStream setObject:sequencesToRequest forKey:stream];
            } else {
                LYRLogError(@"<%@:%p> Failed retrieving sequences for Stream ID %u: %@", [self class], self, stream.databaseIdentifier, error);
                return;
            }
        }
    }];
    
    LYRGetEventsOperation *operation = [[LYRGetEventsOperation alloc] initWithBaseURL:self.baseURL URLSession:self.URLSession sequencesByStream:sequencesByStream delegate:self.delegate];
    __weak typeof(self)weakSelf = self;
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        if (operation.eventsByStream) {
            NSMutableSet *events = [NSMutableSet new];
            for (LYRStream *stream in operation.eventsByStream) {
                for (id object in [operation.eventsByStream objectForKey:stream]) {
                    if ([object isKindOfClass:[NSError class]]) {
                        LYRLogError(@"<%@:%p> Encountered error while fetching event for Stream ID %u: %@", [self class], self, stream.databaseIdentifier, error);
                    } else if ([object isKindOfClass:[LYREvent class]]) {
                        LYREvent *event = object;
                        event.stream_id = stream.stream_id;
                        [events addObject:event];
                    } else {
                        [NSException raise:NSInternalInconsistencyException format:@"Unexpected event result of type '%@' (%@)", [object class], object];
                    }
                }
            }
            __block BOOL success;
            [self.dataSource performTransactionWithBlock:^(FMDatabase *db, BOOL *shouldRollback) {
                success = [weakSelf.dataSource persistEvents:events toDatabase:db error:&error];
                if (!success) *shouldRollback = YES;
            }];
            if (!success) {
                LYRLogError(@"<%@:%p> Failed persisting events: %@", [self class], self, error);
            }
        }
    }];
    [blockOperation addDependency:operation];
    [self.operationQueue addOperation:operation];
    [self.operationQueue addOperation:blockOperation];
}

@end
