//
//  LSUIConversationViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 9/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIConversationViewController.h"
#import "LSApplicationController.h"

/**
 @abstract Subclass of the `LYRUIConversationViewController. Presents a user interface for a conversation.
 */
@interface LSUIConversationViewController : LYRUIConversationViewController

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) LSApplicationController *applicationContoller;

@end
