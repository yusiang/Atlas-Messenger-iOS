//
//  LSConversationListViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIConversationListViewController.h"
#import "LSApplicationController.h"
#import "LSUIConstants.h"
#import "LSUtilities.h"

@interface LSUIConversationListViewController : LYRUIConversationListViewController

@property (nonatomic, strong) LSApplicationController *applicationController;

@end
