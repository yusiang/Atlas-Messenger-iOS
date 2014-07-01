//
//  LSAppController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "LSAPIManager.h"

/**
 @abstract The `LSAppController` class manages mission critical classes to the Layer Sample App
 */

@interface LSApplicationController : NSObject

///--------------------------------
/// @name Initializing a Controller
///--------------------------------

+ (instancetype)managerWithBaseURL:(NSURL *)baseURL;

/**
 @abstract The following properties service mission critical operations for the Layer Sample App and are managed by the Controller
 */

@property (nonatomic, strong) LYRClient *layerClient;
@property (nonatomic, strong) LSAPIManager *APIManager;
@property (nonatomic, strong) LSPersistenceManager *persistenceManager;

@end
