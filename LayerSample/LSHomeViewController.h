//
//  LSHomeViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSLoginTableViewController.h"
#import "LSRegistrationTableViewController.h"
#import "LSLayerController.h"

@class LSHomeViewController;

@protocol LSHomeViewControllerDelegate <NSObject>

- (void) presentConversationViewController;

@end

@interface LSHomeViewController : UIViewController <LSLoginTableViewControllerDelegate, LSRegistrationTableViewControllerDelegate>

@property (nonatomic, strong) LSLayerController *layerController;
@property (nonatomic, weak) id<LSHomeViewControllerDelegate>delegate;

@end
