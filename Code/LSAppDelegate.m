//
//  LSAppDelegate.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <LayerKit/LayerKit.h>
#import <LayerKit/LYRLog.h>
#import <LayerKit/LYRTestUtilities.h>
#import "LSAppDelegate.h"
#import "LSConversationListViewController.h"
#import "LSAPIManager.h"
#import "LYRTestUtilities.h"
#import "LSUtilities.h"
#import "LSUIConstants.h"
#import "LYRConfiguration.h"
#import <Crashlytics/Crashlytics.h>

static void LSAlertWithError(NSError *error)
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unexpected Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


@interface LYRClient ()

- (id)initWithBaseURL:(NSURL *)baseURL appID:(NSUUID *)appID databasePath:(NSString *)path;
- (id)initWithConfiguration:(LYRConfiguration *)configuration appID:(NSUUID *)appID databasePath:(NSString *)path;

@end

@interface LSAppDelegate ()

@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) LSAPIManager *APIManager;
@property (nonatomic) LSPersistenceManager *persistenceManager;
@property (nonatomic) UINavigationController *navigationController;

@end

@implementation LSAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    LYRTestCleanKeychain();
    LYRSetLogLevelFromEnvironment();
    
    NSDictionary *configDictionary = @{ LYRConfigurationCertificationURLKey: @"http://10.66.0.12:5555/certificates",
                                        LYRConfigurationAuthenticationURLKey: @"https://10.66.0.12:7072/",
                                        LYRConfigurationMessagingURLKey: @"https://10.66.0.12:7072/" };
    
    LYRConfiguration *configuration = [LYRConfiguration configurationWithDictionary:configDictionary];
    
    //LYRClient *layerClient = [LYRClient clientWithAppID:LSLayerAppID()];
    LYRClient *layerClient = [[LYRClient alloc] initWithConfiguration:configuration appID:LSLayerAppID() databasePath:LSLayerPersistencePath()];
    LSPersistenceManager *persistenceManager = LSPersitenceManager();
    
    self.applicationController = [LSApplicationController controllerWithBaseURL:LSRailsBaseURL() layerClient:layerClient persistenceManager:persistenceManager];
    
    [self.applicationController.layerClient startWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"Started with success: %d, %@", success, error);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidAuthenticateNotification:) name:LSUserDidAuthenticateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeauthenticateNotification:) name:LSUserDidDeauthenticateNotification object:nil];
    
    LSAuthenticationViewController *authenticationViewController = [LSAuthenticationViewController new];
    authenticationViewController.layerClient = self.applicationController.layerClient;
    authenticationViewController.APIManager = self.applicationController.APIManager;
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:authenticationViewController];
    self.navigationController.navigationBarHidden = TRUE;
    self.navigationController.navigationBar.barTintColor = LSLighGrayColor();
    self.navigationController.navigationBar.tintColor = LSBlueColor();
    self.window.rootViewController = self.navigationController;
    
    LSSession *session = [self.applicationController.persistenceManager persistedSessionWithError:nil];
    
    if (session) {
        [self.applicationController.APIManager resumeSession:session completion:^(LSUser *user, NSError *error) {
            if (user) {
                NSLog(@"Session resumed with user %@", user);
                [self presentConversationsListViewController];
            } else {
                NSLog(@"An error occurred while resuming session");
            }
        }];
    }
    
    [self.window makeKeyAndVisible];
    
    //Kicking off Crashlytics
    [Crashlytics startWithAPIKey:@"0a0f48084316c34c98d99db32b6d9f9a93416892"];
    
    //Declaring that I want to recieve push!
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    
    return YES;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Application failed to register for remote notifications with error %@", error);
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
//    NSError *error;
//    BOOL success = [self.applicationController.layerClient updateDeviceToken:deviceToken error:&error];
//    if (success) {
//        NSLog(@"Application did register for remote notifications");
//    } else {
//        NSLog(@"Error updating Layer device token for push:%@", error);
//    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    //TODO: Implement once LayerKit supports.
}

- (void)userDidAuthenticateNotification:(NSNotification *)notification
{
    NSError *error = nil;
    LSSession *session = self.applicationController.APIManager.authenticatedSession;
    BOOL success = [self.applicationController.persistenceManager persistSession:session error:&error];
    if (success) {
        NSLog(@"Persisted authenticated user session: %@", session);
    } else {
        NSLog(@"Failed persisting authenticated user: %@. Error: %@", session, error);
        LSAlertWithError(error);
    }

    [self loadContacts];
    [self presentConversationsListViewController];
}

- (void)userDidDeauthenticateNotification:(NSNotification *)notification
{
    NSError *error = nil;
    BOOL success = [self.applicationController.persistenceManager persistSession:nil error:&error];
    if (success) {
        NSLog(@"Cleared persisted user session");
    } else {
        NSLog(@"Failed clearing persistent user session: %@", error);
        LSAlertWithError(error);
    }
    
    [self.applicationController.layerClient deauthenticate];
    [self.navigationController dismissViewControllerAnimated:YES completion:NO];
}

- (void)loadContacts
{
    NSLog(@"Loading contacts...");
    [self.applicationController.APIManager loadContactsWithCompletion:^(NSSet *contacts, NSError *error) {
        if (contacts) {
            NSError *persistenceError = nil;
            BOOL success = [self.applicationController.persistenceManager persistUsers:contacts error:&persistenceError];
            if (success) {
                NSLog(@"Persisted contacts successfully: %@", contacts);
            } else {
                NSLog(@"Failed persisting contacts: %@. Error: %@", contacts, persistenceError);
                LSAlertWithError(persistenceError);
            }
        } else {
            NSLog(@"Failed loading contacts: %@", error);
            LSAlertWithError(error);
        }
    }];
}

- (void)presentConversationsListViewController
{    
    LSConversationListViewController *conversationListViewController = [LSConversationListViewController new];
    conversationListViewController.layerClient = self.applicationController.layerClient;
    conversationListViewController.APIManager = self.applicationController.APIManager;
    conversationListViewController.persistenceManager = self.applicationController.persistenceManager;
    UINavigationController *conversationController = [[UINavigationController alloc] initWithRootViewController:conversationListViewController];
    conversationController.navigationBar.barTintColor = LSLighGrayColor();
    conversationController.navigationBar.tintColor = LSBlueColor();
    [self.navigationController presentViewController:conversationController animated:YES completion:nil];
}

@end
