//
//  LSConversationListViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 7/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LSConversationViewController.h"
#import "LSAPIManager.h"

@interface LSConversationListViewController : UITableViewController 

@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) LSAPIManager *APIManager;
@property (nonatomic) LSPersistenceManager *persistenceManager;

@end
