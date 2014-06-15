//
//  LSNavigationController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSNavigationCoordinator.h"
#import "LSContactsViewController.h"
#import "LSHomeViewController.h"
#import "LSUserManager.h"

@interface LSNavigationCoordinator ()

@end

@implementation LSNavigationCoordinator

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void) presentConversationViewController
{

}

//- (void) logout
//{
//    [self.layerController.client stop];
//    [self.presentedViewController dismissViewControllerAnimated:TRUE completion:nil];
//}

@end
