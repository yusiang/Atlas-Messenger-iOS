//
//  LYREvent.m
//  LayerKit
//
//  Created by Klemen Verdnik on 28/04/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYREvent.h"
#import <TMemoryBuffer.h>
#import "TCompactProtocol.h"
#import "LYRUUIDData.h"

@interface LYREvent ()

@property (nonatomic) LYRSequence databaseIdentifier;
@property (nonatomic) LYRSequence streamDatabaseIdentifier;
@property (nonatomic) LYRSequence messageDatabaseIdentifier;
@property (nonatomic, strong, readwrite) NSUUID *streamUUID;

@end

@implementation LYREvent

- (id)init
{
    self = [super init];
    if (self) {
        self.databaseIdentifier = LYRSequenceNotDefined;
        self.streamDatabaseIdentifier = LYRSequenceNotDefined;
        self.messageDatabaseIdentifier = LYRSequenceNotDefined;
    }
    return self;
}

- (id)initWithThriftEvent:(LYRTEvent *)thriftEvent
{
    self = [super init];
    if (self) {
        // Serialize current object's data
        TMemoryBuffer *buffer = [[TMemoryBuffer alloc] init];
        TCompactProtocol *protocol = [[TCompactProtocol alloc] initWithTransport:buffer strictRead:NO strictWrite:YES];
        [thriftEvent write:protocol];

        // Deserialize previously serialized data into a new instance
        [self read:protocol];
        self.databaseIdentifier = LYRSequenceNotDefined;
        self.streamDatabaseIdentifier = LYRSequenceNotDefined;
        self.messageDatabaseIdentifier = LYRSequenceNotDefined;
    }
    return self;
}

- (id)initWithDatabaseIdentifier:(LYRSequence)databaseIdentifier streamDatabaseIdentifier:(LYRSequence)streamDatabaseIdentifier messageDatabaseIdentifier:(LYRSequence)messageDatabaseIdentifier
{
    self = [super init];
    if (self) {
        self.databaseIdentifier = databaseIdentifier;
        self.streamDatabaseIdentifier = streamDatabaseIdentifier;
        self.messageDatabaseIdentifier = messageDatabaseIdentifier;
    }
    return self;
}

+ (id)eventWithThriftEvent:(LYRTEvent *)thriftEvent
{
    return [[self alloc] initWithThriftEvent:thriftEvent];
}

+ (id)eventWithDatabaseIdentifier:(LYRSequence)databaseIdentifier streamDatabaseIdentifier:(LYRSequence)streamDatabaseIdentifier messageDatabaseIdentifier:(LYRSequence)messageDatabaseIdentifier
{
    return [[self alloc] initWithDatabaseIdentifier:databaseIdentifier streamDatabaseIdentifier:streamDatabaseIdentifier messageDatabaseIdentifier:(LYRSequence)messageDatabaseIdentifier];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithThriftEvent:self];
}

- (void)setStream_id:(NSData *)stream_id
{
    _stream_id = stream_id;
    _streamUUID = LYRUUIDFromData(stream_id);
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[LYRTEvent class]]) return NO;
    if (self == object) return YES;

    LYREvent *obj = object;

    BOOL isTypeEqual = self.type == obj.type;
    BOOL isCreatorIDEqual = self.creator_id == obj.creator_id || [self.creator_id isEqual:obj.creator_id];
    BOOL isServerSequenceEqual = self.seq == obj.seq;
    BOOL isServerTimestampEqual = self.timestamp == obj.timestamp;
    BOOL isPrecedingServerSequenceEqual = self.preceding_seq == obj.preceding_seq;
    BOOL isClientSequenceEqual = self.client_seq == obj.client_seq;
    BOOL isSubtypeEqual = self.subtype == obj.subtype;
    BOOL isMetadataEqual = self.metadata == obj.metadata || [self.metadata isEqualToDictionary:obj.metadata];
    BOOL isContentTypesEqual = self.content_types == obj.content_types || [self.content_types isEqualToArray:obj.content_types];
    BOOL isInlineContentTypesEqual = self.inline_content_parts == obj.inline_content_parts || [self.inline_content_parts isEqualToArray:obj.inline_content_parts];
    BOOL isExternalIdEqual = self.external_content_id == obj.external_content_id || [self.external_content_id isEqualToData:obj.external_content_id];
    BOOL isMemberIdEqual = self.member_id == obj.member_id || [self.member_id isEqual:obj.member_id];
    BOOL isMessageEventServerSequenceEqual = self.target_seq == obj.target_seq;
    BOOL isMessageDatabaseIdentifierEqual = self.messageDatabaseIdentifier == obj.messageDatabaseIdentifier;
    BOOL isStreamIdEqual = self.stream_id == obj.stream_id || [self.stream_id isEqualToData:obj.stream_id];

    return isTypeEqual &&
           isCreatorIDEqual &&
           isServerSequenceEqual &&
           isServerTimestampEqual &&
           isPrecedingServerSequenceEqual &&
           isClientSequenceEqual &&
           isSubtypeEqual &&
           isMetadataEqual &&
           isContentTypesEqual &&
           isInlineContentTypesEqual &&
           isExternalIdEqual &&
           isMemberIdEqual &&
           isMessageEventServerSequenceEqual &&
           isMessageDatabaseIdentifierEqual &&
           isStreamIdEqual;
}

- (NSUInteger)hash
{
    if (self.databaseIdentifier != LYRSequenceNotDefined) return (NSUInteger)self.databaseIdentifier;
    NSUInteger metadataHash = (NSUInteger)self.metadata;
    NSUInteger contentTypesHash = (NSUInteger)self.content_types;
    NSUInteger inlineContentPartsHash = (NSUInteger)self.inline_content_parts;
    return (NSUInteger)self.type ^ self.creator_id.hash ^ (NSUInteger)self.seq ^ (NSUInteger)self.timestamp ^ (NSUInteger)self.preceding_seq ^ (NSUInteger)self.client_seq ^ self.subtype ^ metadataHash ^ contentTypesHash ^ inlineContentPartsHash ^ self.external_content_id.hash ^ self.member_id.hash ^ (NSUInteger)self.target_seq ^ (NSUInteger)self.messageDatabaseIdentifier ^ self.stream_id.hash;
}

@end
