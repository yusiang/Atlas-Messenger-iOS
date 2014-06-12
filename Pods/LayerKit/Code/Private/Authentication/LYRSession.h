//
//  LYRSession.h
//  LayerKit
//
//  Created by Blake Watters on 4/8/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LYRTSession;

/**
 The `LYRSession` class models an on-going session with the Layer cloud.
 */
@interface LYRSession : NSObject <NSCoding>

///-----------------------------
/// @name Initializing a Session
///-----------------------------

/**
 Creates and returns a new session object from a authentication details.
 
 @param token The session token with which to initialize the Layer session. Cannot be `nil`.
 @param TTL The TTL value of the session. Cannot be `0`.
 @param layerUserID The user identifier (provided by Layer) associated with the session. Cannot be `nil`.
 @param providerUserID The user identifier (provided by provider) associated with the session. Cannot be `nil`.
 @returns A newly initialized session object initialized with the data in the given Thrift session.
 @raises NSInternalInconsistencyException Raised if the given `session` is `nil`.
 */
+ (instancetype)sessionWithToken:(NSString *)token TTL:(NSInteger)TTLValue layerUserID:(NSUUID *)layerUserID providerUserID:(NSString *)providerUserID appID:(NSUUID *)appID;

///-----------------------
/// @name Session Identity
///-----------------------

/**
 The Layer App ID that the session is associated with.
 */
@property (nonatomic, copy, readonly) NSUUID *appID;

/**
 The Layer User ID that the session is associated with.
 */
@property (nonatomic, copy, readonly) NSUUID *layerUserID;

/**
 The Provider User ID that the session is associated with.
 */
@property (nonatomic, copy, readonly) NSString *providerUserID;

///---------------------------
/// @name Authentication Token
///---------------------------

/**
 A token for authenticating with the identity encoded by the receiver.
 */
@property (nonatomic, copy, readonly) NSString *token;

///-----------------
/// @name Expiration
///-----------------

/**
 The date that the session expires.
 */
@property (nonatomic, readonly) NSDate *expirationDate;

/**
 A convenience accessor that indicates if the session is expired.
 */
@property (nonatomic, readonly) BOOL isExpired;

@end
