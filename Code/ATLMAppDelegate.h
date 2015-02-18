//
//  ATLMAppDelegate.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATLMApplicationController.h"
#import "ATLMConversationListViewController.h"

@interface ATLMAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic) UIWindow *window;

@property (nonatomic) ATLMApplicationController *applicationController;

@end
