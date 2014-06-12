//
//  LYRMessage.m
//  LayerKit
//
//  Created by Blake Watters on 5/8/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRMessage.h"
#import "LYRSynchronizationDataSource.h"
#import "LYRMessagePart.h"

@interface LYRMessage ()

@property (nonatomic, readwrite) LYRConversation *conversation;
@property (nonatomic, readwrite) NSArray *parts;
@property (nonatomic, readwrite) NSDictionary *metadata;
@property (nonatomic, readwrite) NSDictionary *userInfo;
@property (nonatomic, readwrite) NSDate *createdAt;
@property (nonatomic, readwrite) NSDate *sentAt;
@property (nonatomic, readwrite) NSDate *receivedAt;
@property (nonatomic, readwrite) NSDate *deletedAt;
@property (nonatomic, readwrite) NSString *sentByUserID;
@property (nonatomic, readwrite) NSDictionary *recipientStatesByUserID;
@property (nonatomic) LYRSequence seq;
@property (nonatomic) LYRSequence eventDatabaseIdentifier;
@property (nonatomic) LYRSequence databaseIdentifier;

+ (id)messageWithDatabaseIdentifier:(LYRSequence)databaseIdentifier;

@end

@implementation LYRMessage

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}

- (id)initWithDatabaseIdentifier:(LYRSequence)databaseIdentifier;
{
    self = [super init];
    if (self) {
        _databaseIdentifier = databaseIdentifier;
        _createdAt = [NSDate date];
        _seq = LYRSequenceNotDefined;
        _eventDatabaseIdentifier = LYRSequenceNotDefined;
    }
    return self;
}

+ (id)messageWithDatabaseIdentifier:(LYRSequence)databaseIdentifier
{
    return [[LYRMessage alloc] initWithDatabaseIdentifier:databaseIdentifier];
}

- (LYRMessageState)stateForUserID:(NSString *)userID
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not yet implemented." userInfo:nil];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[LYRMessage class]]) return NO;
    if (self == object) return YES;

    LYRMessage *obj = object;

    BOOL isConversationEqual = self.conversation == obj.conversation || [self.conversation isEqual:obj.conversation];
    BOOL isPartsEqual = self.parts == obj.parts || [self.parts isEqualToArray:obj.parts];
    BOOL isMetadataEqual = self.metadata == obj.metadata || [self.metadata isEqualToDictionary:obj.metadata];
    BOOL isUserInfoEqual = self.userInfo == obj.userInfo || [self.userInfo isEqualToDictionary:obj.userInfo];
    BOOL isCreatedAtEqual = self.createdAt == obj.createdAt || self.createdAt.timeIntervalSince1970 == obj.createdAt.timeIntervalSince1970;
    BOOL isSentAtEqual = self.sentAt == obj.sentAt || self.sentAt.timeIntervalSince1970 == obj.sentAt.timeIntervalSince1970;
    BOOL isReceivedAtEqual = self.receivedAt == obj.receivedAt || self.receivedAt.timeIntervalSince1970 == obj.receivedAt.timeIntervalSince1970;
    BOOL isDeletedAtEqual = self.deletedAt == obj.deletedAt || self.deletedAt.timeIntervalSince1970 == obj.deletedAt.timeIntervalSince1970;
    BOOL isSentByUserIDEqual = self.sentByUserID == obj.sentByUserID || [self.sentByUserID isEqual:obj.sentByUserID];
    BOOL isRecipientStatesByUserIDEqual = self.recipientStatesByUserID == obj.recipientStatesByUserID || [self.recipientStatesByUserID isEqualToDictionary:obj.recipientStatesByUserID];
    BOOL isSeqEqual = self.seq == obj.seq;
    BOOL isEventDatabaseIdentifierEqual = self.eventDatabaseIdentifier == obj.eventDatabaseIdentifier;
    BOOL isDatabaseIdentifierEqual = self.databaseIdentifier == obj.databaseIdentifier;

    return isConversationEqual &&
           isPartsEqual &&
           isMetadataEqual &&
           isUserInfoEqual &&
           isCreatedAtEqual &&
           isSentAtEqual &&
           isReceivedAtEqual &&
           isDeletedAtEqual &&
           isSentByUserIDEqual &&
           isSeqEqual &&
           isEventDatabaseIdentifierEqual &&
           isRecipientStatesByUserIDEqual &&
           isDatabaseIdentifierEqual;
}

- (NSUInteger)hash
{
    NSUInteger partsHash = 0;
    NSUInteger metadataHash = 0;
    NSUInteger userInfoHash = 0;
    NSUInteger recipientStateHash = 0;
    for (LYRMessagePart *part in self.parts) partsHash ^= part.hash;
    for (id key in self.metadata) metadataHash ^= [key hash] ^ [[self.metadata objectForKey:key] hash];
    for (id key in self.userInfo) userInfoHash ^= [key hash] ^ [[self.userInfo objectForKey:key] hash];
    for (id key in self.recipientStatesByUserID) recipientStateHash ^= [key hash] ^ [[self.recipientStatesByUserID objectForKey:key] hash];
    return self.conversation.hash ^ partsHash ^ metadataHash ^ userInfoHash ^ self.createdAt.hash ^ self.sentAt.hash ^ self.receivedAt.hash ^ self.deletedAt.hash ^ self.sentByUserID.hash ^ recipientStateHash ^ (NSUInteger)self.seq ^ (NSUInteger)self.eventDatabaseIdentifier ^ (NSUInteger)self.databaseIdentifier;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p databaseIdentifier=%d seq=%d parts=%@ conversation=%@>", [self class], self, self.databaseIdentifier, self.seq, self.parts, self.conversation];
}

@end
