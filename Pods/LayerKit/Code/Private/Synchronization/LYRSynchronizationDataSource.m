//
//  LYRSynchronizationDataSource.m
//  LayerKit
//
//  Created by Klemen Verdnik on 25/04/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <FMDBMigrationManager/FMDBMigrationManager.h>
#import "LYRSynchronizationDataSource.h"
#import "LYRUUIDData.h"
#import "LYREvent.h"
#import "LYRConversation.h"
#import "LYRConversation+Internal.h"
#import "LYRMessage.h"
#import "LYRMessage+Internal.h"
#import "LYRMessagePart.h"
#import "LYRMessagePart+Internal.h"

NSBundle *LYRClientMessagingSchemaBundle(void)
{
    NSBundle *parentBundle = [NSBundle bundleForClass:[LYRSynchronizationDataSource class]];
    NSBundle *schemaBundle = [NSBundle bundleWithPath:[parentBundle pathForResource:@"layer-client-messaging-schema" ofType:@"bundle"]];
    if (!schemaBundle) [NSException raise:NSInternalInconsistencyException format:@"Failed to locate `layer-client-messaging-schema.bundle` in %@", schemaBundle];
    return schemaBundle;
}

NSUInteger const LYRSynchronizationDataSourceSchemaVersion = 1;
NSString *const LYRSynchronizationDataSourceErrorDomain = @"com.layer.LayerKit.SynchronizationDataSource";

@interface LYRSynchronizationDataSource ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

// Private category of LYRStream
@interface LYRStream (Private)
@property (nonatomic) LYRSequence databaseIdentifier;
- (id)initWithDatabaseIdentifier:(LYRSequence)databaseIdentifier;
@end

// Private category of LYREvent
@interface LYREvent (Private)
@property (nonatomic) LYRSequence databaseIdentifier;
@property (nonatomic) LYRSequence streamDatabaseIdentifier;
@end

static NSArray *LYRExplodeSQLStatements(NSString *input)
{
    NSMutableArray *trimmedLines = [NSMutableArray array];
    for (NSString *line in [input componentsSeparatedByString:@"\n"]) {
        [trimmedLines addObject:[line stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]]];
    }
    NSString *trimmedJoined = [trimmedLines componentsJoinedByString:@"\n"];
    return [trimmedJoined componentsSeparatedByString:@"\n\n"];
}

static LYREvent *LYREventFromFMResultSet(FMResultSet *resultSet, FMDatabase *db)
{
    // Map event's root level properties
    LYRSequence databaseIdentifier = [resultSet intForColumn:@"event_database_identifier"];
    LYRSequence streamDatabaseIdentifier = [resultSet intForColumn:@"stream_database_identifier"];
    LYRSequence messageDatabaseIdentifier = [resultSet columnIsNull:@"msg_db_id"] ? LYRSequenceNotDefined : [resultSet intForColumn:@"msg_db_id"];
    
    // Create a new instance of LYREvent
    LYREvent *event = [LYREvent eventWithDatabaseIdentifier:databaseIdentifier streamDatabaseIdentifier:streamDatabaseIdentifier messageDatabaseIdentifier:messageDatabaseIdentifier];
    event.type = [resultSet intForColumn:@"type"];
    event.creator_id = [resultSet stringForColumn:@"creator_id"];
    event.seq = [resultSet intForColumn:@"eventSeq"];
    event.timestamp = [resultSet intForColumn:@"timestamp"];
    event.preceding_seq = [resultSet intForColumn:@"preceding_seq"];
    event.client_seq = [resultSet intForColumn:@"client_seq"];
    event.subtype = (uint8_t)[resultSet intForColumn:@"subtype"];
    event.external_content_id = [resultSet dataForColumn:@"external_content_id"];
    event.member_id = [resultSet stringForColumn:@"member_id"];
    event.target_seq = [resultSet intForColumn:@"target_seq"];
    event.stream_id = [resultSet dataForColumn:@"event_stream_id"];

    // Map event's metadata keys / values
    NSMutableDictionary *event_meta_data = [NSMutableDictionary dictionary];
    FMResultSet *resultMetadata = [db executeQuery:@"SELECT * FROM event_metadata WHERE event_database_identifier = ?", @(event.databaseIdentifier)];
    if (!resultMetadata) return nil;
    while ([resultMetadata next]) {
        NSString *key = [resultMetadata stringForColumn:@"key"];
        NSData *value = [resultMetadata dataForColumn:@"value"];
        value ? event_meta_data[key] = value : nil;
    }
    event.metadata = event_meta_data.count ? event_meta_data : nil;

    // Map event's content and content values
    NSMutableArray *content_types = [NSMutableArray array];
    NSMutableArray *content_values = [NSMutableArray array];
    FMResultSet *resultContentParts = [db executeQuery:@"SELECT * FROM event_content_parts WHERE event_database_identifier = ?", @(event.databaseIdentifier)];
    if (!resultMetadata) return nil;
    while ([resultContentParts next]) {
        NSString *type = [resultContentParts stringForColumn:@"type"];
        NSData *value = [resultContentParts dataForColumn:@"value"];
        [content_types addObject:type];
        [content_values addObject:value ? value : [NSNull null]];
    }
    event.content_types = content_types.count ? content_types : nil;
    event.inline_content_parts = content_values.count ? content_values : nil;
    return event;
}

static LYRConversation *LYRConversationFromFMResultSet(FMResultSet *resultSet, FMDatabase *db)
{
    // Add the mapped event object to the list
    LYRConversation *conversation = [LYRConversation new];
    conversation.databaseIdentifier = (LYRSequence)[resultSet intForColumn:@"conv_db_id"];
    conversation.streamDatabaseIdentifier = (LYRSequence)[resultSet columnIsNull:@"stream_database_identifier"] ? LYRSequenceNotDefined : [resultSet intForColumn:@"stream_database_identifier"];
    conversation.identifier = [resultSet dataForColumn:@"stream_id"] ? LYRUUIDFromData([resultSet dataForColumn:@"stream_id"]) : nil;

    FMResultSet *resultParticipants = [db executeQuery:@"SELECT * FROM conversation_participants WHERE conversation_database_identifier = ? AND deleted_at IS NULL", @(conversation.databaseIdentifier)];
    if (!resultParticipants) return nil;

    NSMutableSet *participants = [NSMutableSet set];
    while ([resultParticipants next]) {
        NSString *participant = [resultParticipants stringForColumn:@"member_id"];
        [participants addObject:participant];
    }
    conversation.participants = [participants copy];
    return conversation;
}

@implementation LYRSynchronizationDataSource

+ (instancetype)dataSourceWithUpToDateDatabaseAtPath:(NSString *)path
{
    LYRSynchronizationDataSource *dataSource = [[self alloc] initWithDatabaseAtPath:path];
    NSError *error = nil;
    BOOL success = [dataSource ensureSchemaUpToDate:&error];
    if (!success) {
        LYRLogError(@"Failed to load database at path '%@': %@", path, error);
        return nil;
    }
    return dataSource;
}

- (instancetype)initWithDatabaseAtPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
        // If db failed to open the database at given resource path,
        // we should fail the whole data source creation.
        if (!_dbQueue) {
            LYRLogError(@"could not instantiate the SQLite db on path: %@", path);
            return nil;
        }
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer: Call `initWithDatabaseAtPath:`." userInfo:nil];
}

- (BOOL)attemptBlock:(BOOL(^)(void))block
{
    if (!block) return NO;
    return block();
}

#pragma mark - Private methods

#pragma mark Schema

- (BOOL)ensureSchemaUpToDate:(out NSError *__autoreleasing *)error
{
    __block BOOL success = NO;
    __block NSError *localError = nil;
    LYRLogVerbose(@"creating schema");
    
    [self inDatabase:^(FMDatabase *database) {
        database.logsErrors = YES;
        [database executeUpdate:@"PRAGMA foreign_keys = ON;"];
        
        // Ensure that we have an up to data database via loading the schema or migration
        NSBundle *schemaBundle = LYRClientMessagingSchemaBundle();
        FMDBMigrationManager *migrationManager = [FMDBMigrationManager managerWithDatabase:database migrationsBundle:schemaBundle];
        
        if (!migrationManager.hasMigrationsTable) {
            NSString *schemaPath = [LYRClientMessagingSchemaBundle() pathForResource:@"layer-client-messaging-schema" ofType:@"sql"];
            if (!schemaPath) [NSException raise:NSInternalInconsistencyException format:@"Failed to locate `layer-client-messaging-schema.sql` in %@", schemaBundle];
            NSString *SQL = [NSString stringWithContentsOfFile:schemaPath encoding:NSUTF8StringEncoding error:&localError];
            if (!SQL) [NSException raise:NSInternalInconsistencyException format:@"Failed loading SQL from '%@': %@", schemaPath, localError];
            success = [database executeStatements:SQL];
            if (!success) localError = [database lastError];
        } else if (migrationManager.needsMigration) {
            success = [migrationManager migrateDatabaseToVersion:UINT64_MAX progress:nil error:&localError];
            if (!success) {
                [NSException raise:NSInternalInconsistencyException format:@"Failed to create database: %@", localError];
            }
        } else {
            LYRLogVerbose(@"successfully loaded with schema version:%llu at path:%@", migrationManager.currentVersion, database.databasePath);
            success = YES;
        }
    }];

    if (success) LYRLogInfo(@"succesfully created a new schema with version:%lu", (unsigned long) LYRSynchronizationDataSourceSchemaVersion);
    else {
        if (error) *error = localError;
        LYRLogError(@"failed to create schema with %@", localError);
    }
    return success;
}

