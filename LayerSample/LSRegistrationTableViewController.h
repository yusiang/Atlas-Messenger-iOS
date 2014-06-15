//
//  LSRegistrationTableViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSRegistrationTableViewController;

@protocol LSRegistrationTableViewControllerDelegate <NSObject>

- (void)registrationSuccessful;
- (void)setLoggedInUserInfo:(NSDictionary *)userInfo;

@end

@interface LSRegistrationTableViewController : UITableViewController

@property (nonatomic, weak) id<LSRegistrationTableViewControllerDelegate>delegate;

@end
