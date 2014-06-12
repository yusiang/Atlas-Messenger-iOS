//
//  LYRSynchronizationDataSource.h
//  LayerKit
//
//  Created by Klemen Verdnik on 25/04/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDatabase.h>
#import <FMDatabaseQueue.h>
#import "messaging.h"
#import "LYREvent.h"
#import "LYRStream.h"
#import "LYRConversation.h"
#import "LYRSyncableChange.h"
#import "LYRMessage.h"

/**
 @abstract Returns the path to the `layer-client-messaging-schema` Bundle.
 @discussion The layer-client-messaging-schema bundle is built via CocoaPods from the master schema repository
 managed by Monkey Butler.
 @see https://github.com/layerhq/layer-client-messaging-schema
 */
NSBundle *LYRClientMessagingSchemaBundle(void);

/**
 The domain for errors emitted at the data source layer.
 */
extern NSString *const LYRSynchronizationDataSourceErrorDomain;

typedef NS_ENUM(NSUInteger, LYRSynchronizationDataSourceError) {
    /**
     Returned when the data source fetch or persist operation failed unexpectedly.
     */
    LYRSynchronizationDataSourceErrorUnexpected            = 5000,
    /**
     Returned when the data source coulnd't do a perist or fetch operation for a given streamUUID.
     */
    LYRSynchronizationDataSourceErrorStreamDoesntExist     = 5001,
};


// Database schema version of the current build
extern NSUInteger const LYRSynchronizationDataSourceSchemaVersion;

/**
 The `LYRSynchronizationDataSource` class manages persisting and fetching syncrhonization objects, which also provides basic querying.
 @warning When using this class you should aways work with identifiable Thrift object - that's objects that end with ID suffix (e.g.: LYREvent, LYRStream). The reason behin it is, once you fetch a specific object, it needs to have a reference you can use in order to either mutate its properties or delete it from the persistence store.
 */
@interface LYRSynchronizationDataSource : NSObject

/**
 @abstract Creates and returns a data source with an up to database at the given path.
 @discussion This method takes care of initializing and loading/migrating
 */
+ (instancetype)dataSourceWithUpToDateDatabaseAtPath:(NSString *)path;

#pragma mark - Data Source API

/**
 @abstract Initialize a data source with a database at the given path. If path is `nil`, then an in-memory database is created.
 @param path The path at which to create or open the database. If `nil`, then a temporary in-memory database is created. If an empty string
 is given `@""`, then a database is created at temporary file path.
 @return The receiver, initialized with a database at the given path. `nil` in a case of a failure.
 */
- (id)initWithDatabaseAtPath:(NSString *)path;

/**
 @abstract Ensures that the schema in the database managed by the receiver is up to date.
 @discussion This method will load a schema snapshot into an empty database or migrate an existing database that is not up to date.
 @param error A pointer to an error object to be set upon failure
 @return YES if the create schema operation was successful; otherwise NO.
 @warning This should only be called in case of an empty or dropped persistence store. It will return an error if trying to create schema over existing one.
 */
- (BOOL)ensureSchemaUpToDate:(out NSError *__autoreleasing *)error;

/**
 @abstract Executes the block in a transaction.
 @param database Database reference.
 @param transactionBlock Transaction block with a `FMDatabase` instance and a pointer to the `shouldRollback` switch.
 */
- (void)performTransactionWithBlock:(void (^)(FMDatabase *db, BOOL *shouldRollback))transactionBlock;

/**
 @abstract Executes a block on the underlying database.
 @param block The block to execute on the database. The block has no return value and accepts one argument: a reference to the database.
 */
- (void)inDatabase:(void (^)(FMDatabase *db))block;

#pragma mark Stream and membership

/**
 @abstract Collects and returns all streams that persist in the persistence store.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return A set of stream objects in a form of `LYRStream` instances; empty set, if the operation yielded no results; `nil` in case of a failure.
 */
