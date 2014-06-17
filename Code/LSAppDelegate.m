//
//  LSAppDelegate.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSAppDelegate.h"
#import "LSUserManager.h"
#import "LSConversationViewController.h"
@implementation LSAppDelegate

NSString *const LSTestUser0FullName = @"Layer Tester0";
NSString *const LSTestUser0Email = @"tester0@layer.com";
NSString *const LSTestUser0Password = @"password0";
NSString *const LSTestUser0Confirmation = @"password0";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeSDKs];
    [self.window setRootViewController:[self rootViewController]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark
#pragma mark SDK Initialization Classes
- (void)initializeSDKs
{
    [self setLayerController:[[LSLayerController alloc] init]];
    [self setParseController:[[LSParseController alloc] init]];
}

- (void)setLayerController:(LSLayerController *)layerController
{
    if (_layerController != layerController) {
        _layerController = layerController;
    }
    [_layerController initializeLayerClientWithCompletion:^(NSError *error) {
        NSLog(@"Layer Client Initialized");
    }];
}

- (void)setParseController:(LSParseController *)parseController
{
    if (_parseController != parseController) {
        _parseController = parseController;
    }
}

- (UINavigationController *)rootViewController
{
    LSHomeViewController *homeViewController = [[LSHomeViewController alloc] init];
    homeViewController.layerController = self.layerController;
    
    return [[UINavigationController alloc] initWithRootViewController:homeViewController];
}
@end