#pragma mark - Public API methods

#pragma mark - Transactions

- (void)performTransactionWithBlock:(void (^)(FMDatabase *db, BOOL *shouldRollback))transactionBlock
{
    __block BOOL shouldRollback = NO;
    __block NSUInteger changes = 0;
    if (!transactionBlock) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to perform a non instantiated transaction block." userInfo:nil];
    }
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        transactionBlock(db, &shouldRollback);
        if (shouldRollback) *rollback = YES;
        changes = [db changes];
    }];
}

- (void)inDatabase:(void (^)(FMDatabase *db))block
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        block(db);
        [db closeOpenResultSets];
    }];
}

#pragma mark Streams

- (NSSet *)streamsWithIDs:(NSSet *)streamIDs inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block NSSet *streams;
    LYRLogVerbose(@"fetching all streams");
    [self attemptBlock:^BOOL{
        FMResultSet *result = nil;
        if (streamIDs) {
            NSArray *arrayOfStreamIDs = [streamIDs allObjects];
            NSMutableArray *placeholders = [NSMutableArray arrayWithCapacity:[arrayOfStreamIDs count]];
            NSMutableArray *bindValues = [NSMutableArray arrayWithCapacity:[arrayOfStreamIDs count]];
            for (id dbIdentifier in arrayOfStreamIDs) {
                [placeholders addObject:@"?"];
                if ([dbIdentifier isKindOfClass:[NSUUID class]]) {
                    [bindValues addObject:LYRDataFromUUID(dbIdentifier)];
                } else if ([dbIdentifier isKindOfClass:[NSData class]]) {
                    [bindValues addObject:dbIdentifier];
                } else {
                    [NSException raise:NSInvalidArgumentException format:@"Cannot query for streams with ID of type %@ (%@)", [dbIdentifier class], dbIdentifier];
                }
            }
            NSString *query = [NSString stringWithFormat:@"SELECT * FROM streams WHERE stream_id IN (%@)", [placeholders componentsJoinedByString:@", "]];
            result = [database executeQuery:query withArgumentsInArray:bindValues];
        } else {
            result = [database executeQuery:@"SELECT * FROM streams"];
        }
        if (!result) {
            outError = database.lastError;
            return NO;
        }
        
        NSMutableSet *fetchedStreams = [NSMutableSet set];
        
        // Iterate through the stream_member result set
        while ([result next]) {
            LYRSequence databaseIdentifier = [result intForColumn:@"database_identifier"];
            LYRStream *stream = [[LYRStream alloc] initWithDatabaseIdentifier:databaseIdentifier];
            stream.stream_id = [result dataForColumn:@"stream_id"];
            stream.seq = [result intForColumn:@"seq"];
            
            // TODO: What is optimal in a sql transaction, LEFT OUTER JOIN or individual SELECTs based on a result set?
            FMResultSet *resultMembers = [database executeQuery:@"SELECT * FROM stream_members WHERE stream_database_identifier = ?", @(stream.databaseIdentifier)];
            NSMutableSet *fetchedMembers = [NSMutableSet set];
            // Iterate through the stream_member result set
            while ([resultMembers next]) {
                NSString *memberID = [resultMembers stringForColumn:@"member_id"];
                if (memberID) [fetchedMembers addObject:memberID];
            }
            stream.member_ids = fetchedMembers.mutableCopy;
            [fetchedStreams addObject:stream];
        }
        streams = fetchedStreams.copy;
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to fetch all streams with %@", outError);
        if (error) *error = outError;
    }
    return streams;
}

- (NSSet *)allStreamsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    return [self streamsWithIDs:nil inDatabase:database error:error];
}

- (NSSet *)unpostedStreamsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block NSSet *streams;
    LYRLogVerbose(@"fetching all streams");
    [self attemptBlock:^BOOL{
        FMResultSet *result = [database executeQuery:@"SELECT * FROM streams WHERE stream_id IS NULL"];
        if (!result) {
            outError = database.lastError;
            return NO;
        }

        NSMutableSet *fetchedStreams = [NSMutableSet set];

        // Iterate through the stream_member result set
        while ([result next]) {
            LYRSequence databaseIdentifier = [result intForColumn:@"database_identifier"];
            LYRStream *stream = [[LYRStream alloc] initWithDatabaseIdentifier:databaseIdentifier];
            stream.stream_id = [result dataForColumn:@"stream_id"];
            stream.seq = [result intForColumn:@"seq"];

            // TODO: What is optimal in a sql transaction, LEFT OUTER JOIN or individual SELECTs based on a result set?
            FMResultSet *resultMembers = [database executeQuery:@"SELECT * FROM stream_members WHERE stream_database_identifier = ?", @(stream.databaseIdentifier)];
            NSMutableSet *fetchedMembers = [NSMutableSet set];
            // Iterate through the stream_member result set
            while ([resultMembers next]) {
                NSString *memberID = [resultMembers stringForColumn:@"member_id"];
                if (memberID) [fetchedMembers addObject:memberID];
            }
            stream.member_ids = fetchedMembers.mutableCopy;
            [fetchedStreams addObject:stream];
        }
        streams = fetchedStreams.copy;
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to fetch all streams with %@", outError);
        if (error) *error = outError;
    }
    return streams;
}

- (NSSet *)unprocessedStreamsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block NSSet *streams;
    LYRLogVerbose(@"fetching all streams");
    [self attemptBlock:^BOOL{
        FMResultSet *result = [database executeQuery:
                               @"SELECT streams.*, streams.database_identifier AS stream_database_identifier, conversations.stream_database_identifier AS conv_str_db_id FROM streams "
                               @"LEFT JOIN conversations ON (streams.database_identifier = conversations.stream_database_identifier) "
                               @"WHERE conv_str_db_id IS NULL"];
        if (!result) {
            outError = database.lastError;
            return NO;
        }

        NSMutableSet *fetchedStreams = [NSMutableSet set];

        // Iterate through the stream_member result set
        while ([result next]) {
            LYRSequence databaseIdentifier = [result intForColumn:@"stream_database_identifier"];
            LYRStream *stream = [[LYRStream alloc] initWithDatabaseIdentifier:databaseIdentifier];
            stream.stream_id = [result dataForColumn:@"stream_id"];
            stream.seq = [result intForColumn:@"seq"];

            // TODO: What is optimal in a sql transaction, LEFT OUTER JOIN or individual SELECTs based on a result set?
            FMResultSet *resultMembers = [database executeQuery:@"SELECT * FROM stream_members WHERE stream_database_identifier = ?", @(stream.databaseIdentifier)];
            NSMutableSet *fetchedMembers = [NSMutableSet set];
            // Iterate through the stream_member result set
            while ([resultMembers next]) {
                NSString *memberID = [resultMembers stringForColumn:@"member_id"];
                if (memberID) [fetchedMembers addObject:memberID];
            }
            stream.member_ids = fetchedMembers.mutableCopy;
            [fetchedStreams addObject:stream];
        }
        streams = fetchedStreams.copy;
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to fetch all streams with %@", outError);
        if (error) *error = outError;
    }
    return streams;
}

- (LYRStream *)streamForIdentifier:(NSUUID *)streamIdentifier inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block LYRStream *stream;
    LYRLogVerbose(@"fetching stream for identifier:%@", streamIdentifier.UUIDString);
    [self attemptBlock:^BOOL{
        FMResultSet *result = [database executeQuery:@"SELECT * FROM streams WHERE stream_id = ? LIMIT 1", LYRDataFromUUID(streamIdentifier)];
        if (!result) {
            outError = database.lastError;
            return NO;
        }

        if ([result next]) {
            LYRSequence databaseIdentifier = [result intForColumn:@"database_identifier"];
            stream = [[LYRStream alloc] initWithDatabaseIdentifier:databaseIdentifier];
            stream.stream_id = [result dataForColumn:@"stream_id"];
            stream.seq = [result intForColumn:@"seq"];

            // TODO: What is optimal in a sql transaction, LEFT OUTER JOIN or individual SELECTs based on a result set?
            FMResultSet *resultMembers = [database executeQuery:@"SELECT * FROM stream_members WHERE stream_database_identifier = ?", @(stream.databaseIdentifier)];
            NSMutableSet *fetchedMembers = [NSMutableSet set];
            // Iterate through the stream_member result set
            while ([resultMembers next]) {
                NSString *memberID = [resultMembers stringForColumn:@"member_id"];
                if (memberID) [fetchedMembers addObject:memberID];
            }
            stream.member_ids = fetchedMembers.mutableCopy;
        }
        [result close];
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to fetch stream for identifier:%@ with %@", streamIdentifier, outError);
        if (error) *error = outError;
    }
    return stream;
}

