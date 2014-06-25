//
//  LSLoginTableViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSLoginTableViewController;

@protocol LSLoginTableViewControllerDelegate <NSObject>

- (void)loginViewControllerDidFinish;

- (void)loginViewControllerDidFailWithError:(NSError *)error;

@end

@interface LSLoginTableViewController : UITableViewController

@property (nonatomic, weak) id<LSLoginTableViewControllerDelegate>delegate;

@end
