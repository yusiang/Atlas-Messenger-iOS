//
//  LYRStream.m
//  LayerKit
//
//  Created by Klemen Verdnik on 28/04/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRStream.h"
#import <TMemoryBuffer.h>
#import "TCompactProtocol.h"
#import <CommonCrypto/CommonDigest.h>
#import "LYRUUIDData.h"

@interface LYRStream ()

@property (nonatomic) LYRSequence databaseIdentifier;

/**
 @abstract Initializes the new subclassed instance of `LYRTStream` (Thrift generated object)

 @param databaseIdentifier The value that's going to be assigned to the `databaseIdentifier` property.
 @return An initialized instance of `LYRStream` object.
 */
- (id)initWithDatabaseIdentifier:(LYRSequence)databaseIdentifier;

@end

@implementation LYRStream

+ (id)stream
{
    return [[self alloc] initWithMembers:nil];
}

+ (id)streamWithMembers:(NSSet *)members
{
    return [[self alloc] initWithMembers:members];
}

- (id)initWithMembers:(NSSet *)members
{
    self = [super init];
    if (self) {
        self.member_ids = members;
        self.databaseIdentifier = LYRSequenceNotDefined;
    }
    return self;
}

+ (instancetype)streamWithThriftStream:(LYRTStream *)stream
{
    return [[self alloc] initWithThriftStream:stream];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.databaseIdentifier = LYRSequenceNotDefined;
    }
    return self;
}

- (id)initWithDatabaseIdentifier:(LYRSequence)databaseIdentifier
{
    self = [super init];
    if (self) {
        self.databaseIdentifier = (LYRSequence)databaseIdentifier;
    }
    return self;
}

- (id)initWithThriftStream:(LYRTStream *)thriftStream
{
    self = [super init];
    if (self) {
        // Serialize current object's data
        TMemoryBuffer *buffer = [[TMemoryBuffer alloc] init];
        TCompactProtocol *protocol = [[TCompactProtocol alloc] initWithTransport:buffer strictRead:NO strictWrite:YES];
        [thriftStream write:protocol];

        // Deserialize previously serialized data into a new instance
        self = [super init];
        [self read:protocol];
        self.databaseIdentifier = LYRSequenceNotDefined;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithThriftStream:self];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[LYRTStream class]]) return NO;
    if (self == object) return YES;

    LYRStream *obj = object;

    BOOL isStreamIDEqual = self.stream_id == obj.stream_id || [self.stream_id isEqualToData:obj.stream_id];
    BOOL isMemberIDsEqual = self.member_ids == obj.member_ids || [self.member_ids isEqualToSet:obj.member_ids];
    BOOL isDatabaseIdentifierEqual = self.databaseIdentifier == obj.databaseIdentifier;
    BOOL isLatestSequenceEqual = self.seq == obj.seq;

    return isStreamIDEqual &&
           isMemberIDsEqual &&
           isDatabaseIdentifierEqual &&
           isLatestSequenceEqual;
}

- (void)setStream_id:(LYRTUUID)stream_id
{
    [super setStream_id:stream_id];
    _streamUUID = stream_id ? LYRUUIDFromData(stream_id) : nil;
}

- (NSUInteger)hash
{
    NSUInteger memberIDsHash = 0;
    for (NSString *memberID in self.member_ids) memberIDsHash ^= memberID.hash;
    return self.stream_id.hash ^ memberIDsHash ^ (NSUInteger)self.seq ^ (NSUInteger)self.databaseIdentifier;
}

@end
