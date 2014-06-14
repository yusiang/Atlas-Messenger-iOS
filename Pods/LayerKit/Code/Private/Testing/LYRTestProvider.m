//
//  LYRTestProvider.m
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRTestProvider.h"
#import "LYRUUIDData.h"

@implementation LYRTestProvider

- (id)initWithAccount:(LYRTAccount *)account keyPair:(LYRKeyPair *)keyPair publicKey:(LYRTPublicKey *)publicKey apps:(NSArray *)apps
{
    NSParameterAssert(account);
    NSParameterAssert(keyPair);
    NSParameterAssert(publicKey);
    NSParameterAssert(apps);
    NSAssert([apps count], @"Cannot instantiate a provider with an empty collection of apps.");
    
    self = [self init];
    if (self) {
        _account = account;
        _keyPair = keyPair;
        _publicKey = publicKey;
        _apps = apps;
    }
    return self;
}

- (NSString *)JWSIdentityTokenForUserID:(NSString *)userID nonce:(NSString *)nonce
{
    if (!nonce) [NSException raise:NSInvalidArgumentException format:@"Cannot compute an identity token with `nil` nonce"];
    LYRIdentityToken *identityToken = [LYRIdentityToken new];
    identityToken.keyID = LYRUUIDFromData(self.publicKey.key_id).UUIDString;
    identityToken.userID = userID;
    identityToken.providerID = LYRUUIDFromData(self.account.provider_id).UUIDString;
    identityToken.nonce = nonce;
    return [identityToken JWSStringRepresentationSignedWithKeyPair:self.keyPair error:nil];
}

- (NSUUID *)primaryAppID
{
    return LYRUUIDFromData([(LYRTApp *)self.apps[0] id]);
}

@end
