//
//  LSHomeViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LSLoginTableViewController.h"
#import "LSRegistrationTableViewController.h"
#import "LSAuthenticationManager.h"

@interface LSHomeViewController : UIViewController

@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) LSAuthenticationManager *authenticationManager;

@end
