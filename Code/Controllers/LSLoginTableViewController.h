//
//  LSLoginTableViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSAuthenticationManager.h"

@class LSUser, LYRClient;

@interface LSLoginTableViewController : UITableViewController

@property (nonatomic, strong) LSAuthenticationManager *authenticationManager;

- (void)setCompletionBlock:(void (^)(LSUser *user))completion;

@end
