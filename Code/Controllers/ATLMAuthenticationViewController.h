//
//  ATLMAuthenticationViewController.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATLMApplicationController.h"
#import "ATLMUtilities.h"

@class ATLMAuthenticationViewController;

/**
 @abstract The `ATLMAuthenticationViewControllerDelegate` inform the delegate to events occuring within the controller.
 */
@protocol ATLMAuthenticationViewControllerDelegate <NSObject>

/**
 @abstract Informs the delegate that the user has selected a Layer Sample App environment.
 @param authenticationViewController The controller object within which the selection occurred.
 @param environment The `ATLMEnvironment` enumeration that was selected.
 */
- (void)authenticationViewController:(ATLMAuthenticationViewController *)authenticationViewController didSelectEnvironment:(ATLMEnvironment)environment;

@end

/**
 @abstract The `ATLMAuthenticationViewController` presents a user interface allowing for user login or user registration.
 When a user enters his or her credentials, the controller will attempt to authenticate and/or register the user.
 */
@interface ATLMAuthenticationViewController : UIViewController

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) ATLMApplicationController *applicationController;

/**
 @abstract The `ATLMAuthenticationViewControllerDelegate` object for the controller.
 */
@property (nonatomic) id<ATLMAuthenticationViewControllerDelegate> delegate;

/**
 @abstract Resets the UI after a successful authentication.
 */
- (void)resetState;

@end
