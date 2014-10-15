//
//  LSConversationListViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIConversationListViewController.h"
#import "LSApplicationController.h"
#import "LYRUIConstants.h"
#import "LSUtilities.h"

/**
 @abstract Subclass of the `LYRUIConversationListViewController. Presents a list of conversations in time series order
 */
@interface LSUIConversationListViewController : LYRUIConversationListViewController

- (void)selectConversation:(LYRConversation *)conversation;

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) LSApplicationController *applicationController;

@end
