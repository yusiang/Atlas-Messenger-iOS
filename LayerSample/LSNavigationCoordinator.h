//
//  LSNavigationController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSHomeViewController.h"
#import "LSConversationListViewController.h"

@interface LSNavigationCoordinator : NSObject <LSHomeViewControllerDelegate, LSConversationListViewControllerDelegate>

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) LSLayerController *layerController;

- (void) setViewController:(id)viewController;

- (void) logout;
@end
