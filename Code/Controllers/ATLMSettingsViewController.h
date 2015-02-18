//
//  ATLMSettingsViewController.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 10/20/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "ATLMApplicationController.h"

@class ATLMSettingsViewController;

/**
 @abstract The `ATLMSettingsViewControllerDelegate` protocol informs the receiver of events that have occurred
 within the controller.
 */
@protocol ATLMSettingsViewControllerDelegate <NSObject>

/**
 @abstract Informs the receiver that a logout button has been tapped in the controller.
 @param settingsViewController The controller in which the selection occurred.
 */
- (void)logoutTappedInSettingsViewController:(ATLMSettingsViewController *)settingsViewController;

/**
 @abstract Informs the receiver that the user wants to dismiss the controller.
 @param settingsViewController The controller in which the selection occurred.
 */
- (void)settingsViewControllerDidFinish:(ATLMSettingsViewController *)settingsViewController;

@end

/**
 @abstract The `ATLMSettingsViewController` presents a user interface for viewing and configuring application settings
 in addition to information related to the application.
 */
@interface ATLMSettingsViewController : UITableViewController

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) ATLMApplicationController *applicationController;

/**
 @abstract The `ATLMSettingsViewControllerDelegate` object for the controller.
 */
@property (nonatomic) id<ATLMSettingsViewControllerDelegate> settingsDelegate;

@end
