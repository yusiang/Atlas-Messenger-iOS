//
//  LYRTransportManager.h
//  LayerKit
//
//  Created by Blake Watters on 4/11/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRSession.h"
#import <SPDYTLSTrustEvaluator.h>

/**
 The `LYRTransportManager` class manages transport level concerns around Thrift RPC.
 */
@interface LYRTransportManager : NSObject

///-----------------------------
/// @name Initializing Transport
///-----------------------------

/**
 @abstract Initializes the receiver with a specific baseURL and cryptographic identity.
 
 @param baseURL The baseURL of the remote Layer server to connect to. Cannot be `nil`.
 @param appID The unique application identifier.
 @param identity The cryptographic identity to use when establishing a TLS session on the remote host. Cannot be `NULL`.
 @param sessionToken Previously received session token we received and persisted previously.
 @return The receiver, initialized with the given host, port, appID, identity and session token.
 */
- (id)initWithBaseURL:(NSURL *)baseURL appID:(NSUUID *)appID identity:(SecIdentityRef)identity sessionToken:(NSString *)sessionToken;

///-----------------------------------
/// @name Accessing Connection Details
///-----------------------------------

/**
 @abstract The remote host that the receiver is connected to.
 */
@property (nonatomic, strong, readonly) NSURL *baseURL;

/**
 */
@property (nonatomic, strong, readonly) NSUUID *appID;

/**
 @abstract The cryptographic identity used to establish a TLS connection on the remote host that the receiver is connected to.
 */
@property (nonatomic, assign, readonly) SecIdentityRef identity;

/**
 @abstract Returns the URL session configuration.
 @discussion Maintains authentication state and transport protocol configuration.
 */
@property (nonatomic, readonly) NSURLSessionConfiguration *sessionConfiguration;

///----------------------------
/// @name Connection Management
///----------------------------

/**
 @abstract Establishes a connection with the remote host.
 
 @param completion An optional block to be executed when the status of the connection is determined.
 */
- (void)connectWithCompletion:(void (^)(BOOL success, NSError *error))completion;

/**
 @abstract Breaks the connection with the remote host.
 */
- (void)disconnect;

/**
 @abstract Returns a Boolean value that indicates if the receiver is connected to a remote Layer server.
 */
@property (nonatomic, readonly) BOOL isConnected;

///-------------------------------
/// @name Transport Authentication
///-------------------------------

/**
 @abstract Returns the session token, if any, used to authenticate the connection.
 */
@property (nonatomic, readonly) NSString *sessionToken;

/**
 @abstract Asynchronously requests an authentication nonce.
 */
- (void)requestAuthenticationNonceWithCompletion:(void (^)(NSString *nonce, NSError *error))completion;

/**
 @abstract Authenticates the URL Session used for SPDY Transport.

 @param identityToken The identity token with which to authenticate the underlying SPDY connection.
 @param completion A block to be executed once the asynchronous authentication request has been completed. It accepts two arguments: a 
    dictionary containing a session token, TTL, and userID on success or `nil` on failure and an error object that, upon failure, describes the nature of the failure.
 */
- (void)authenticateWithIdentityToken:(NSString *)identityToken completion:(void (^)(NSDictionary *authenticationInfo, NSError *error))completion;

/**
 @abstract Deauthenticates the transport manager, disposing of any previously established user identity and disallowing access to the Layer communication services until a new identity is established.
 */
- (void)deauthenticate;

@end
