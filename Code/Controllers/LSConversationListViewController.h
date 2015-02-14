//
//  LSConversationListViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Atlas/Atlas.h>
#import "LSApplicationController.h"

/**
 @abstract Subclass of the `LYRUIConversationListViewController`. Presents a list of conversations in time series order.
 */
@interface LSConversationListViewController : ATLConversationListViewController

/**
 @abstract Programatically simulates the selection of a `LYRConversation` object in the conversations table view.
 @discussion This method is used when opening the application in response to a push notification. When invoked, it
 will display the approriate conversation on screen.
 */
- (void)selectConversation:(LYRConversation *)conversation;

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) LSApplicationController *applicationController;

/**
 @abstract Determines if the view controller should display a `Settings` item as the left bar button item of
 the navigation controller.
 */
@property (nonatomic) BOOL displaysSettingsItem;

@end
