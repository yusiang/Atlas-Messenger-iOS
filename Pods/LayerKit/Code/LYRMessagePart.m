//
//  LYRMessagePart.m
//  LayerKit
//
//  Created by Blake Watters on 5/8/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRMessagePart.h"

NSString *const LYRMIMETypeTextPlain = @"text/plain";
NSString *const LYRMIMETypeTextHTML  = @"text/html";
NSString *const LYRMIMETypeImagePNG  = @"image/png";

@interface LYRMessagePart ()
@property (nonatomic) LYRSequence databaseIdentifier;
@end

@implementation LYRMessagePart

+ (instancetype)messagePartWithMIMEType:(NSString *)MIMEType data:(NSData *)data
{
    return [[self alloc] initWithMIMEType:MIMEType data:data];
}

+ (instancetype)messagePartWithMIMEType:(NSString *)MIMEType stream:(NSInputStream *)stream
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Not yet implemented." userInfo:nil];
}

+ (instancetype)messagePartWithText:(NSString *)text
{
    return [[self alloc] initWithMIMEType:LYRMIMETypeTextPlain data:[text dataUsingEncoding:NSUTF8StringEncoding]];
}

- (id)initWithMIMEType:(NSString *)MIMEType data:(NSData *)data
{
    self = [super init];
    if (self) {
        _MIMEType = MIMEType;
        _data = data;
        _databaseIdentifier = LYRSequenceNotDefined;
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}

- (NSInputStream *)inputStream
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Not yet implemented." userInfo:nil];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[LYRMessagePart class]]) return NO;
    if (self == object) return YES;

    LYRMessagePart *obj = object;

    BOOL isDatabaseIdentifierEqual = self.databaseIdentifier == obj.databaseIdentifier;
    BOOL isMIMETypeEqual = self.MIMEType == obj.MIMEType || [self.MIMEType isEqual:obj.MIMEType];
    BOOL isDataEqual = self.data == obj.data || [self.data isEqual:obj.data];

    return isDatabaseIdentifierEqual &&
           isMIMETypeEqual &&
           isDataEqual;
}

- (NSUInteger)hash
{
    return (NSUInteger)self.databaseIdentifier ^ self.MIMEType.hash ^ self.data.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p MIMEType=%@ size=%uld", [self class], self, self.MIMEType, [self.data length]];
}

@end
