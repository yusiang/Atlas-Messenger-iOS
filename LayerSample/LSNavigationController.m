//
//  LSNavigationController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSNavigationController.h"
#import "LSContactsViewController.h"
#import "LSHomeViewController.h"
#import "LSUserManager.h"

@interface LSNavigationController ()

@end

@implementation LSNavigationController

- (id)initWithRootViewController:(LSHomeViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        rootViewController.delegate = self;
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

- (void)presentConversationViewController
{
    LSConversationListViewController *conversationListViewController = [[LSConversationListViewController alloc] init];
    conversationListViewController.delegate = self;
    UINavigationController *conversationController = [[UINavigationController alloc] initWithRootViewController:conversationListViewController];
    
    [self presentViewController:conversationController animated:TRUE completion:^{
        NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.viewControllers];
        [navigationArray removeObjectAtIndex: 1];
        self.viewControllers = navigationArray;
    }];
    
    [self.layerController initializeLayerClientWithUserIdentifier:[LSUserManager loggedInUserID] completion:^(NSError * error) {
        if (!error) {
            NSLog(@"Layer Client Started");
            conversationListViewController.layerController = self.layerController;
        }
    }];
}

- (void)logout
{
    [self.layerController.client stop];
    [self.presentedViewController dismissViewControllerAnimated:TRUE completion:nil];
}

@end
