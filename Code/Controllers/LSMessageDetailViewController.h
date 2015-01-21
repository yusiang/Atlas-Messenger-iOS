//
//  LSMessageDetailViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 11/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LSApplicationController.h"

/**
 @abstract The `LSMessageDetailViewController` presents a user interface for displaying
 information regarding a single Layer `LYRMessage` object.
 */
@interface LSMessageDetailViewController : UITableViewController

///--------------------------------
/// @name Initializing a Controller
///--------------------------------

+ (instancetype)messageDetailViewControllerWithMessage:(LYRMessage *)message applicationController:(LSApplicationController *)applicationController;

@end
