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

@interface LSHomeViewController : UIViewController <LSLoginTableViewControllerDelegate, LSRegistrationTableViewControllerDelegate>

@property (nonatomic, strong) LSLayerController *layerController;

@end
