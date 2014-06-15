//
//  LSAppDelegate.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSLayerController.h"
#import "LSParseController.h"
#import "LSHomeViewController.h"
#import "LSNavigationCoordinator.h"

@interface LSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) LSLayerController *layerController;
@property (nonatomic, strong) LSParseController *parseController;

@end