- (LYRStream *)streamForDatabaseIdentifier:(LYRSequence)streamDatabaseIdentifier inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block LYRStream *stream;
    LYRLogVerbose(@"fetching stream for database identifier:%d", (int)streamDatabaseIdentifier);
    [self attemptBlock:^BOOL{
        FMResultSet *result = [database executeQuery:@"SELECT * FROM streams WHERE database_identifier = ? LIMIT 1", @(streamDatabaseIdentifier)];
        if (!result) {
            outError = database.lastError;
            return NO;
        }

        if ([result next]) {
            LYRSequence databaseIdentifier = [result intForColumn:@"database_identifier"];
            stream = [[LYRStream alloc] initWithDatabaseIdentifier:databaseIdentifier];
            stream.stream_id = [result dataForColumn:@"stream_id"];
            stream.seq = [result intForColumn:@"seq"];

            // TODO: What is optimal in a sql transaction, LEFT OUTER JOIN or individual SELECTs based on a result set?
            FMResultSet *resultMembers = [database executeQuery:@"SELECT * FROM stream_members WHERE stream_database_identifier = ?", @(stream.databaseIdentifier)];
            NSMutableSet *fetchedMembers = [NSMutableSet set];
            // Iterate through the stream_member result set
            while ([resultMembers next]) {
                NSString *memberID = [resultMembers stringForColumn:@"member_id"];
                if (memberID) [fetchedMembers addObject:memberID];
            }
            stream.member_ids = fetchedMembers.mutableCopy;
        }
        [result close];
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to fetch stream for database identifier:%d with %@", (int)streamDatabaseIdentifier, outError);
        if (error) *error = outError;
    }
    return stream;
}

- (BOOL)persistStreams:(NSSet *)streams toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    LYRLogVerbose(@"persisting streams");
    BOOL success = [self attemptBlock:^BOOL{
        BOOL success = NO;
        for (LYRStream *stream in streams) {
            if (![stream isKindOfClass:[LYRStream class]]) [NSException raise:NSInternalInconsistencyException format:@"Failed to persist a stream. Expected '%@' but received an object of type '%@'", [LYRStream class], [stream class]];

            // Let's see if the db already has a stream with the given `stream_id`
            BOOL streamAlreadyExists = NO;
            if (stream.stream_id) {
                FMResultSet *result = [database executeQuery:@"SELECT * FROM streams WHERE stream_id = ? LIMIT 1", stream.stream_id];
                if (!result) { outError = database.lastError; return NO; };
                if ([result next]) {
                    stream.databaseIdentifier = [result intForColumn:@"database_identifier"];
                    streamAlreadyExists = YES;
                }
                [result close];
            }
            
            BOOL didInsert = NO;
            // Persist stream info
            if (!streamAlreadyExists) {
                success = [database executeUpdate:@"INSERT OR IGNORE INTO streams (database_identifier, stream_id, seq) VALUES (?, ?, ?)", stream.databaseIdentifier != LYRSequenceNotDefined ? @(stream.databaseIdentifier) : nil, stream.stream_id, @(stream.seq)];
                if (!success) { outError = database.lastError; return NO; };
                didInsert = YES;
            }

            // Skip the update, if we had an INSERT
            if (![database changes] || streamAlreadyExists) {
                if (stream.stream_id) {
                    success = [database executeUpdate:@"UPDATE streams SET seq = ? WHERE stream_id = ?", @(stream.seq), stream.stream_id];
                    if (![database changes]) {
                        success = [database executeUpdate:@"UPDATE streams SET seq = ?, stream_id = ? WHERE database_identifier = ?", @(stream.seq), stream.stream_id, @(stream.databaseIdentifier)];
                    }
                } else {
                    success = [database executeUpdate:@"UPDATE streams SET seq = ? WHERE database_identifier = ?", @(stream.seq), @(stream.databaseIdentifier)];
                }
                if (!success) {
                    outError = database.lastError;
                    return NO;
                }
            }
            
            LYRSequence lastInsertStreamId = (LYRSequence)[database lastInsertRowId];

            // Get the row ID (primary key) of the record we just inserted and
            // update the LYRStream's databaseIdentifier, now that we have it.
            stream.databaseIdentifier = stream.databaseIdentifier == LYRSequenceNotDefined ? lastInsertStreamId : stream.databaseIdentifier;

            // Delete any previous memeberhip info.
            success = [database executeUpdate:@"DELETE FROM stream_members WHERE stream_database_identifier = ?", @(stream.databaseIdentifier)];
            if (!success) {
                outError = database.lastError;
                return NO;
            };
            
            // Persist membership info
            for (NSString *memberID in stream.member_ids) {
                LYRLogDebug(@"persist member: %@", memberID);
                success = [database executeUpdate:@"INSERT OR IGNORE INTO stream_members (stream_database_identifier, member_id) VALUES (?, ?)", @(stream.databaseIdentifier), memberID];
                if (!success) {
                    outError = database.lastError;
                    return NO;
                };
            }
        }
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to persist streams:%@ with %@", [[streams valueForKey:@"streamUUID"] valueForKey:@"UUIDString"], outError);
        if (error) *error = outError;
    }
    return success;
}

- (BOOL)deleteStreams:(NSSet *)streams fromDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block BOOL success = NO;
    LYRLogVerbose(@"deleting streams: %@", streams);
    [self attemptBlock:^BOOL{
        for (LYRStream *streamToDelete in streams) {
            success = [database executeUpdate:@"DELETE FROM streams WHERE database_identifier = ?", @(streamToDelete.databaseIdentifier)];
            if (!success) { outError = database.lastError; return NO; };
        }
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to delete streams:%@ with %@", streams, outError);
        error ? *error = outError : nil;
    }
    return success;
}

- (NSSet *)membersForStream:(LYRStream *)stream inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block NSSet *members;
    LYRLogVerbose(@"fetching members for stream:%@", stream.streamUUID.UUIDString);
    [self attemptBlock:^BOOL{
        FMResultSet *result = [database executeQuery:@"SELECT * FROM stream_members WHERE stream_database_identifier = ?", @(stream.databaseIdentifier)];
        if (!result) {
            outError = database.lastError;
            return NO;
        }
        NSMutableArray *fetchedMembers = [NSMutableArray array];
        // Iterate through the stream_member result set
        while ([result next]) {
            NSString *memberID = [result stringForColumn:@"member_id"];
            if (memberID) [fetchedMembers addObject:memberID];
        }
        members = fetchedMembers.copy;
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to fetch members for stream:%@ with %@", stream.streamUUID.UUIDString, outError);
        if (error) *error = outError;
    }
    return members;
}

#pragma mark Events

- (BOOL)persistEvents:(NSSet *)events toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    LYRLogVerbose(@"persisting %lu event(s)", (unsigned long)events.count);
    BOOL success = [self attemptBlock:^BOOL{
        BOOL success = NO;
        for (LYREvent *event in events) {
            if (![event isKindOfClass:[LYREvent class]]) [NSException raise:NSInternalInconsistencyException format:@"Failed to persist an event. Expected '%@' but received an object of type '%@'", [LYREvent class], [event class]];
            if (event.stream_id == nil && event.streamDatabaseIdentifier == LYRSequenceNotDefined) [NSException raise:NSInternalInconsistencyException format:@"Failed to persist an event. Event should have 'stream_id' OR 'streamDatabaseIdentifier' set!"];

            // Insert event's root level properties
            if (event.streamDatabaseIdentifier == LYRSequenceNotDefined) {
                // In case we don't have the `streamDatabaseIdentifier` set yet,
                // we should use the `stream_id`. We are probably persisting
                // an event received from the network (Thrift).

                // So let's find out, what's the `event.streamDatabaseIdentifier`
                // based on the `event.stream_id`.
                FMResultSet *result = [database executeQuery:@"SELECT * FROM streams WHERE stream_id = ? LIMIT 1", event.stream_id];
                if (!result) {
                    outError = database.lastError;
                    return NO;
                }

                // Iterate through the events result set
                if ([result next]) {
                    event.streamDatabaseIdentifier = [result intForColumn:@"database_identifier"];
                    [result close];
                } else {
                    [NSException raise:NSInternalInconsistencyException format:@"Failed to persist an event. stream_id='%@' doesn't exist yet in the database. Should create a new stream with that identifier before persisting the event.", LYRUUIDFromData(event.stream_id).UUIDString];
                }
            }
            
            success = [database executeUpdate:@"INSERT OR IGNORE INTO events (database_identifier, type, creator_id, seq, timestamp, preceding_seq, client_seq, subtype, external_content_id, member_id, target_seq, stream_database_identifier) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", event.databaseIdentifier != LYRSequenceNotDefined ? @(event.databaseIdentifier) : nil, @(event.type), event.creator_id, event.seqIsSet ? @(event.seq) : NULL, @(event.timestamp), @(event.preceding_seq), @(event.client_seq), @(event.subtype), event.external_content_id, event.member_id, @(event.target_seq), event.streamDatabaseIdentifier != LYRSequenceNotDefined ? @(event.streamDatabaseIdentifier) : nil];
            if (!success) {
                outError = database.lastError;
                return NO;
            }

            // Skip the update, if we had an INSERT
            if (![database changes]) {
                success = [database executeUpdate:@"UPDATE events SET type = ?, creator_id = ?, seq = ?, timestamp = ?, preceding_seq = ?, client_seq = ?, subtype = ?, external_content_id = ?, member_id = ?, target_seq = ?, stream_database_identifier = ? WHERE database_identifier = ?", @(event.type), event.creator_id, event.seqIsSet ? @(event.seq) : NULL, @(event.timestamp), @(event.preceding_seq), @(event.client_seq), @(event.subtype), event.external_content_id, event.member_id, @(event.target_seq), event.streamDatabaseIdentifier != LYRSequenceNotDefined ? @(event.streamDatabaseIdentifier) : nil, @(event.databaseIdentifier)];
                if (!success) {
                    outError = database.lastError;
                    return NO;
                }
            }

            // Get the row ID (primary key) of the record we just inserted and
            // update the LYREvent's databaseIdentifier, now that we have it.
            event.databaseIdentifier = event.databaseIdentifier == LYRSequenceNotDefined ? (LYRSequence)[database lastInsertRowId] : event.databaseIdentifier;

            // Delete any previous event_metadata info.
            success = [database executeUpdate:@"DELETE FROM event_metadata WHERE event_database_identifier = ?", @(event.databaseIdentifier)];
            if (!success) {
                outError = database.lastError;
                return NO;
            }

            // Persist event's metadata
            for (NSString *key in event.metadata.allKeys) {
                // Insert the damn thing
                success = [database executeUpdate:@"INSERT INTO event_metadata (event_database_identifier, key, value) VALUES (?, ?, ?)", @(event.databaseIdentifier), key, event.metadata[key]];
                if (!success) {
                    outError = database.lastError;
                    return NO;
                }
            }

            // Persist content types and values
            for (NSString *type in event.content_types) {
                // Get the index number of the content part type
                LYRSequence event_content_part_id = (LYRSequence)[event.content_types indexOfObject:type];
                // Let's see, if we have a corresponding inline content part (payload)
                NSData *value = event_content_part_id < event.inline_content_parts.count ? [event.inline_content_parts objectAtIndex:(uint32_t)event_content_part_id] : nil;
                // Persist the type and the value (if available)
                success = [database executeUpdate:@"INSERT OR IGNORE INTO event_content_parts (event_content_part_id, event_database_identifier, type, value) VALUES (?, ?, ?, ?)", @(event_content_part_id), @(event.databaseIdentifier), type, value ? value : [NSNull null]];
                if (!success) {
                    outError = database.lastError;
                    return NO;
                }

                // Skip the update, if we had an INSERT
                if ([database changes]) continue;

                success = [database executeUpdate:@"UPDATE event_content_parts SET type = ?, value = ? WHERE event_content_part_id = ? AND event_database_identifier = ?", type, value, @(event_content_part_id), @(event.databaseIdentifier)];
                if (!success) {
                    outError = database.lastError;
                    return NO;
                }
            }
        }
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to persist events:%@ with %@", events, outError);
        if (error) *error = outError;
    }
    return success;
}

