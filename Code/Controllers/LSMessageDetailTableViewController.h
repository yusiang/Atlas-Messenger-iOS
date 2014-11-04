//
//  LSMessageDetailTableViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 11/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LSApplicationController.h"

@interface LSMessageDetailTableViewController : UITableViewController

+ (instancetype)initWithMessage:(LYRMessage *)message applicationController:(LSApplicationController *)applicationController;

@end
