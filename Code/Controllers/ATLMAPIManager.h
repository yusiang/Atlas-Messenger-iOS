//
//  ATLMAPIManager.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "ATLMUser.h"
#import "ATLMPersistenceManager.h"
#import "ATLMUser.h"
#import "ATLMHTTPResponseSerializer.h"
#import "ATLMErrors.h"

extern NSString *const ATLMUserDidAuthenticateNotification;
extern NSString *const ATLMUserDidDeauthenticateNotification;

/**
 @abstract The `ATLMAPIManager` class provides an interface for interacting with the Layer Identity Provider JSON API and managing
 the Layer sample app authentication state.
 */
@interface ATLMAPIManager : NSObject

///--------------------------------
/// @name Initializing a Manager
///--------------------------------

+ (instancetype)managerWithBaseURL:(NSURL *)baseURL layerClient:(LYRClient *)layerClient;

/**
 @abstract The `LYRClient` object used to initialize the receiver.
 */
@property (nonatomic, readonly) LYRClient *layerClient;

/**
 @abstract The `ATLMPersistenceManage` object used to persiste user information
 */
@property (nonatomic) ATLMPersistenceManager *persistenceManager;

/**
 @abstract The current authenticated session or `nil` if not yet authenticated.
 */
@property (nonatomic) ATLMSession *authenticatedSession;

/**
 @abstract The baseURL used to initailze the receiver.
 */
@property (nonatomic) NSURL *baseURL;

/**
 @abstract The current authenticated URL session configuration or `nil` if not yet authenticated.
 */
@property (nonatomic) NSURLSessionConfiguration *authenticatedURLSessionConfiguration;

/**
 @abstract The currently configured URL session`
 */
@property (nonatomic) NSURLSession *URLSession;

/**
 @abstract Attempts to resume an exsiting application session.
 */
- (BOOL)resumeSession:(ATLMSession *)session error:(NSError **)error;

/**
 @abstract Registers and authenticates an Altas Messenger user.
 @param completion The completion block that is called upon successfully registering a user. Completion block cannot be `nil`.
 */
- (void)registerUserWithName:(NSString*)name nonce:(NSString *)nonce completion:(void (^)(NSString *identityToken, NSError *error))completion;

/**
 @abstract Deauthenticates the Layer sample app by discarding its `ATLMSession` object.
 */
- (void)deauthenticate;

@end
