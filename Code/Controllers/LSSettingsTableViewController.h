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

/**
 @abstract The `LSSettingsTableViewControllerDelegate` protocol informs the reciever to events that have occured 
 within the controller.
 */
@protocol LSSettingsTableViewControllerDelegate <NSObject>

/**
 @abstract Informs the reciever that a Logout button has been tapped in the controller. 
 @param settingsTableViewController The controller in which the selection occured.
 */
- (void)logoutTappedInSettingsTableViewController:(LSSettingsTableViewController *)settingsTableViewController;

@end

/**
 @abstract The `LSSettingsTableViewController` Presents a user interface for viewing and configuring application setting
 in adition to information related to the application.
 */
@interface LSSettingsTableViewController : UITableViewController

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) LSApplicationController *applicationController;

/**
 @abstract The `LSSettingsTableViewControllerDelegate` object for the controller.
 */
@property (nonatomic) id<LSSettingsTableViewControllerDelegate>settingsDelegate;

@end
