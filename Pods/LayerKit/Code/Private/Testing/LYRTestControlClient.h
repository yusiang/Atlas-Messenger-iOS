//
//  LYRTestControlClient.h
//  LayerKit
//
//  Created by Blake Watters on 4/8/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ctrl.h"
#import "LYRIdentityToken.h"
#import "LYRSession.h"

@class LYRTestProvider;

/**
 The `LYRTestControlClient` class provides a convenient interface to the Layer Control Thrift
 API's for testing purposes. It presents a high level interface to the Control API's that supports
 rapid test-driven development on LayerKit.
 */
@interface LYRTestControlClient : NSObject

/**
 Creates and returns a new Control client to the Thrift endpoint at the specified hostname and port.
 
 @param hostname The hostname on which a Control Thrift API is running. Pass `nil` to use `LYRTestHostname()`.
 @param port The port on which a Control Thrift API is running. Pass `0` to use `LYRTestControlPort()`.
 */
+ (instancetype)controlClientWithHost:(NSString *)hostname port:(NSUInteger)port;

///-----------------------------------
/// @name Accessing Connection Details
///-----------------------------------

/**
 The hostname of the Control Thrift API the receiver is connected to.
 */
@property (nonatomic, copy, readonly) NSString *hostname;

/**
 The port on the host running the Control Thrift API that the receiver is connected to.
 */
@property (nonatomic, assign, readonly) NSUInteger port;

/**
 The underlying Thrift client used to interact with the Control API.
 */
@property (nonatomic, strong, readonly) LYRTCtrlClient *thriftClient;

///----------------------------------------
/// @name Managing Authentication Providers
///----------------------------------------

/**
 Creates a Layer account for testing purposes, optionally yielding it to the block for configuration before registration with Control.
 
 @param configurationBlock An optional block that is called to provide an opportunity to configure the account before it is created.
 @return A fully registered Layer account that is ready for testing.
 */
- (LYRTAccount *)createAccountWithConfigurationBlock:(void (^)(LYRTAccount *account))configurationBlock;

/**
 Adds the public key portion of a given key pair to the specified account, making it usable for authentication signing purposes.
 
 @param keyPair The key pair containing the public key to be added. Cannot be `nil`.
 @param account The account to which the public key to be added. Cannot be `nil`.
 @return An `LYRTPublicKey` object representation of the key that was added to Control.
 */
- (LYRTPublicKey *)addPublicKeyOfKeyPair:(LYRKeyPair *)keyPair toAccount:(LYRTAccount *)account;

/**
 Create a complete Layer provider for testing purposes.
 
 A Layer provider consists of an Account, an RSA key pair with a registered Public Key (for verification of cryptographic signing), an associated App.
 Typically providers are external systems that have been configured to interact with Layer via the CLI or Web user interfaces. In a testing context, it
 is convenient to provision a transient provider that can internally authenticte users with requiring interaction with an external system.
 
 @param configurationBlock An optional block that is called to provide an opportunity to configure the account before it is created.
 @return A fully provisioned Layer provider that is ready for testing.
 */
- (LYRTestProvider *)createProviderWithConfigurationBlock:(void (^)(LYRTAccount *account))configurationBlock;

/**
 Revokes a session, forcefully deauthenticating the client.
 
 @param session The session to be revoked.
 */
- (void)revokeSession:(LYRSession *)session;

@end
