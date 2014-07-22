//
//  LSConversationViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LSPersistenceManager.h"
#import "LSComposeView.h"
#import "LSNotificationObserver.h"
#import "LSAPIManager.h"

@interface LSConversationViewController : UIViewController <LSNotificationObserverDelegate>

@property (nonatomic, strong) LYRClient *layerClient;
@property (nonatomic, strong) LYRConversation *conversation;
@property (nonatomic, strong) LSPersistenceManager *persistanceManager;
@property (nonatomic, strong) LSNotificationObserver *notificationObserver;
@property (nonatomic, strong) LSAPIManager *APImanager;

@end
