//
//  LSConversationListVC.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRConversationListViewController.h"
#import <LayerKit/LayerKit.h>
#import "LSAPIManager.h"
#import "LSPersistenceManager.h"
#import "LSApplicationController.h"

@interface LSConversationListViewController : LYRConversationListViewController

@property (nonatomic, strong) LSApplicationController *applicationController;

@end

