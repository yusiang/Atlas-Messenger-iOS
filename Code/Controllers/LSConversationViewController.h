//
//  LSConversationViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 9/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Atlas/Atlas.h>
#import "LSApplicationController.h"
/**
 @abstract Subclass of the `LYRUIConversationViewController` LayerUIKit component.
 The class acts as the data source and delegate of the component. It presents a user
 interface for displaying a conversation's messages.
 */
@interface LSConversationViewController : ATLConversationViewController <ATLConversationViewControllerDataSource, ATLConversationViewControllerDelegate>

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) LSApplicationController *applicationController;

@end
