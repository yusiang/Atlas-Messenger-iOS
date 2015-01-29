//
//  LSAppDelegate.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSApplicationController.h"
#import "LSConversationListViewController.h"

@interface LSAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic) UIWindow *window;

@property (nonatomic) LSApplicationController *applicationController;

@end