- (NSSet *)publishableEventsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block NSSet *events;
    LYRLogVerbose(@"fetching publishable events");
    [self attemptBlock:^BOOL{
        NSMutableSet *fetchedEvents = [NSMutableSet set];
        FMResultSet *result = [database executeQuery:
                               @"SELECT events.*, events.seq AS eventSeq, events.database_identifier AS event_database_identifier, streams.stream_id AS event_stream_id, streams.seq AS streamsSeq, messages.database_identifier as msg_db_id FROM events "
                               @"LEFT JOIN streams ON (events.stream_database_identifier = streams.database_identifier) "
                               @"LEFT JOIN messages ON (events.database_identifier = messages.event_database_identifier) "
                               @"WHERE events.seq IS NULL AND event_stream_id IS NOT NULL"];
        if (!result) { outError = database.lastError; return NO; }

        // Iterate through the events result set
        while ([result next]) {
            // Add the mapped event object to the list
            [fetchedEvents addObject:LYREventFromFMResultSet(result, database)];
        }
        events = fetchedEvents.copy;
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to fetch publishable events with %@", outError);
        error ? *error = outError : nil;
    }
    return events;
}

- (NSSet *)unpublishableEventsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block NSSet *events;
    LYRLogVerbose(@"fetching unpublishable events");
    [self attemptBlock:^BOOL{
        NSMutableSet *fetchedEvents = [NSMutableSet set];
        FMResultSet *result = [database executeQuery:
                               @"SELECT events.*, events.seq AS eventSeq, events.database_identifier AS event_database_identifier, streams.stream_id AS event_stream_id, streams.seq AS streamsSeq, messages.database_identifier as msg_db_id FROM events "
                               @"LEFT JOIN streams ON (events.stream_database_identifier = streams.database_identifier) "
                               @"LEFT JOIN messages ON (events.database_identifier = messages.event_database_identifier) "
                               @"WHERE events.seq IS NULL AND event_stream_id IS NULL"];
        if (!result) { outError = database.lastError; return NO; }
        
        // Iterate through the events result set
        while ([result next]) {
            // Add the mapped event object to the list
            [fetchedEvents addObject:LYREventFromFMResultSet(result, database)];
        }
        events = fetchedEvents.copy;
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to fetch unpublishable events with %@", outError);
        error ? *error = outError : nil;
    }
    return events;
}

- (NSSet *)unprocessedEventsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block NSSet *events;
    LYRLogVerbose(@"fetching unprocessed events");
    [self attemptBlock:^BOOL{
        NSMutableSet *fetchedEvents = [NSMutableSet set];
        FMResultSet *result = [database executeQuery:
                               @"SELECT events.*, events.seq AS eventSeq, events.database_identifier AS event_database_identifier, streams.stream_id AS event_stream_id, streams.seq AS streamsSeq, messages.database_identifier as msg_db_id FROM events "
                               @"LEFT JOIN streams ON (events.stream_database_identifier = streams.database_identifier) "
                               @"LEFT JOIN unprocessed_events ON (events.database_identifier = unprocessed_events.event_database_identifier) "
                               @"LEFT JOIN messages ON (events.database_identifier = messages.event_database_identifier) "
                               @"WHERE unprocessed_events.event_database_identifier IS NOT NULL"];
        if (!result) {
            outError = database.lastError;
            return NO;
        }

        // Iterate through the events result set
        while ([result next]) {
            // Add the mapped event object to the list
            [fetchedEvents addObject:LYREventFromFMResultSet(result, database)];
        }
        events = fetchedEvents.copy;
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to fetch unprocessed events with %@", outError);
        if (error) *error = outError;
    }
    return events;
}

- (NSSet *)postedAndProcessedEventsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block NSSet *events;
    LYRLogVerbose(@"fetching posted and processed events");
    [self attemptBlock:^BOOL{
        NSMutableSet *fetchedEvents = [NSMutableSet set];
        FMResultSet *result = [database executeQuery:
                               @"SELECT events.*, events.seq AS eventSeq, events.database_identifier AS event_database_identifier, streams.stream_id AS event_stream_id, streams.seq AS streamsSeq, messages.database_identifier as msg_db_id FROM events "
                               @"LEFT JOIN streams ON (events.stream_database_identifier = streams.database_identifier) "
                               @"LEFT JOIN unprocessed_events ON (events.database_identifier = unprocessed_events.event_database_identifier) "
                               @"LEFT JOIN messages ON (events.database_identifier = messages.event_database_identifier) "
                               @"WHERE unprocessed_events.event_database_identifier IS NULL AND events.seq IS NOT NULL"];
        if (!result) {
            outError = database.lastError;
            return NO;
        }

        // Iterate through the events result set
        while ([result next]) {
            // Add the mapped event object to the list
            [fetchedEvents addObject:LYREventFromFMResultSet(result, database)];
        }
        events = fetchedEvents.copy;
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to fetch posted and processed events with %@", outError);
        if (error) *error = outError;
    }
    return events;
}

- (BOOL)deleteUnprocessedEvents:(NSSet *)unprocessedEvents inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    LYRLogVerbose(@"deleting unprocessed events");
    BOOL success = [self attemptBlock:^BOOL{
        BOOL success = NO;
        for (LYREvent *event in unprocessedEvents) {
            success = [database executeUpdate:@"DELETE FROM unprocessed_events WHERE event_database_identifier = ?", @(event.databaseIdentifier)];
            if (!success) {
                outError = database.lastError;
                return NO;
            }
        }
        return success;
    }];
    if (outError) {
        LYRLogError(@"failed to delete unprocessed events with %@", outError);
        if (error) *error = outError;
    }
    return success;
}

- (BOOL)persistSequencesByEvent:(NSMapTable *)sequencesByEvent toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    LYRLogVerbose(@"persisting sequences by event");
    BOOL success = [self attemptBlock:^BOOL{
        BOOL success;
        for (LYREvent *event in sequencesByEvent) {
            NSNumber *sequence = [sequencesByEvent objectForKey:event];
            
            success = [database executeUpdate:@"UPDATE events SET seq = ? WHERE database_identifier = ?", sequence, @(event.databaseIdentifier)];
            if (!success) {
                outError = database.lastError;
                return NO;
            }

            if (event.stream_id == nil) [NSException raise:NSInternalInconsistencyException format:@"Failed to persist sequence by event. Event's stream_id property shouldn't be `nil`, since it's not possible to publish events for streams that don't exist in the data source yet."];

            switch (event.type) {
                case EventType_MEMBER_ADDED:
                case EventType_MEMBER_REMOVED:
                    success = [self persistConversationsParticipantsSeq:(uint32_t)sequence.integerValue memberID:event.member_id streamIdentifier:LYRUUIDFromData(event.stream_id) toDatabase:database error:&outError];
                    if (!success) {
                        outError = database.lastError;
                        return NO;
                    }
                    break;
                case EventType_MESSAGE:
                    // TODO: update message's seq
                    break;
                case EventType_MESSAGE_DELIVERED:
                case EventType_MESSAGE_READ:
                    // TODO: update message_recipient_status's seq
                    break;
                case EventType_METADATA_ADDED:
                case EventType_METADATA_REMOVED:
                    // TODO: update keyed_values's seq
                    break;
                default:
                    break;
            }
        }
        return YES;
    }];
    if (outError) {
        LYRLogError(@"Failed persist sequences by event: %@", outError);
        if (error) *error = outError;
    }
    return success;
}

