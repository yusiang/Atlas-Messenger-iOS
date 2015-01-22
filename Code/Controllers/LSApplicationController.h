//
//  LSApplicationController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "LSAPIManager.h"
#import "LSLayerClient.h"

extern NSString *const LSConversationDeletedNotification;
extern NSString *const LSUserDefaultsLayerConfigurationURLKey;

/**
 @abstract The `LSApplicationController` manages global resources needed by multiple view controller classes in the Layer Sample App.
 It also implement the `LYRClientDelegate` protocol. Only one instance should be instantiated and it should be passed to 
 controllers that require it.
 */
@interface LSApplicationController : NSObject <LYRClientDelegate>

///--------------------------------
/// @name Initializing a Controller
///--------------------------------

+ (instancetype)controllerWithBaseURL:(NSURL *)baseURL layerClient:(LYRClient *)layerClient persistenceManager:(LSPersistenceManager *)persistenceManager;

///--------------------------------
/// @name Global Resources
///--------------------------------

/**
 @abstract The `LYRCLient` object for the application.
 */
@property (nonatomic) LSLayerClient *layerClient;

/**
 @abstract The `LSAPIManager` object for the application.
 */
@property (nonatomic) LSAPIManager *APIManager;

/**
 @abstract The `LSPersistenceManager` object for the application.
 */
@property (nonatomic) LSPersistenceManager *persistenceManager;


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
