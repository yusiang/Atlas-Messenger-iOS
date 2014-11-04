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
#import "LSUtilities.h"

@class LSAuthenticationTableViewController;

@protocol LSAuthenticationTableViewControllerDelegate <NSObject>

- (void)authenticationTableViewController:(LSAuthenticationTableViewController *)authenticationTabelViewController didSelectEnvironment:(LSEnvironment)environment;

@end

@interface LSAuthenticationTableViewController : UITableViewController

@property (nonatomic) LSApplicationController *applicationController;

@property (nonatomic) id<LSAuthenticationTableViewControllerDelegate>delegate;

- (void)loginTappedWithEmail:(NSString *)email password:(NSString *)password;

- (void)setCompletionBlock:(void (^)(NSString *authenticatedUserID))completion;

- (void)resetState;

@end
