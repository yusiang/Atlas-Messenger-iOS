//
//  LSUIConversationViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 9/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIConversationViewController.h"
#import "LSApplicationController.h"
#import "LSConversationDetailViewController.h"

/**
 @abstract Subclass of the `LYRUIConversationViewController` Layer UI Kit component. 
 The class acts as the Data Source and Delegate object of the component. It Presents a user 
 interface for displaying a list of conversations.
 */
@interface LSUIConversationViewController : LYRUIConversationViewController <LYRUIConversationViewControllerDataSource, LYRUIConversationViewControllerDelegate>

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) LSApplicationController *applicationContoller;

@end
