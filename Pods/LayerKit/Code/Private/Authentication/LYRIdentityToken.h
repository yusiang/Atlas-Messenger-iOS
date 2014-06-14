//
//  LYRIdentityToken.h
//  LayerKit
//
//  Created by Blake Watters on 4/8/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRKeyPair.h"

/**
 The `LYRIdentityToken` class provides an implementation of the Layer
 identity token, which is used to authenticate a user of the SDK. Typically this
 is implemented by web applications that act as the backend for Layer integrations.
 */
@interface LYRIdentityToken : NSObject

/**
 @abstract Creates and returns a new identity token object from the JSON Web Signature (JWS) representation encoded in the given string.
 @param JWSString A JSON Web Signature encoding an Layer Identity Token.
 @return A new identity token object or `nil` if the given string does not encode a value Layer Identity Token in JWS format.
 */
+ (instancetype)identityTokenFromJWSStringRepresentation:(NSString *)JWSString;

///-----------------------------------
/// @name Configuring Provider Details
///-----------------------------------

/**
 The provider ID associated with the account. Issued by Layer to integrating parties.
 */
@property (nonatomic, copy) NSString *providerID;

/**
 The key ID of the public key that is to be used to verify the signature on the identity token.
 */
@property (nonatomic, copy) NSString *keyID;

/**
 The date and time that the token was issued by the identity provider.
 */
@property (nonatomic, strong) NSDate *issueDate;

/**
 The date and time that the token will expire.
 */
@property (nonatomic, strong) NSDate *expirationDate;

///-------------------------------
/// @name Configuring User Details
///-------------------------------

/**
 The user ID that is to be authenticated by the identity token. This typically corresponds to the primary key,
 email address, or username of a User in the remote system.
 */
@property (nonatomic, copy) NSString *userID;

/**
 A nonce value that is issued by Layer and used to confirm that the identity token is one that we requested.
 
 Obtained by a call to `getNonce` or via a `LYRClientDelegate` callback.
 */
@property (nonatomic, copy) NSString *nonce;

///---------------------------
/// @name Accessing Components
///---------------------------

/**
 @abstract Returns the header component of the JWS.
 */
@property (nonatomic, readonly) NSDictionary *header;

/**
 @abstract Returns the payload component of the JWS.
 */
@property (nonatomic, readonly) NSDictionary *payload;

/**
 @abstract Returns the signature of the identity token or `nil` if unsigned.
 */
@property (nonatomic, readonly) NSData *signature;

///-------------------------------------
/// @name Obtaining a JWS Representation
///-------------------------------------

/**
 Returns a JSON Web Signature representation of the receiver as a string. This can be used to complete authentication
 and establish identity with Layer. Upon return, the value of `signature` is updated to the results of the signing operation.
 
 @param keyPair The
 @raises NSInvalidArgumentException Raised if the given `keyPair` is `nil`.
 */
- (NSString *)JWSStringRepresentationSignedWithKeyPair:(LYRKeyPair *)keyPair error:(NSError **)error;

@end
