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

// SBW: Any time you define a delegate the first argument should be a pointer to the object for which the receiver is acting as the delegate.
// i.e. registrationViewControllerDidFinish
// You also need a `didFailWithError:`
- (void)registrationSuccess;

@end

@interface LSRegistrationTableViewController : UITableViewController

@property (nonatomic, weak) id<LSRegistrationTableViewControllerDelegate>delegate;

@end
