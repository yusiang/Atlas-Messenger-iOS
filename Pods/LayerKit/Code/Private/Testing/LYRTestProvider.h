//
//  LYRTestProvider.h
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ctrl.h"
#import "LYRKeyPair.h"
#import "LYRIdentityToken.h"

/**
 The `LYRTestProvider` class models a transient authentication provider within the testing backend. It acts
 as a stand-in for a Layer developer's backend system that issues cryptographic identity tokens for authentication purposes.
 */
@interface LYRTestProvider : NSObject

///---------------------------------
/// @name Accessing Provider Details
///---------------------------------

/**
 The account of the provider.
 */
@property (nonatomic, strong, readonly) LYRTAccount *account;

/**
 A keypair used for signing.
 */
@property (nonatomic, strong, readonly) LYRKeyPair *keyPair;

/**
 The Thrift representation of the registered public key.
 */
@property (nonatomic, strong, readonly) LYRTPublicKey *publicKey;

/**
 An array of apps registered to the provider.
 */
@property (nonatomic, strong, readonly) NSArray *apps;

/**
 A convenience accessor for retrieving the app ID of the first element in `apps`.
 
 This is equivalent to the following example code:
 
 [(LYRTApp *)provider.apps[0] id];
 */
@property (nonatomic, readonly) NSUUID *primaryAppID;

///----------------------------------
/// @name Obtaining an Identity Token
///----------------------------------

/**
 Creates and returns an identity token object for authenticating the specified user ID with a given nonce.
 
 @param userID The ID of the user in our mock provider that is to be authenticated.
 @param nonce A nonce object that was obtained by calling `getNonce` or handling an authentication interrupt.
 @return An identity token object ready for authenticating the user.
 */
- (NSString *)JWSIdentityTokenForUserID:(NSString *)userID nonce:(NSString *)nonce;

@end