- (NSIndexSet *)sequencesForStream:(LYRStream *)stream inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    LYRLogVerbose(@"fetching sequence numbers from events for stream:%@", stream.streamUUID.UUIDString);
    NSMutableIndexSet *sequences = [NSMutableIndexSet new];
    [self attemptBlock:^BOOL{
        FMResultSet *result = [database executeQuery:@"SELECT seq FROM events WHERE stream_database_identifier = ?", @(stream.databaseIdentifier)];
        if (!result) {
            outError = database.lastError;
            return NO;
        }

        while ([result next]) {
            if (![result columnIsNull:@"seq"]) {
                LYRSequence latestSequence = [result intForColumn:@"seq"];
                [sequences addIndex:(uint32_t)latestSequence];
            }
        }
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to fetch sequence numbers from events for streams with:%@ with %@", stream.streamUUID.UUIDString, outError);
        if (error) *error = outError;
    }
    return sequences;
}

#pragma mark - Conversations

- (BOOL)persistConversations:(NSSet *)conversations toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    LYRLogVerbose(@"persisting %lu conversations(s)", (unsigned long)conversations.count);
    BOOL success = [self attemptBlock:^BOOL{
        BOOL success;
        for (LYRConversation *conversation in conversations) {
            if (![conversation isKindOfClass:[LYRConversation class]]) [NSException raise:NSInternalInconsistencyException format:@"Failed to persist a conversation. Expected '%@' but received an object of type '%@'", [LYRConversation class], [conversation class]];

            // Let's see if the db already has a conversation with the given `conversation.stream_identifier`
            BOOL streamExists = NO;
            LYRSequence stream_database_identifier = LYRSequenceNotDefined;
            if (conversation.identifier) {
                FMResultSet *result = [database executeQuery:@"SELECT * FROM streams WHERE stream_id = ? LIMIT 1", LYRDataFromUUID(conversation.identifier)];
                if (!result) {
                    outError = database.lastError;
                    return NO;
                }
                if ((streamExists = [result next])) {
                    stream_database_identifier = [result intForColumn:@"database_identifier"];
                }
                [result close];
            }

            // Persist conversation info
            success = [database executeUpdate:@"INSERT OR IGNORE INTO conversations (database_identifier, stream_database_identifier) VALUES (?, ?)", conversation.databaseIdentifier != LYRSequenceNotDefined ? @(conversation.databaseIdentifier) : nil, stream_database_identifier != LYRSequenceNotDefined ? @(stream_database_identifier) : nil];
            if (!success) {
                outError = database.lastError;
                return NO;
            }

            // Skip the update, if we had an INSERT
            if (![database changes]) {
                success = [database executeUpdate:@"UPDATE conversations SET stream_database_identifier = ? WHERE database_identifier = ?", stream_database_identifier != LYRSequenceNotDefined ? @(stream_database_identifier) : nil, @(conversation.databaseIdentifier)];
                if (!success) {
                    outError = database.lastError;
                    return NO;
                }
            }

            // Get the row ID (primary key) of the record we've inserted and
            // update the LYRConversation's databaseIdentifier, now that we have it.
            conversation.databaseIdentifier = conversation.databaseIdentifier == LYRSequenceNotDefined ? (LYRSequence)[database lastInsertRowId] : conversation.databaseIdentifier;
            conversation.streamDatabaseIdentifier = stream_database_identifier;

            // Collect a set of participants that already exist in the persistence store
            // so we could diff it with the one in the `LYRConversation` we got
            // in the method arguments.
            FMResultSet *resultParticipants = [database executeQuery:@"SELECT * FROM conversation_participants WHERE conversation_database_identifier = ? AND deleted_at IS NULL", @(conversation.databaseIdentifier)];
            if (!resultParticipants) {
                outError = database.lastError;
                return NO;
            }
            NSMutableSet *alreadyPersistedParticipants = [NSMutableSet set];
            while ([resultParticipants next]) [alreadyPersistedParticipants addObject:[resultParticipants stringForColumn:@"member_id"]];

            // Make a set of participants we need to insert to the persistence store
            NSMutableSet *participantsToPersist = [[conversation participants] mutableCopy];
            [participantsToPersist minusSet:alreadyPersistedParticipants];

            // Make a set of participants we need to delete from the persistence store
            NSMutableSet *participantsToDelete = [alreadyPersistedParticipants mutableCopy];
            [participantsToDelete minusSet:conversation.participants];

            // Mark the deleted participants as deleted with a timestamp on `deleted_at` column
            for (NSUUID *participant in participantsToDelete) {
                success = [database executeUpdate:@"UPDATE conversation_participants SET deleted_at = datetime(\"NOW\") WHERE member_id = ? AND conversation_database_identifier = ?", participant, @(conversation.databaseIdentifier)];
                if (!success) {
                    outError = database.lastError;
                    return NO;
                }
            }

            // Insert participants (or update deleted ones)
            for (NSUUID *participant in participantsToPersist) {
                success = [database executeUpdate:@"INSERT OR IGNORE INTO conversation_participants (conversation_database_identifier, member_id, created_at) VALUES (?, ?, datetime(\"NOW\"))", conversation.databaseIdentifier != LYRSequenceNotDefined ? @(conversation.databaseIdentifier) : nil, participant];
                if (!success) {
                    outError = database.lastError;
                    return NO;
                }
                // Skip the update on `conversation_participants`, if we had an INSERT
                if (![database changes]) {
                    success = [database executeUpdate:@"UPDATE conversation_participants SET created_at = datetime(\"NOW\"), deleted_at = NULL WHERE conversation_database_identifier = ? AND member_id = ?", conversation.databaseIdentifier != LYRSequenceNotDefined ? @(conversation.databaseIdentifier) : nil, participant];
                    if (!success) {
                        outError = database.lastError;
                        return NO;
                    }
                }
            }

            // TODO: take care of metadata and user info (`keyed_values`).
        }
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to persist conversations:%@ with %@", conversations, outError);
        if (error) *error = outError;
    }
    return success;
}

- (BOOL)persistConversationsStreamForeignKeysByIdentifiers:(NSMapTable *)foreignKeysByIdentifiers toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    LYRLogVerbose(@"persisting conversations' stream foreign keys by conversations' database identifiers");
    BOOL success = [self attemptBlock:^BOOL{
        BOOL success;
        for (NSNumber *databaseIdentifier in foreignKeysByIdentifiers) {
            NSNumber *foreignKey = [foreignKeysByIdentifiers objectForKey:databaseIdentifier];
            success = [database executeUpdate:@"UPDATE conversations SET stream_database_identifier = ? WHERE database_identifier = ?", foreignKey, databaseIdentifier];
            if (!success) {
                outError = database.lastError;
                return NO;
            }
        }
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to persist conversations' stream foreign keys by conversations' database identifiers");
        if (error) *error = outError;
    }
    return success;
}

- (BOOL)persistConversationsParticipantsSeq:(LYRSequence)seq memberID:(NSUUID *)memberID streamIdentifier:(NSUUID *)streamIdentifier toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block BOOL success;
    LYRLogVerbose(@"persisting conversations participant's seq:%u for member:%@ with stream identifier:%@", (LYRSequence)seq, memberID, streamIdentifier.UUIDString);
    [self attemptBlock:^BOOL{
        LYRConversation *conversation = [[self conversationsForIdentifiers:[NSOrderedSet orderedSetWithObject:streamIdentifier] inDatabase:database error:&outError] firstObject];
        if (!conversation) {
            outError = database.lastError;
            return NO;
        }

        success = [database executeUpdate:@"UPDATE conversation_participants SET seq = ? WHERE member_id = ? AND conversation_database_identifier = ?", @(seq), memberID, @(conversation.databaseIdentifier)];
        if (!success) {
            outError = database.lastError;
            return NO;
        }
        return YES;
    }];
    if (outError) {
        LYRLogVerbose(@"failed persisting conversations participant's seq:%u for member:%@ with stream identifier:%@ with %@", seq, memberID, streamIdentifier.UUIDString, outError);
        if (error) *error = outError;
    }
    return success;
}

- (NSSet *)conversationsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block NSSet *conversations;
    LYRLogVerbose(@"fetching conversations");
    [self attemptBlock:^BOOL{
        NSMutableSet *fetchedConversations = [NSMutableSet set];
        FMResultSet *result = [database executeQuery:
                               @"SELECT conversations.database_identifier as conv_db_id, conversations.*, streams.database_identifier as strm_db_id, streams.* FROM conversations "
                               @"LEFT JOIN streams ON (conversations.stream_database_identifier = streams.database_identifier) "];
        if (!result) {
            outError = database.lastError;
            return NO;
        }

        // Iterate through the events result set
        while ([result next]) {
            LYRConversation *conversation = LYRConversationFromFMResultSet(result, database);
            if (!conversation) {
                outError = database.lastError;
                return NO;
            }
            [fetchedConversations addObject:conversation];
        }
        conversations = fetchedConversations;
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to fetch conversations with %@", outError);
        if (error) *error = outError;
    }
    return conversations;
}

