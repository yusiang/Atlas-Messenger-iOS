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

@property (nonatomic) LSLayerController *layerController;

@end

@implementation LSAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURL *baseURL = [NSURL URLWithString:@"https://10.66.0.35:7072"];
    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-1000-8000-000000000000"];
    LYRClient *client = [[LYRClient alloc] initWithBaseURL:baseURL appID:appID];
    
//    NSURL *baseURL = [NSURL URLWithString:@"https://10.66.0.35:7072"];
//<<<<<<< HEAD
//    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-1000-0000-000000000000"];
//    
//=======
//    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-1000-8000-000000000000"];
//>>>>>>> 1a72deec0a13ca3933bdde3cbea2451333347377
//    LYRClient *client = [[LYRClient alloc] initWithBaseURL:baseURL appID:appID];
    
    [client startWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"Started with success: %d, %@", success, error);
    }];
    
    self.layerController = [[LSLayerController alloc] initWithClient:client];
    
    LSAuthenticationManager *authenticationManager = [[LSAuthenticationManager alloc] initWithBaseURL:@"http://10.66.0.35:8080/"];
    authenticationManager.layerController= self.layerController;
    
    if (authenticationManager.authToken) {
        [authenticationManager resumeSessionWithCompletion:^(BOOL success, NSError *error) {
            //
        }];
    } else {
        LSHomeViewController *homeViewController = [[LSHomeViewController alloc] init];
        homeViewController.layerController = self.layerController;
        homeViewController.authenticationManager = authenticationManager;
        
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
        [self.window makeKeyAndVisible];
    }
    

    
    return YES;
}

@end
