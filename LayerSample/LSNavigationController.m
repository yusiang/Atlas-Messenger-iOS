//
//  LSNavigationController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSNavigationController.h"

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
    LSConversationListViewController *viewController = [[LSConversationListViewController alloc] init];
    viewController.layerController = self.layerController;
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:controller animated:TRUE completion:^{
        //
    }];
}

@end
