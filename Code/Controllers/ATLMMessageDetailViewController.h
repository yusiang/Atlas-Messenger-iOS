//
//  ATLMMessageDetailViewController.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 11/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "ATLMApplicationController.h"

/**
 @abstract The `ATLMMessageDetailViewController` presents a user interface for displaying
 information regarding a single Layer `LYRMessage` object.
 */
@interface ATLMMessageDetailViewController : UITableViewController

///--------------------------------
/// @name Initializing a Controller
///--------------------------------

+ (instancetype)messageDetailViewControllerWithMessage:(LYRMessage *)message applicationController:(ATLMApplicationController *)applicationController;

@end
