//
//  LYRIdentityToken.m
//  LayerKit
//
//  Created by Blake Watters on 4/8/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRIdentityToken.h"
#import "LYRBase64Serialization.h"

@interface LYRIdentityToken ()
@property (nonatomic, strong) NSMutableDictionary *mutableHeader;
@property (nonatomic, strong) NSMutableDictionary *mutablePayload;
@property (nonatomic, strong, readwrite) NSData *signature;
@end

@implementation LYRIdentityToken

+ (instancetype)identityTokenFromJWSStringRepresentation:(NSString *)JWSString
{
    NSArray *components = [JWSString componentsSeparatedByString:@"."];
    if ([components count] != 3) return nil;
    
    NSData *headerJSONData = [LYRBase64Serialization dataFromBase64URLEncodedStringWithoutPadding:components[0]];
    NSDictionary *header = [NSJSONSerialization JSONObjectWithData:headerJSONData options:0 error:nil];
    if (!header) return nil;
    
    NSData *payloadJSONData = [LYRBase64Serialization dataFromBase64URLEncodedStringWithoutPadding:components[1]];
    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:payloadJSONData options:0 error:nil];
    if (!payload) return nil;
    
    NSData *signature = [LYRBase64Serialization dataFromBase64URLEncodedStringWithoutPadding:components[2]];
    if (!signature) return nil;
    
    LYRIdentityToken *identityToken = [LYRIdentityToken new];
    identityToken.mutableHeader = [header mutableCopy];
    identityToken.mutablePayload = [payload mutableCopy];
    identityToken.signature = signature;
    return identityToken;
}

- (id)init
{
    self = [super init];
    if (self) {
        _mutableHeader = [@{ @"typ": @"JWS",
                             @"cty": @"layer-eit;v=1",
                             @"alg": @"RS256" } mutableCopy];
        _mutablePayload = [NSMutableDictionary new];
        self.issueDate = [NSDate date];
        self.expirationDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 7]; // Expires in 7 days
    }
    return self;
}

- (NSDictionary *)header
{
    return _mutableHeader;
}

- (NSDictionary *)payload
{
    return _mutablePayload;
}

#pragma mark - Header Fields

- (void)setKeyID:(NSString *)keyID
{
    self.mutableHeader[@"kid"] = keyID;
}

- (NSString *)keyID
{
    return self.mutableHeader[@"kid"];
}

#pragma mark - Payload Fields

- (void)setProviderID:(NSString *)providerID
{
    self.mutablePayload[@"iss"] = providerID;
}

- (NSString *)providerID
{
    return self.payload[@"iss"];
}

- (void)setUserID:(NSString *)userID
{
    self.mutablePayload[@"prn"] = userID;
}

- (NSString *)userID
{
    return self.payload[@"prn"];
}

- (void)setIssueDate:(NSDate *)issueDate
{
    self.mutablePayload[@"iat"] = @([issueDate timeIntervalSince1970]);
}

- (NSDate *)issueDate
{
    NSNumber *iat = self.payload[@"iat"];
    return iat ? [NSDate dateWithTimeIntervalSince1970:[iat doubleValue]] : nil;
}

- (void)setExpirationDate:(NSDate *)expirationDate
{
    self.mutablePayload[@"exp"] = @([expirationDate timeIntervalSince1970]);
}

- (NSDate *)expirationDate
{
    NSNumber *exp = self.payload[@"exp"];
    return exp ? [NSDate dateWithTimeIntervalSince1970:[exp doubleValue]] : nil;
}

- (void)setNonce:(NSString *)nonce
{
    self.mutablePayload[@"nce"] = nonce;
}

- (NSString *)nonce
{
    return self.payload[@"nce"];
}

- (NSString *)JWSStringRepresentationSignedWithKeyPair:(LYRKeyPair *)keyPair error:(NSError **)error
{
    if (!keyPair) [NSException raise:NSInvalidArgumentException format:@"Cannot sign identity token with a `nil` key pair."];
    
    NSData *headerJSON = [NSJSONSerialization dataWithJSONObject:self.header options:0 error:error];
    if (!headerJSON) return nil;
    NSString *base64Header = [LYRBase64Serialization base64URLEncodedStringWithoutPaddingFromData:headerJSON];
    
    NSData *payloadJSON = [NSJSONSerialization dataWithJSONObject:self.payload options:0 error:error];
    if (!payloadJSON) return nil;
    NSString *base64Payload = [LYRBase64Serialization base64URLEncodedStringWithoutPaddingFromData:payloadJSON];
    
    NSString *signingInput = [NSString stringWithFormat:@"%@.%@", base64Header, base64Payload];
    NSData *signature = [keyPair signatureForData:[signingInput dataUsingEncoding:NSUTF8StringEncoding] error:error];
    if (!signature) return nil;
    _signature = signature;
    
    NSString *base64Signature = [LYRBase64Serialization base64URLEncodedStringWithoutPaddingFromData:signature];
    return [signingInput stringByAppendingFormat:@".%@", base64Signature];
}

@end
