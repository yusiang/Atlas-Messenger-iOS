//
//  LSTableViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSAuthenticationTableViewFooter.h"
#import "LSApplicationController.h"

@interface LSAuthenticationTableViewController : UITableViewController

@property (nonatomic, strong) LSApplicationController *applicationController;

- (void)setCompletionBlock:(void (^)(NSString *authenticatedUserID))completion;

- (void)resetState;

@end
