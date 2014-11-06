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

/**
 @abstract Programatically simulates the selection of a `LYRConversation` object from the Conversation TableView.
 @discusttion This method is used when opening the application in response to a push notification. When invoked, it
 will display the approriate conversation on screen.
 */
- (void)selectConversation:(LYRConversation *)conversation;

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) LSApplicationController *applicationController;

/**
 @abstract Determies if the view controller shoud display an option `Settings` item as the left bar button item of 
 the Navigation Controller.
 */
@property (nonatomic) BOOL shouldDisplaySettingsItem;

@end
