//
//  LYRSession.m
//  LayerKit
//
//  Created by Blake Watters on 4/8/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRSession.h"

@implementation LYRSession

+ (instancetype)sessionWithToken:(NSString *)token TTL:(NSInteger)TTLValue layerUserID:(NSUUID *)layerUserID providerUserID:(NSString *)providerUserID appID:(NSUUID *)appID
{
    return [[self alloc] initWithToken:token TTL:TTLValue layerUserID:layerUserID providerUserID:providerUserID appID:appID];
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer: Call `initWithAccessToken:TTL:layerUserID:providerUserID:appID:` instead." userInfo:nil];
}

- (id)initWithToken:(NSString *)token TTL:(NSInteger)TTLValue layerUserID:(NSUUID *)layerUserID providerUserID:(NSString *)providerUserID appID:(NSUUID *)appID
{
    if (!token) [NSException raise:NSInternalInconsistencyException format:@"Cannot initialize with a `nil` token."];
    if (TTLValue == 0) [NSException raise:NSInternalInconsistencyException format:@"Cannot initialize with a `TTL` set to zero."];
    if (!layerUserID) [NSException raise:NSInternalInconsistencyException format:@"Cannot initialize with a `nil` layerUserID."];
    if (!providerUserID) [NSException raise:NSInternalInconsistencyException format:@"Cannot initialize with a `nil` providerUserID."];
    if (!appID) [NSException raise:NSInternalInconsistencyException format:@"Cannot initialize with a `nil` appID."];
    self = [super init];
    if (self) {
        _appID = appID;
        _layerUserID = layerUserID;
        _providerUserID = providerUserID;
        _token = token;
        _expirationDate = [NSDate dateWithTimeInterval:TTLValue sinceDate:NSDate.date];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_appID forKey:@"appID"];
    [encoder encodeObject:_layerUserID forKey:@"layerUserID"];
    [encoder encodeObject:_providerUserID forKey:@"providerUserID"];
    [encoder encodeObject:_token forKey:@"token"];
    [encoder encodeObject:_expirationDate forKey:@"expirationDate"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        _appID = [decoder decodeObjectForKey:@"appID"];
        _layerUserID = [decoder decodeObjectForKey:@"layerUserID"];
        _providerUserID = [decoder decodeObjectForKey:@"providerUserID"];
        _token = [decoder decodeObjectForKey:@"token"];
        _expirationDate = [decoder decodeObjectForKey:@"expirationDate"];
    }
    return self;
}

- (BOOL)isExpired
{
    return [self.expirationDate timeIntervalSinceNow] < 0;
}

@end
