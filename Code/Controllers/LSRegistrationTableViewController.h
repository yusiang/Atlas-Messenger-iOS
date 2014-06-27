//
//  LSRegistrationTableViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSAuthenticationManager.h"

@class LSRegistrationTableViewController;

@protocol LSRegistrationTableViewControllerDelegate <NSObject>

- (void)registrationViewControllerDidFinish;

- (void)registrationViewControllerDidFailWithError:(NSError *)error;

@end

@interface LSRegistrationTableViewController : UITableViewController

@property (nonatomic, strong) LSAuthenticationManager *authenticationManager;
@property (nonatomic, weak) id<LSRegistrationTableViewControllerDelegate>delegate;

@end
