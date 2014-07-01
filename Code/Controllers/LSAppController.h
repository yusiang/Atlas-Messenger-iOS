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

@interface LSAppController : NSObject

@property (nonatomic, strong) LYRClient *layerClient;
@property (nonatomic, strong) LSAPIManager *APIManager;
@property (nonatomic, strong) LSPersistenceManager *persistenceManager;
@property (nonatomic, strong) UINavigationController *navigationController;

@end
