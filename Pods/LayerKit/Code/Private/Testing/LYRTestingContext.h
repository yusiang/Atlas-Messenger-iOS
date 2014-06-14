//
//  LYRTestingContext.h
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRTestControlClient.h"
#import "LYRUUIDData.h"
#import "LYRCryptographer.h"

/**
 @abstract The `LYRTestingContext` class provides an interface for accessing key pieces of information necessary to test a Layer client.
 @discussion This class is designed to eliminate boilerplate and speed up tests by providing convenient interfaces for quickly establishing a desired testing context.
 */
@interface LYRTestingContext : NSObject

/**
 @abstract Returns the shared testing context.
 @discussion Returns a testing context with a randomly generated app ID with all cryptographic and transport configuration completed.
 @returns The shared testing context.
 */
+ (instancetype)sharedContext;

/**
 @abstract Returns a test provider for servicing authentication requests.
 */
@property (nonatomic, readonly) LYRTestProvider *provider;

/**
 @abstract Returns the cryptographer object managing the cryptographic assets for the receiver.
 */
@property (nonatomic, readonly) LYRCryptographer *cryptographer;

/**
 @abstract Returns the app ID.
 */
@property (nonatomic, readonly) NSUUID *appID;

/**
 @abstract Returns a Keychain secure identity usable for establishing a TLS connection with the remote Layer server.
 */
@property (nonatomic, readonly) SecIdentityRef identity;

///----------------------------------
/// @name Establishing Authentication
///----------------------------------

/**
 @abstract Retrieves an authenticated session with the specified user ID.
 @discussion This method caches the results such that subsequent requests for the same user ID are in memory lookups.
 @param userID The user ID to obtain an authenticated session as. If `nil`, then a user ID will be randomly generated.
 @return An authenticated Layer session object.
 */
- (LYRSession *)authenticatedSessionWithUserID:(NSString *)userID;

/**
 @abstract Returns a URL session configuration configured to use SPDY for transport and authenticated using the given session.
 @param session The session to authenticate the URL session with. Passing `nil` will generate a new session.
 @return A URL session configuration with SPDY transport and authentication configured for the given session.
 */
- (NSURLSessionConfiguration *)URLSessionConfigurationWithSession:(LYRSession *)session;

/**
 @abstract Saves the cryptographic assets from the receiver into the keychain.
 @discussion Keychain persistence uses the key identifier expected by `LYRClient` instances. If the assets already exist in the keychain
 this method will return `YES` without saving additional copies.
 @param error A pointer to an error object that upon failure describes why persistence to the keychain failed.
 @return A Boolean value indicating if persistence of the cryptographic assets was successful.
 */
- (BOOL)saveCryptographicAssetsToKeychain:(NSError **)error;

@end