- (NSOrderedSet *)conversationsForIdentifiers:(NSOrderedSet *)conversationIdentifiers inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block NSOrderedSet *conversations;
    LYRLogVerbose(@"fetching conversation for identifiers:%@", [[[[conversationIdentifiers valueForKeyPath:@"UUIDString"] description] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"    " withString:@""]);
    [self attemptBlock:^BOOL{
        NSMutableOrderedSet *fetchedConversations = [NSMutableOrderedSet orderedSet];
        for (NSUUID *conversationIdentifier in conversationIdentifiers) {
            LYRConversation *conversation;
            FMResultSet *result = [database executeQuery:
                                   @"SELECT conversations.database_identifier as conv_db_id, conversations.*, streams.database_identifier as strm_db_id, streams.* FROM conversations "
                                   @"LEFT JOIN streams ON (conversations.stream_database_identifier = streams.database_identifier) "
                                   @"WHERE streams.stream_id = ? LIMIT 1", LYRDataFromUUID(conversationIdentifier)];
            if (!result) {
                outError = database.lastError;
                return NO;
            }

            // Iterate through the events result set
            if ([result next]) {
                conversation = LYRConversationFromFMResultSet(result, database);
                if (!conversation) {
                    outError = database.lastError;
                    return NO;
                }
                [result close];
                [fetchedConversations addObject:conversation];
            }
        }
        conversations = fetchedConversations;
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to fetch conversation for identifier:%@ with %@", [[[[conversationIdentifiers valueForKeyPath:@"UUIDString"] description] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"    " withString:@""], outError);
        if (error) *error = outError;
    }
    return conversations;
}

- (NSString *)participantForDatabaseIdentifier:(LYRSequence)participantDatabaseIdentifier inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block NSString *participantIdentifier;
    LYRLogVerbose(@"fetching participant for participant database identifier: %d", (int)participantDatabaseIdentifier);
    [self attemptBlock:^BOOL{
        FMResultSet *result = [database executeQuery:
                               @"SELECT * FROM conversation_participants "
                               @"WHERE conversation_participants.database_identifier = ? LIMIT 1", @(participantDatabaseIdentifier)];
        if (!result) {
            outError = database.lastError;
            return NO;
        }

        // Iterate through the events result set
        if ([result next]) {
            NSString *participantIdentifier = [result stringForColumn:@"member_id"];
            if (!participantIdentifier) {
                outError = database.lastError;
                return NO;
            }
            [result close];
        }
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to fetch participant with %@", outError);
        if (error) *error = outError;
    }
    return participantIdentifier;
}

- (BOOL)persistAddParticipant:(NSString *)participant seq:(LYRSequence)seq date:(NSDate *)date conversationIdentifier:(NSUUID *)conversationIdentifier toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    LYRLogVerbose(@"persisting participant:%@ seq:%u date:%@ for the conversation:%@", participant, seq, date, conversationIdentifier.UUIDString);
    BOOL success = [self attemptBlock:^BOOL{
        BOOL success;
        FMResultSet *result = [database executeQuery:
                               @"SELECT conversations.database_identifier as conv_db_id, conversations.*, streams.database_identifier as strm_db_id, streams.*, stream_members.stream_database_identifier as strm_mbr_id FROM conversations "
                               @"LEFT JOIN streams ON (conversations.stream_database_identifier = streams.database_identifier) "
                               @"LEFT JOIN stream_members ON (conversations.stream_database_identifier = stream_members.stream_database_identifier) "
                               @"WHERE streams.stream_id = ? OR (streams.stream_id = ? AND stream_members.member_id = ?) LIMIT 1", LYRDataFromUUID(conversationIdentifier), LYRDataFromUUID(conversationIdentifier), participant];
        if (!result) { outError = database.lastError; return NO; }
        if (![result next]) {
            outError = [NSError errorWithDomain:LYRSynchronizationDataSourceErrorDomain code:LYRSynchronizationDataSourceErrorStreamDoesntExist userInfo:@{NSLocalizedDescriptionKey:@"Couldn't persist participant into an non-existing conversation.", @"conversationIdentifier":conversationIdentifier}];
            success = NO;
            return NO;
        }
        LYRSequence conversationDatabaseIdentifier = [result intForColumn:@"conv_db_id"];
        LYRSequence streamMemberDatabaseIdentifier = [result columnIsNull:@"strm_mbr_id"] ? LYRSequenceNotDefined : [result intForColumn:@"strm_mbr_id"];
        [result close];
        success = [database executeUpdate:@"INSERT OR IGNORE INTO conversation_participants (conversation_database_identifier, member_id, created_at, seq, stream_member_database_identifier) VALUES (?, ?, ?, ?, ?)", @(conversationDatabaseIdentifier), participant, date, @(seq), streamMemberDatabaseIdentifier == LYRSequenceNotDefined ? NULL : @(streamMemberDatabaseIdentifier)];
        if (!success) { outError = database.lastError; return NO; };
        // Skip the update on `conversation_participants`, if we had an INSERT
        if (![database changes]) {
            success = [database executeUpdate:@"UPDATE conversation_participants SET created_at = ?, deleted_at = NULL, seq = ? WHERE conversation_database_identifier = ? AND member_id = ?", date, @(seq), @(conversationDatabaseIdentifier), participant];
            if (!success) {
                outError = database.lastError;
                return NO;
            }
        }
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to persist participant:%@ for conversation:%@ date:%@ seq:%u", participant, conversationIdentifier.UUIDString, date, seq);
        if (error) *error = outError;
    }
    return success;
}

- (BOOL)persistRemoveParticipant:(NSString *)participant seq:(LYRSequence)seq date:(NSDate *)date conversationIdentifier:(NSUUID *)conversationIdentifier toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    LYRLogVerbose(@"marking participant:%@ as deleted on:%@ with seq:%u for the conversation:%@", participant, date, seq, conversationIdentifier.UUIDString);
    BOOL success = [self attemptBlock:^BOOL{
        BOOL success;
        FMResultSet *result = [database executeQuery:
                               @"SELECT conversations.database_identifier as conv_db_id, conversations.*, streams.database_identifier as strm_db_id, streams.* FROM conversations "
                               @"LEFT JOIN streams ON (conversations.stream_database_identifier = streams.database_identifier) "
                               @"WHERE streams.stream_id = ? LIMIT 1", LYRDataFromUUID(conversationIdentifier)];
        if (!result) {
            outError = database.lastError;
            return NO;
        }
        if (![result next]) {
            outError = [NSError errorWithDomain:LYRSynchronizationDataSourceErrorDomain code:LYRSynchronizationDataSourceErrorStreamDoesntExist userInfo:@{NSLocalizedDescriptionKey:@"Couldn't persist participant into an non-existing conversation.", @"conversationIdentifier":conversationIdentifier}];
            success = NO;
            return NO;;
        }
        LYRSequence conversationDatabaseIdentifier = [result intForColumn:@"conv_db_id"];
        [result close];
        success = [database executeUpdate:@"INSERT OR IGNORE INTO conversation_participants (conversation_database_identifier, member_id, deleted_at, seq) VALUES (?, ?, ?, ?)", @(conversationDatabaseIdentifier), participant, date, @(seq)];
        if (!success) {
            outError = database.lastError;
            return NO;
        }
        // Skip the update on `conversation_participants`, if we had an INSERT
        if (![database changes]) {
            success = [database executeUpdate:@"UPDATE conversation_participants SET deleted_at = ?, seq = ? WHERE conversation_database_identifier = ? AND member_id = ?", date, @(seq), @(conversationDatabaseIdentifier), participant];
            if (!success) {
                outError = database.lastError;
                return NO;
            }
        }
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to mark participant:%@ as deleted for conversation:%@ date:%@ seq:%u", participant, conversationIdentifier.UUIDString, date, seq);
        if (error) *error = outError;
    }
    return success;
}

#pragma mark - Syncable changes

- (NSSet *)syncableChangesInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block NSSet *syncableChanges;
    LYRLogVerbose(@"fetching syncable changes");
    [self attemptBlock:^BOOL{
        NSMutableSet *fetchedSyncableChanges = [NSMutableSet set];
        FMResultSet *result = [database executeQuery:@"SELECT * FROM syncable_changes"];
        if (!result) {
            outError = database.lastError;
            return NO;
        }
        // Iterate through the events result set
        while ([result next]) {
            // Add the mapped event object to the list
            LYRSyncableChange *syncableChange = [LYRSyncableChange syncableChangeWithChangeID:[result intForColumn:@"change_identifier"]
                                                                                    tableName:[result stringForColumn:@"TABLE_NAME"]
                                                                                        rowID:[result intForColumn:@"row_identifier"]
                                                                                   changeType:[result intForColumn:@"change_type"]
                                                                                   columnName:[result stringForColumn:@"column_name"]];
            [fetchedSyncableChanges addObject:syncableChange];
        }
        syncableChanges = [fetchedSyncableChanges copy];
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to fetch syncable changes with %@", outError);
        if (error) *error = outError;
    }
    return syncableChanges;
}

- (LYREvent *)eventFromParticipantSyncableChange:(LYRSyncableChange *)syncableChange inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block LYREvent *event;
    LYRLogVerbose(@"collecting participant info for syncable change:%@", syncableChange);
    [self attemptBlock:^BOOL{
        FMResultSet *result = [database executeQuery:
                               @"SELECT syncable_changes.*, conversation_participants.*, conversations.*, streams.*, streams.database_identifier AS streams_database_id FROM syncable_changes "
                               @"LEFT JOIN conversation_participants ON syncable_changes.row_identifier = conversation_participants.database_identifier "
                               @"LEFT JOIN conversations ON conversation_participants.conversation_database_identifier = conversations.database_identifier "
                               @"LEFT JOIN streams ON conversations.stream_database_identifier = streams.database_identifier "
                               @"WHERE change_identifier = ?", @(syncableChange.changeIdentifier)];
        if (!result) {
            outError = database.lastError;
            return NO;
        }
        if (![result next]) {
            // TODO: no results, throw an exception
            return NO;
        }
        if (![[result stringForColumn:@"table_name"] isEqualToString:LYRSyncableChangeTableNameConversationParticipants]) {
            // TODO: generate an error / exception over here!
            return NO;
        }
        event = [LYREvent eventWithDatabaseIdentifier:LYRSequenceNotDefined streamDatabaseIdentifier:[result columnIndexForName:@"stream_database_identifier"] messageDatabaseIdentifier:LYRSequenceNotDefined];
        if ([result intForColumn:@"change_type"] == LYRSyncableChangeTypeInsert) {
            event.type = EventType_MEMBER_ADDED;
        } else if ([result intForColumn:@"change_type"] == LYRSyncableChangeTypeDelete) {
            event.type = EventType_MEMBER_REMOVED;
        } else {
            // TODO: generate an error over here!
            event = nil;
            return NO;
        }
        event.stream_id = [result stringForColumn:@"stream_id"];
        event.member_id = [result stringForColumn:@"member_id"];
        event.streamDatabaseIdentifier = [result intForColumn:@"streams_database_id"];
        event.preceding_seq = [result columnIsNull:@"seq"] ? 0 : [result intForColumn:@"seq"];
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to collect participant info for syncable changes:%@ with %@", syncableChange, outError);
        if (error) *error = outError;
    }
    return event;
}

- (LYREvent *)eventFromMessageSyncableChange:(LYRSyncableChange *)syncableChange inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block LYREvent *event;
    LYRLogVerbose(@"collecting participant info for syncable change:%@", syncableChange);
    [self attemptBlock:^BOOL{
        FMResultSet *result = [database executeQuery:
                               @"SELECT syncable_changes.*, conversations.*, messages.*, messages.database_identifier AS message_database_ID, streams.*, streams.database_identifier AS streams_database_id FROM syncable_changes "
                               @"LEFT JOIN messages ON syncable_changes.row_identifier = messages.database_identifier "
                               @"LEFT JOIN conversations ON messages.conversation_database_identifier = conversations.database_identifier "
                               @"LEFT JOIN streams ON conversations.stream_database_identifier = streams.database_identifier "
                               @"WHERE change_identifier = ?", @(syncableChange.changeIdentifier)];
        if (!result) {
            outError = database.lastError;
            return NO;
        }
        if (![result next]) {
            // TODO: no results, throw an exception
            return NO;
        }
        if (![[result stringForColumn:@"table_name"] isEqualToString:LYRSyncableChangeTableNameMessages]) {
            // TODO: generate an error / exception over here!
            return NO;
        }
        LYRSequence messageDatabaseIdentifier = [result intForColumn:@"message_database_ID"];
        event = [LYREvent eventWithDatabaseIdentifier:LYRSequenceNotDefined streamDatabaseIdentifier:[result columnIndexForName:@"stream_database_identifier"] messageDatabaseIdentifier:messageDatabaseIdentifier];
        if ([result intForColumn:@"change_type"] == LYRSyncableChangeTypeInsert) {
            event.type = EventType_MESSAGE;
        } else {
            // TODO: generate an error over here!
            event = nil;
            return NO;
        }
        event.stream_id = [result dataForColumn:@"stream_id"];
        event.streamDatabaseIdentifier = [result intForColumn:@"streams_database_id"];
        event.preceding_seq = [result columnIsNull:@"seq"] ? 0 : [result intForColumn:@"seq"];
        
        FMResultSet *resultMessageParts = [database executeQuery:@"SELECT * FROM message_parts WHERE message_database_identifier = ?", @(messageDatabaseIdentifier)];
        if (!resultMessageParts) {
            outError = database.lastError;
            return NO;
        }

        NSMutableArray *contentTypes = [NSMutableArray array];
        NSMutableArray *contentParts = [NSMutableArray array];
        while ([resultMessageParts next]) {
            NSString *MIMEType = [resultMessageParts stringForColumn:@"mime_type"];
            NSData *content = [resultMessageParts dataForColumn:@"content"];
            [contentTypes addObject:MIMEType];
            [contentParts addObject:content];
        }
        event.content_types = contentTypes;
        event.inline_content_parts = contentParts;
        event.creator_id = [result stringForColumn:@"user_id"];
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to collect participant info for syncable changes:%@ with %@", syncableChange, outError);
        if (error) *error = outError;
    }
    return event;
}

- (BOOL)deleteAllSyncableChangesInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block BOOL success = NO;
    LYRLogVerbose(@"deleting all the syncable changes");
    [self attemptBlock:^BOOL{
        // Delete all the syncable changes
        success = [database executeUpdate:@"DELETE FROM syncable_changes"];
        if (!success) {
            outError = database.lastError;
            return NO;
        }
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to delete all syncable changes");
        if (error) *error = outError;
    }
    return success;
}

- (BOOL)deleteSyncableChanges:(NSSet *)syncableChanges inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block BOOL success = NO;
    LYRLogVerbose(@"deleting syncable changes: %@", syncableChanges);
    [self attemptBlock:^BOOL{
        for (LYRSyncableChange *syncableChange in syncableChanges) {
            success = [database executeUpdate:@"DELETE FROM syncable_changes WHERE change_identifier = ?", @(syncableChange.changeIdentifier)];
            if (!success) {
                outError = database.lastError;
                return NO;
            }
        }
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to delete syncable changes:%@ with %@", syncableChanges, outError);
        if (error) *error = outError;
    }
    return success;
}

#pragma mark - Messages

- (BOOL)persistMessage:(LYRMessage *)message toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block BOOL success;
    LYRLogVerbose(@"persisting message: %@", message);
    [self attemptBlock:^BOOL{
        // First, check if there's conversation information available
        if (!message.conversation) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Could not persist message with an undefined conversation database identifier." userInfo:nil];
        }
        else if (message.conversation && (message.conversation.databaseIdentifier == LYRSequenceNotDefined)) {
            // Persist conversation if it doesn't exist yet in the database
            success = [self persistConversations:[NSSet setWithObject:message.conversation] toDatabase:database error:&outError];
            if (!success) {
                if (error) *error = outError;
                return NO;
            }
        }
        // Persist message
        success = [database executeUpdate:@"INSERT OR IGNORE INTO messages (database_identifier, sent_at, created_at, deleted_at, received_at, user_id, seq, conversation_database_identifier, event_database_identifier) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", message.databaseIdentifier != LYRSequenceNotDefined ? @(message.databaseIdentifier) : nil, message.sentAt, message.createdAt, nil, message.receivedAt, message.sentByUserID, message.seq != LYRSequenceNotDefined ? @(message.seq) : nil, @(message.conversation.databaseIdentifier), message.eventDatabaseIdentifier != LYRSequenceNotDefined ? @(message.eventDatabaseIdentifier) : nil];
        if (!success) {
            outError = database.lastError;
            return NO;
        }
        
        // Skip the update, if we had an INSERT
        if (![database changes]) {
            if (message.databaseIdentifier == LYRSequenceNotDefined) @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Tried to persist an existing message without database identifier!" userInfo:nil];
            success = [database executeUpdate:@"UPDATE messages SET sent_at = ?, deleted_at = ?, received_at = ?, received_at = ?, user_id = ?, seq = ?, conversation_database_identifier = ?, event_database_identifier = ? WHERE database_identifier = ?", message.sentAt, message.deletedAt, message.receivedAt, message.sentByUserID, message.seq != LYRSequenceNotDefined ? @(message.seq) : nil, @(message.conversation.databaseIdentifier), message.eventDatabaseIdentifier != LYRSequenceNotDefined ? @(message.eventDatabaseIdentifier) : nil, @(message.databaseIdentifier)];
            if (!success) {
                outError = database.lastError;
                return NO;
            }
        }
        
        message.databaseIdentifier = message.databaseIdentifier == LYRSequenceNotDefined ? (LYRSequence)[database lastInsertRowId] : message.databaseIdentifier;

        // Persist message parts
        for (LYRMessagePart *messagePart in message.parts) {
            success = [database executeUpdate:@"INSERT OR IGNORE INTO message_parts (database_identifier, message_database_identifier, mime_type, content, url) VALUES (?, ?, ?, ?, ?)", messagePart.databaseIdentifier != LYRSequenceNotDefined ? @(messagePart.databaseIdentifier) : nil, @(message.databaseIdentifier), messagePart.MIMEType, messagePart.data, nil];
            if (!success) {
                outError = database.lastError;
                return NO;
            }

            messagePart.databaseIdentifier = messagePart.databaseIdentifier == LYRSequenceNotDefined ? (LYRSequence)[database lastInsertRowId] : messagePart.databaseIdentifier;

            // Skip the update, if we had an INSERT
            if (![database changes]) {
                success = [database executeUpdate:@"UPDATE message_parts SET message_database_identifier = ?, mime_type = ?, content = ?, url = ? WHERE database_identifier = ?", @(message.databaseIdentifier), messagePart.MIMEType, messagePart.data, nil, @(messagePart.databaseIdentifier)];
                if (!success) {
                    outError = database.lastError;
                    return NO;
                }
            }
        }

        return YES;
    }];
    if (!success) {
        if (error) *error = outError;
        LYRLogError(@"Failed persisting message %@: %@", message, outError);
    }
    return success;
}