- (NSSet *)allStreamsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Collects and returns all streams with the specified identifiers from the database.
 @param streamIDs The set of `stream_id` values to retrieve the corresponding stream representations of. Passing `nil` will retrieve all streams.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return A set of stream objects in a form of `LYRStream` instances; empty set, if the operation yielded no results; `nil` in case of a failure.
 */
- (NSSet *)streamsWithIDs:(NSSet *)streamIDs inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Collects and returns all unposted (pending) streams.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return A set of stream objects in a form of `LYRStream` instances; empty set, if the operation yielded no results; `nil` in case of a failure.
 */
- (NSSet *)unpostedStreamsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Collects and returns all unprocessed (non-reconciled) streams.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return A set of stream objects in a form of `LYRStream` instances; empty set, if the operation yielded no results; `nil` in case of a failure.
 */
- (NSSet *)unprocessedStreamsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Fetch and return stream information for given stream identifier.
 @param streamIdentifier Stream identifier of type `NSUUID` of the stream to fetch.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return The `LYRStream` instance, containing latest sequence number and membership info.
 */
- (LYRStream *)streamForIdentifier:(NSUUID *)streamIdentifier inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Fetch and return stream information for given stream database identifier.
 @param streamIdentifier Stream database identifier of the stream to fetch.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return The `LYRStream` instance, containing latest sequence number and membership info.
 */
- (LYRStream *)streamForDatabaseIdentifier:(LYRSequence)streamDatabaseIdentifier inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Persist a set of streams to the persistence store.
 @param streams A set of `LYRStream` instances.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return YES if the persist operation was successful; otherwise NO.
 */
- (BOOL)persistStreams:(NSSet *)streams toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Deletes a set of streams from the persistence store.
 @param streams A set of `LYRStream` instances to delete.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return YES if the delete operation was successful; otherwise NO.
 */
- (BOOL)deleteStreams:(NSSet *)streams fromDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Collects and returns a set of members for the given stream.
 @param stream The `LYRStream` instance of which we want to fetch members for.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return A set of member identifiers in a form of `NSUUID` instances; empty set, if the operation yielded no results; `nil` in case of a failure.
 */
- (NSSet *)membersForStream:(LYRStream *)stream inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

#pragma mark Events

/**
 @abstract Persist a set of events to the persistence store.
 @param events A set of `LYREvent` instances.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return YES if the persist operation was successful; otherwise NO.
 */
- (BOOL)persistEvents:(NSSet *)events toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Collects and returns a set of publishable events.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return A set of event objects in a form of `LYREvent` instances; empty set, if the operation yielded no results; `nil` in case of a failure.
 */
- (NSSet *)publishableEventsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Collects and returns a set of events that cannot be published to the server, since their streams haven't been created on the server yet.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return A set of event objects in a form of `LYREvent` instances; empty set, if the operation yielded no results; `nil` in case of a failure.
 */
- (NSSet *)unpublishableEventsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Collects and returns a set of unprocessed events.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return A set of event objects in a form of `LYREvent` instances; empty set, if the operation yielded no results; `nil` in case of a failure.
 */
- (NSSet *)unprocessedEventsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Collects and returns a set of posted and/or processed events.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return A set of event objects in a form of `LYREvent` instances; empty set, if the operation yielded no results; `nil` in case of a failure.
 */
- (NSSet *)postedAndProcessedEventsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Delete given unprocessed events.
 @param unprocessedEvents A set of `LYREvents` instances to delete from the persistence store.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return YES if the delete operation was successful; otherwise NO.
 */
- (BOOL)deleteUnprocessedEvents:(NSSet *)unprocessedEvents inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Persists new server-sequence numbers for given events.
 @param sequencesByEvent An `NSMapTable` containing `LYREvents` for keys and `NSNumbers` for new server-sequence number values.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return YES if the persist operation was successful; otherwise NO.
 */
