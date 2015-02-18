//
//  ATLMAuthenticationViewController.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