- (BOOL)persistMessageEventDatabaseIdentifier:(LYRSequence)eventDatabaseIdentifier forMessageDatabaseIdentifier:(LYRSequence)messageDatabaseIdentifier toDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block BOOL success;
    LYRLogVerbose(@"persisting event database identifier:%d to message with database identifier:%d", eventDatabaseIdentifier, messageDatabaseIdentifier);
    [self attemptBlock:^BOOL{
        // First, check if there's conversation information available
        if (eventDatabaseIdentifier == LYRSequenceNotDefined) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Could not persist event database identifier to message with undefined eventDatabaseIdentifier." userInfo:nil];
        } else if (messageDatabaseIdentifier == LYRSequenceNotDefined) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Could not persist event database identifier to message with undefined messageDatabaseIdentifier." userInfo:nil];
        }
        
        success = [database executeUpdate:@"UPDATE messages SET event_database_identifier = ? WHERE database_identifier = ?", @(eventDatabaseIdentifier), @(messageDatabaseIdentifier)];
        if (!success) {
            outError = database.lastError;
            return NO;
        }
        return YES;
    }];
    if (!success) {
        if (error) *error = outError;
        LYRLogError(@"Failed persisting event database identifier:%d to message with database identifier:%d with %@", eventDatabaseIdentifier, messageDatabaseIdentifier, outError);
    }
    return success;
}