- (BOOL)persistSequencesByEvent:(NSMapTable *)sequencesByEvent toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Collects server-sequence numbers for a given stream and returns them in a form of an `NSIndexSet`.
 @param stream The `LYRStream` instance for which we want to fetch the set of server-sequence numbers.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return An instance of `NSIndexSet` containing server-sequence numbers as indexes.
 */
- (NSIndexSet *)sequencesForStream:(LYRStream *)stream inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

#pragma mark Conversations

/**
 @abstract Persist a set of conversations to the persistence store.
 @param events A set of `LYRConversation` instances.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return YES if the persist operation was successful; otherwise NO.
 @discussion If the `LYRConversation` object has an indentifier with a `nil` value, it will generate a new conversation in the persistence store. Once the conversation has been posted to the server, `identifier` value is populated.
 */
- (BOOL)persistConversations:(NSSet *)conversations toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Persists conversation's stream database identifier (foreign key).
 @param foreignKeysByIdentifiers An `NSMapTable` with `NSUUID` stream ids for keys and @(stream.database_identifiers) for values.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return YES if the persist operation was successful; otherwise NO.
 @discussion If the `LYRConversation` object has an indentifier with a `nil` value, it will generate a new conversation in the persistence store. Once the conversation has been posted to the server, `identifier` value is populated.
 */
- (BOOL)persistConversationsStreamForeignKeysByIdentifiers:(NSMapTable *)foreignKeysByIdentifiers toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Collects and returns a set of conversations.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return A set of `LYRConversation` instances; empty set, if the operation yielded no results; `nil` in case of a failure.
 */
- (NSSet *)conversationsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Fetches a conversation for a given conversation identifier.
 @param conversationIdentifiers An ordered set of Layer defined stream identifier in a form of nn `NSUUID` instance.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return An order set with `LYRConversation` instance that matches the conversation identifier; `nil` in case of a failure.
 */
- (NSOrderedSet *)conversationsForIdentifiers:(NSOrderedSet *)conversationIdentifiers inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Persist a single participant by adding it to the given conversation.
 @param participant An `NSString` identifier of a participant.
 @param seq Server sequence number of the event that caused the addition of the participant to the conversation.
 @param date Server time stamp of the event.
 @param conversationIdentifier An `NSUUID` identifier of the conversation / stream.
 @param error An error object describing the failure that was encountered.
 @return YES if the persist operation was successful; otherwise NO.
 @discussion This method is called by the sync engine whenever it processes an incoming (unprocessed) event. The method should not cause any trigger to generate any syncable changes in the `syncable_changes` table.
 */
- (BOOL)persistAddParticipant:(NSString *)participant seq:(LYRSequence)seq date:(NSDate *)date conversationIdentifier:(NSUUID *)conversationIdentifier toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Persist a single participant by removing it from the given conversation.
 @param participant An `NSString` identifier of a participant.
 @param seq Server sequence number of the event that caused the removal of the participant from the conversation.
 @param date Server time stamp of the event.
 @param conversationIdentifier An `NSUUID` identifier of the conversation / stream.
 @param error An error object describing the failure that was encountered.
 @return YES if the persist operation was successful; otherwise NO.
 @discussion This method is called by the sync engine whenever it processes an incoming (unprocessed) event. The method should not cause any trigger to generate any syncable changes in the `syncable_changes` table.
 */
- (BOOL)persistRemoveParticipant:(NSString *)participant seq:(LYRSequence)seq date:(NSDate *)date conversationIdentifier:(NSUUID *)conversationIdentifier toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Fetches and returns a participant's ID for a given participants database identifier.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return A set of `LYRConversation` instances; empty set, if the operation yielded no results; `nil` in case of a failure.
 */
- (NSString *)participantForDatabaseIdentifier:(LYRSequence)participantDatabaseIdentifier inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Collects and returns a set of syncable changes.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return A set of `LYRSyncableChange` instances; empty set, if the operation yielded no results; `nil` in case of a failure.
 */
