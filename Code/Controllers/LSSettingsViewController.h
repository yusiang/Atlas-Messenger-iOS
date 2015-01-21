//
//  LSSettingsViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 10/20/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LSApplicationController.h"

@class LSSettingsViewController;

/**
 @abstract The `LSSettingsTableViewControllerDelegate` protocol informs the receiver of events that have occurred
 within the controller.
 */
@protocol LSSettingsTableViewControllerDelegate <NSObject>

/**
 @abstract Informs the receiver that a logout button has been tapped in the controller.
 @param settingsTableViewController The controller in which the selection occurred.
 */
- (void)logoutTappedInSettingsViewController:(LSSettingsViewController *)settingsTableViewController;

/**
 @abstract Informs the receiver that the user wants to dismiss the controller.
 @param settingsTableViewController The controller in which the selection occurred.
 */
- (void)settingsViewControllerDidFinish:(LSSettingsViewController *)settingsTableViewController;

@end

/**
 @abstract The `LSSettingsTableViewController` presents a user interface for viewing and configuring application settings
 in addition to information related to the application.
 */
@interface LSSettingsViewController : UITableViewController

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) LSApplicationController *applicationController;

/**
 @abstract The `LSSettingsTableViewControllerDelegate` object for the controller.
 */
@property (nonatomic) id<LSSettingsTableViewControllerDelegate> settingsDelegate;

@end