- (NSOrderedSet *)messagesForConversation:(LYRConversation *)conversation inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block NSMutableOrderedSet *messages;
    LYRLogVerbose(@"collecting messages for conversation:%d:%@", (int)conversation.databaseIdentifier, conversation.identifier.UUIDString);
    [self attemptBlock:^BOOL{
        FMResultSet *resultSet = [database executeQuery:
                                  @"SELECT messages.*, message_index.conversation_database_identifier AS conv_db_id FROM messages "
                                  @"JOIN message_index ON messages.database_identifier = message_index.message_database_identifier "
                                  @"WHERE messages.conversation_database_identifier = ? ORDER BY message_index.rowId", @(conversation.databaseIdentifier)];
        if (!resultSet) {
            outError = database.lastError;
            return NO;
        }

        messages = [NSMutableOrderedSet orderedSet];
        while ([resultSet next]) {
            // Map event's root level properties
            LYRSequence databaseIdentifier = [resultSet intForColumn:@"database_identifier"];

            // Create a new instance of LYREvent
            LYRMessage *message = [[LYRMessage alloc] initWithDatabaseIdentifier:databaseIdentifier];
            message.sentAt = [resultSet dateForColumn:@"sent_at"];
            message.createdAt = [resultSet dateForColumn:@"created_at"];
            message.deletedAt = [resultSet dateForColumn:@"deleted_at"];
            message.receivedAt = [resultSet dateForColumn:@"received_at"];
            message.sentByUserID = [resultSet stringForColumn:@"user_id"];
            message.seq = [resultSet columnIsNull:@"seq"] ? LYRSequenceNotDefined : [resultSet intForColumn:@"seq"];
            message.conversation = conversation;
            message.eventDatabaseIdentifier = [resultSet columnIsNull:@"event_database_identifier"] ? LYRSequenceNotDefined : [resultSet intForColumn:@"event_database_identifier"];

            // Map event's metadata keys / values
            FMResultSet *resultMessageParts = [database executeQuery:@"SELECT * FROM message_parts WHERE message_database_identifier = ?", @(message.databaseIdentifier)];
            if (!resultMessageParts) {
                outError = database.lastError;
                return NO;
            }

            NSMutableArray *messageParts = [NSMutableArray array];
            while ([resultMessageParts next]) {
                NSString *MIMEType = [resultMessageParts stringForColumn:@"mime_type"];
                NSData *content = [resultMessageParts dataForColumn:@"content"];
                LYRMessagePart *messagePart = [LYRMessagePart messagePartWithMIMEType:MIMEType data:content];
                messagePart.databaseIdentifier = [resultMessageParts intForColumn:@"database_identifier"];
                [messageParts addObject:messagePart];
            }
            message.parts = [messageParts copy];
            [messages addObject:message];
        }
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to collect messages for conversation:%d:%@ with %@", (int)conversation.databaseIdentifier, conversation.identifier.UUIDString, outError);
        if (error) *error = outError;
    }
    return messages;
}

- (BOOL)reindexConversation:(LYRConversation *)conversation inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block BOOL success;
    LYRLogVerbose(@"reindexing message order for conversation: %@", conversation);
    [self attemptBlock:^BOOL{
        // Delete all of the old index rows for the given conversation
        success = [database executeUpdate:@"DELETE FROM message_index WHERE conversation_database_identifier = ?", @(conversation.databaseIdentifier)];
        if (!success) {
            outError = database.lastError;
            return NO;
        }
        
        // Insert new index rows based on the message order defined by events.
        // row_id will guarantee the order of messages since it's auto-incremented per insert.
        success = [database executeUpdate:
                   @"INSERT INTO message_index (conversation_database_identifier, message_database_identifier) "
                   @"SELECT messages.conversation_database_identifier, messages.database_identifier "
                   @"FROM events JOIN messages ON events.database_identifier = messages.event_database_identifier "
                   @"WHERE messages.conversation_database_identifier = ? "
                   @"ORDER BY events.preceding_seq, events.client_seq, events.creator_id", @(conversation.databaseIdentifier)];
        if (!success) {
            outError = database.lastError;
            return NO;
        }
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to reindex message order for conversation: %@", conversation, outError);
        if (error) *error = outError;
    }
    return success;
}

- (BOOL)addMessageOrderIndexForMessage:(LYRMessage *)message inDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block BOOL success;
    LYRLogVerbose(@"adding a message order index for message: %@", message);
    [self attemptBlock:^BOOL{
        // Insert new index row for the given message
        success = [database executeUpdate:@"INSERT INTO message_index (conversation_database_identifier, message_database_identifier) VALUES (?, ?)", @(message.conversation.databaseIdentifier), @(message.databaseIdentifier)];
        if (!success) {
            outError = database.lastError;
            return NO;
        }
        return YES;
    }];
    if (outError) {
        LYRLogError(@"failed to add message order index for message: %@", message, outError);
        if (error) *error = outError;
    }
    return success;
}

#pragma mark - Deprecated methods

- (BOOL)presistLatestSequence:(LYRSequence)latestSequenceNumber forStreamIdentifier:(NSUUID *)streamIdentifier error:(out NSError *__autoreleasing *)error
{
    __block NSError *outError;
    __block BOOL success = NO;
    LYRLogVerbose(@"persist latestSequence:%u for streamUUID:%@", latestSequenceNumber, streamIdentifier.UUIDString);
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        success = [db executeUpdate:@"UPDATE streams SET seq = ? WHERE stream_id = ?", @(latestSequenceNumber), LYRDataFromUUID(streamIdentifier)];
        if (!success) {
            outError = db.lastError;
            *rollback = YES;
            return;
        }

        // Skip the update, if we had an INSERT
        if (![db changes]) {
            success = NO;
            outError = [NSError errorWithDomain:LYRSynchronizationDataSourceErrorDomain code:LYRSynchronizationDataSourceErrorStreamDoesntExist userInfo:@{NSLocalizedDescriptionKey:@"Couldn't persist the latest sequence number for the given stream",@"streamUUID":streamIdentifier}];
            return;
        }
    }];
    if (outError) {
        LYRLogError(@"failed to persist latestSequence:%u for streamUUID:%@ with %@", latestSequenceNumber, streamIdentifier.UUIDString, outError);
        if (error) *error = outError;
    }
    return success;
}

- (BOOL)latestSequence:(out LYRSequence *)latestSequenceNumber forStreamIndentifier:(NSUUID *)streamIdentifier error:(out NSError *__autoreleasing *)error;
{
    __block NSError *outError;
    __block BOOL success = NO;
    LYRLogVerbose(@"fetching latestSequence for streamUUID:%@", streamIdentifier);
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM streams WHERE stream_id = ? LIMIT 1", LYRDataFromUUID(streamIdentifier)];
        if (!result) {
            outError = db.lastError;
            return;
        }
        if ([result next]) {
            LYRSequence fetchedLatestSequence = [result intForColumn:@"seq"];
            if (latestSequenceNumber) *latestSequenceNumber = fetchedLatestSequence;
            success = YES;
        } else {
            success = NO;
        }
    }];
    if (outError) {
        LYRLogError(@"failed to fetch latestSequence for streamUUID:%@ with %@", streamIdentifier, outError);
        if (error) *error = outError;
    }
    return success;
}

@end
