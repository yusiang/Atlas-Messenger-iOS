//
//  LSAuthenticationViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSApplicationController.h"
#import "LSUtilities.h"

@class LSAuthenticationViewController;

/**
 @abstract The `LSAuthenticationViewControllerDelegate` inform the delegate to events occuring within the controller.
 */
@protocol LSAuthenticationViewControllerDelegate <NSObject>

/**
 @abstract Informs the delegate that the user has selected a Layer Sample App environment.
 @param authenticationViewController The controller object within which the selection occurred.
 @param environment The `LSEnvironment` enumeration that was selected.
 */
- (void)authenticationViewController:(LSAuthenticationViewController *)authenticationViewController didSelectEnvironment:(LSEnvironment)environment;

@end

/**
 @abstract The `LSAuthenticationViewController` presents a user interface allowing for user login or user registration.
 When a user enters his or her credentials, the controller will attempt to authenticate and/or register the user.
 */
@interface LSAuthenticationViewController : UITableViewController

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) LSApplicationController *applicationController;

/**
 @abstract The `LSAuthenticationViewControllerDelegate` object for the controller.
 */
@property (nonatomic) id<LSAuthenticationViewControllerDelegate> delegate;

/**
 @abstract Resets the UI after a successful authentication.
 */
- (void)resetState;

@end
