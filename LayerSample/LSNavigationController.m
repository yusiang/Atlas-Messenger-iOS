//
//  LSNavigationController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSNavigationController.h"
#import "LSContactsViewController.h"

@interface LSNavigationController ()

@end

@implementation LSNavigationController

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setViewController:(id)viewController
{
    [self setViewControllers:@[viewController] animated:TRUE];
}

- (void) presentConversationViewController
{
    LSContactsViewController *contactViewController = [[LSContactsViewController alloc] init];
    contactViewController.layerController = self.layerController;
    
    UINavigationController *contactController = [[UINavigationController alloc] initWithRootViewController:contactViewController];
    
    LSConversationListViewController *conversationListViewController = [[LSConversationListViewController alloc] init];
    conversationListViewController.layerController = self.layerController;
    
    UINavigationController *conversationController = [[UINavigationController alloc] initWithRootViewController:conversationListViewController];
    
//    UITabBarController *controller = [[UITabBarController alloc] init];
//    [controller setViewControllers:@[contactController, conversationController]];
//    
    [self presentViewController:conversationController animated:TRUE completion:^{
        //
    }];
}

@end
