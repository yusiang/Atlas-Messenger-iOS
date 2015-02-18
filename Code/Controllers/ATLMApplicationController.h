//
//  ATLMApplicationController.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 6/30/14.
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
#import "ATLMAPIManager.h"
#import "ATLMLayerClient.h"

extern NSString *const ATLMConversationMetadataDidChangeNotification;
extern NSString *const ATLMConversationParticipantsDidChangeNotification;
extern NSString *const ATLMConversationDeletedNotification;
extern NSString *const ATLMUserDefaultsLayerConfigurationURLKey;

/**
 @abstract The `ATLMApplicationController` manages global resources needed by multiple view controller classes in the Layer Sample App.
 It also implement the `LYRClientDelegate` protocol. Only one instance should be instantiated and it should be passed to 
 controllers that require it.
 */
@interface ATLMApplicationController : NSObject <LYRClientDelegate>

///--------------------------------
/// @name Initializing a Controller
///--------------------------------

+ (instancetype)controllerWithBaseURL:(NSURL *)baseURL layerClient:(LYRClient *)layerClient persistenceManager:(ATLMPersistenceManager *)persistenceManager;

///--------------------------------
/// @name Global Resources
///--------------------------------

/**
 @abstract The `LYRCLient` object for the application.
 */
@property (nonatomic) ATLMLayerClient *layerClient;

/**
 @abstract The `ATLMAPIManager` object for the application.
 */
@property (nonatomic) ATLMAPIManager *APIManager;

/**
 @abstract The `ATLMPersistenceManager` object for the application.
 */
@property (nonatomic) ATLMPersistenceManager *persistenceManager;


///--------------------------------
/// @name Global Settings
///--------------------------------

/**
 @abstract Boolean value that determines whether or not Layer should send a push notification payload.
 */
@property (nonatomic) BOOL shouldSendPushText;

/**
 @abstract Boolean value that determines whether or not Layer should send a push notification sound.
 */
@property (nonatomic) BOOL shouldSendPushSound;

/**
 @abstract Boolean value that determines whether or not Layer should display local notifications.
 */
@property (nonatomic) BOOL shouldDisplayLocalNotifications;

/**
 @abstract Boolean value that determines whether or not the application is in debug mode.
 */
@property (nonatomic) BOOL debugModeEnabled;

///--------------------------------
/// @name Global Info
///--------------------------------
/**
 @abstract The device token object used for push notifications.
 */
@property (nonatomic) NSData *deviceToken;

/**
 @abstract Constructs and returns a version string describing the current version of the application.
 @return The version string suitable for display in the app.
 */
+ (NSString *)versionString;

/**
 @abstract Constructs and returns a build string describing the context in which the app was built.
 @return The build string suitable for display in the app.
 */
+ (NSString *)buildInformationString;

/**
 @abstract Constructs and returns a string describing the current Layer server environment.
 @return The current Layer server environment string suitable for display in the app.
 */
+ (NSString *)layerServerHostname;

@end
