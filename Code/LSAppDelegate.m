//
//  LSAppDelegate.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <LayerKit/LayerKit.h>
#import "LSAppDelegate.h"
#import "LSUserManager.h"
#import "LSConversationViewController.h"
#import "LSAuthenticationManager.h"

@interface LYRClient ()

- (id)initWithBaseURL:(NSURL *)baseURL appID:(NSUUID *)appID;

@end

@interface LSAppDelegate ()

@property (nonatomic) LYRClient *layerClient;

@end

@implementation LSAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURL *baseURL = [NSURL URLWithString:@"https://10.66.0.35:7072"];
    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-1000-8000-000000000000"];
    LYRClient *layerClient = [[LYRClient alloc] initWithBaseURL:baseURL appID:appID];
    self.layerClient = layerClient;
    
    [layerClient startWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"Started with success: %d, %@", success, error);
    }];
    
    LSAuthenticationManager *authenticationManager = [[LSAuthenticationManager alloc] initWithBaseURL:@"http://10.66.0.35:8080/" layerClient:layerClient];
    if (authenticationManager.authToken) {
        [authenticationManager resumeSessionWithCompletion:^(LSUser *user, NSError *error) {
            
        }];
    } else {
        LSHomeViewController *homeViewController = [LSHomeViewController new];
        homeViewController.layerClient = self.layerClient;
        homeViewController.authenticationManager = authenticationManager;
        
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
        [self.window makeKeyAndVisible];
    }
    
    return YES;
}

@end
