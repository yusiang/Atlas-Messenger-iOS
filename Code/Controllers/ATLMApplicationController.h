//
//  LSApplicationController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "ATLMAPIManager.h"
#import "ATLMLayerClient.h"

NSString *const ATLMLayerApplicationID;

extern NSString *const ATLMConversationMetadataDidChangeNotification;
extern NSString *const ATLMConversationParticipantsDidChangeNotification;
extern NSString *const ATLMConversationDeletedNotification;

/**
 @abstract The `LSApplicationController` manages global resources needed by multiple view controller classes in the Layer Sample App.
 It also implement the `LYRClientDelegate` protocol. Only one instance should be instantiated and it should be passed to 
 controllers that require it.
 */
@interface ATLMApplicationController : NSObject <LYRClientDelegate>

///--------------------------------
/// @name Initializing a Controller
///--------------------------------

+ (instancetype)controllerWithPersistenceManager:(ATLMPersistenceManager *)persistenceManager;

///--------------------------------
/// @name Global Resources
///--------------------------------

/**
 @abstract The `LYRCLient` object for the application.
 */
@property (nonatomic) ATLMLayerClient *layerClient;

/**
 @abstract The `LSAPIManager` object for the application.
 */
@property (nonatomic) ATLMAPIManager *APIManager;

/**
 @abstract The `LSPersistenceManager` object for the application.
 */
@property (nonatomic) ATLMPersistenceManager *persistenceManager;

@end
