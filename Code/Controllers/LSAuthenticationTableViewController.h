//
//  LSTableViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSApplicationController.h"
#import "LSUtilities.h"

@class LSAuthenticationTableViewController;

/**
 @abstract The `LSAuthenticationTableViewControllerDelegate` inform the delegate to events occuring within the controller.
 */
@protocol LSAuthenticationTableViewControllerDelegate <NSObject>

/**
 @abstract Informs the delegate that the user has selected a Layer Sample App environment.
 @param authenticationTableViewController The controller object within which the selection occurred.
 @param environment The `LSEnvironment` enumeration that was selected.
 */
- (void)authenticationTableViewController:(LSAuthenticationTableViewController *)authenticationTabelViewController didSelectEnvironment:(LSEnvironment)environment;

@end

/**
 @abstract The `LSAuthenticationTableViewController` presents a user interface allowing for user login or user registration.
 When a user enters his or her credentials, the controller will attempt to authenticate and/or register the user.
 */
@interface LSAuthenticationTableViewController : UITableViewController

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) LSApplicationController *applicationController;

/**
 @abstract The `LSAuthenticationTableViewControllerDelegate` object for the controller.
 */
@property (nonatomic) id<LSAuthenticationTableViewControllerDelegate> delegate;

/**
 @abstract A completion block that is called upon completion of a login or registration attempt.
 @param completionBlock The completion block to be invoked.
 */
- (void)setCompletionBlock:(void (^)(NSString *authenticatedUserID, NSError *error))completion;

/**
 @abstract Resets the UI after a successful authentication.
 */
- (void)resetState;

@end