- (NSSet *)syncableChangesInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Fetches related syncable change data (depending on table_name) and generates a `LYREvent` object of type EventType_MEMBER_ADDED or EventType_MEMBER_REMOVED.
 @param syncableChange Syncable change instance for which we want to generate `LYREvent`.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return An instance of `LYREvent`; `nil` in case of a failure.
 */
- (LYREvent *)eventFromParticipantSyncableChange:(LYRSyncableChange *)syncableChange inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Fetches related syncable change data (depending on table_name) and generates a `LYREvent` object of type EventType_MESSAGE.
 @param syncableChange Syncable change instance for which we want to generate `LYREvent`.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return An instance of `LYREvent`; `nil` in case of a failure.
 */
- (LYREvent *)eventFromMessageSyncableChange:(LYRSyncableChange *)syncableChange inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Delete all syncable changes found in `syncable_changes` table.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return YES if the delete operation was successful; otherwise NO.
 */
- (BOOL)deleteAllSyncableChangesInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Delete given syncable changes.
 @param syncableChanges A set of `LYRSyncableChanges` instances to delete from the persistence store.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return YES if the delete operation was successful; otherwise NO.
 */
- (BOOL)deleteSyncableChanges:(NSSet *)syncableChanges inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

#pragma mark Messages

/**
 @abstract Persists a single message to the persistence store.
 @param message Message to persist in a form of `LYRMessage`.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return YES if the delete operation was successful; otherwise NO.
 */
- (BOOL)persistMessage:(LYRMessage *)message toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Collects and returns a set of syncable changes.
 @param conversation A `LYRConversation` instance for which to collect messages.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return An ordered set of `LYRMessage` instances; empty set, if the operation yielded no results; `nil` in case of a failure.
 */
- (NSOrderedSet *)messagesForConversation:(LYRConversation *)conversation inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Persist (update) messages's `eventDatabaseIdentifier` property in the database.
 @param eventDatabaseIdentifier Database identifier of the event.
 @param messageDatabaseIdentifier Database identifier of the message we want to update.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return YES if the persist operation was successful; otherwise NO.
 */
- (BOOL)persistMessageEventDatabaseIdentifier:(LYRSequence)eventDatabaseIdentifier forMessageDatabaseIdentifier:(LYRSequence)messageDatabaseIdentifier toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Reindex message order for given conversation
 @param conversation A `LYRConversation` instance for which to reindex the message order.
 @param database Database referece.
 @param error An error object describing the failure that was encountered.
 @return YES if the reindex operation was successful; otherwise NO.
 */
- (BOOL)reindexConversation:(LYRConversation *)conversation inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

/**
 @abstract Add a message order index entry for a newly created message.
 @param message A `LYRMessage` instance for which to add a message order index entry.
 @param database Database referece.
 @param error An error object describing the failure that was encountered.
 @return YES if the reindex operation was successful; otherwise NO.
 */
- (BOOL)addMessageOrderIndexForMessage:(LYRMessage *)message inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

#pragma mark Deprecated

/**
 @abstract Persists a new sequence number to a given stream.
 @param latestSequenceNumber The value of the latest sequence number we want to persist into a given stream.
 @param streamIdentifier The stream identifier in `NSUUID` format.
 @param error An error object describing the failure that was encountered.
 @return YES if the persist operation was successful; otherwise NO.
 */
- (BOOL)presistLatestSequence:(LYRSequence)latestSequenceNumber forStreamIdentifier:(NSUUID *)streamIdentifier error:(out NSError *__autoreleasing *)error;

/**
 @abstract Fetch the latest sequence number of a given stream.
 @param latestSequenceNumber The latest sequence number set after a successful fetch; If operation failes `latestSequenceNumber` is untouched.
 @param streamIdentifier The stream identifier in `NSUUID` format.
 @param error An error object describing the failure that was encountered.
 @return YES if the fetch operation was successful; otherwise NO.
 */
- (BOOL)latestSequence:(out LYRSequence *)latestSequenceNumber forStreamIndentifier:(NSUUID *)streamIdentifier error:(out NSError *__autoreleasing *)error;

@end
