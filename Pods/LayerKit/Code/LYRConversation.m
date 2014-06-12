//
//  LYRConversation.m
//  LayerKit
//
//  Created by Klemen Verdnik on 06/05/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRConversation.h"

@interface LYRConversation ()

@property (nonatomic) NSUUID *identifier;
@property (nonatomic) NSSet *participants;
@property (nonatomic) NSDictionary *metadata;
@property (nonatomic) NSDate *createdAt;

/**
 @abstract The immutable database identifier (primary key in the local persistence store).
 */
@property (nonatomic) LYRSequence databaseIdentifier;

/**
 @abstract The immutable stream database identifier (foreign key for the `streamDatabaseIdentifier`).
 */
@property (nonatomic) LYRSequence streamDatabaseIdentifier;

+ (id)conversationWithIdentifier:(NSUUID *)identifier participants:(NSSet *)participants;

@end

@implementation LYRConversation

- (id)init
{
    self = [super init];
    if (self) {
        self.databaseIdentifier = LYRSequenceNotDefined;
        self.streamDatabaseIdentifier = LYRSequenceNotDefined;
    }
    return self;
}

- (id)initWithIdentifier:(NSUUID *)identifier participants:(NSSet *)participants
{
    self = [self init];
    if (self) {
        for (NSString *participant in participants) {
            if (![participant isKindOfClass:[NSString class]]) {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Failed to initialize %@ because of an improper type %@ for participant.", [self class], [participant class]] userInfo:nil];
            }
        }
        self.identifier = identifier;
        self.participants = participants;
    }
    return self;
}

+ (id)conversationWithIdentifier:(NSUUID *)identifier participants:(NSSet *)participants
{
    return [[[self class] alloc] initWithIdentifier:identifier participants:participants];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[LYRConversation class]]) return NO;
    if (self == object) return YES;

    LYRConversation *obj = object;

    BOOL isIdentifierEqual = self.identifier == obj.identifier || [self.identifier isEqual:obj.identifier];
    BOOL isParticipantsEqual = self.participants == obj.participants || [self.participants isEqualToSet:obj.participants];
    BOOL isMetadataEqual = self.metadata == obj.metadata || [self.metadata isEqualToDictionary:obj.metadata];
    BOOL isDatabaseIdentifierEqual = self.databaseIdentifier == obj.databaseIdentifier;
    BOOL isStreamDatabaseIdentifierEqual = self.streamDatabaseIdentifier == obj.streamDatabaseIdentifier;
    BOOL isCreatedAtEqual = self.createdAt == obj.createdAt || [self.createdAt isEqualToDate:obj.createdAt];

    return isIdentifierEqual &&
           isParticipantsEqual &&
           isMetadataEqual &&
           isDatabaseIdentifierEqual &&
           isStreamDatabaseIdentifierEqual &&
           isCreatedAtEqual;
}

- (NSUInteger)hash
{
    NSUInteger participantsHash = 0;
    NSUInteger metadataHash = 0;
    for (NSUUID *participant in self.participants) participantsHash ^= participant.hash;
    for (id key in self.metadata) metadataHash ^= [key hash] ^ [[self.metadata objectForKey:key] hash];
    return self.identifier.hash ^ participantsHash ^ metadataHash ^ (NSUInteger)self.databaseIdentifier ^ (NSUInteger)self.streamDatabaseIdentifier ^ self.createdAt.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p databaseIdentifier=%d identifier=%@ participants=%@>", [self class], self, self.databaseIdentifier, [self.identifier UUIDString], self.participants];
}

@end
