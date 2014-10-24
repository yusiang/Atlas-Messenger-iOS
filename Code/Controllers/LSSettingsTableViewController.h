//
//  LSSettingsViewControllerTableViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 10/20/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LSApplicationController.h"

@class LSSettingsTableViewController;

@protocol LSSettingsTableViewControllerDelegate <NSObject>

- (void)logoutTappedInSettingsTableViewController:(LSSettingsTableViewController *)settingsTableViewController;

@end

@interface LSSettingsTableViewController : UITableViewController

@property (nonatomic) LSApplicationController *applicationController;

@property (nonatomic) id<LSSettingsTableViewControllerDelegate>settingsDelegate;

@end
