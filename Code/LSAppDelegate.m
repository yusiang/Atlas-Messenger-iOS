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

static void LSAlertWithError(NSError *error)
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unexpected Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


@interface LYRClient ()

- (id)initWithBaseURL:(NSURL *)baseURL appID:(NSUUID *)appID;

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
    
    LYRClient *layerClient = [[LYRClient alloc] initWithBaseURL:LSLayerBaseURL() appID:LSLayerAppID()];
    LSPersistenceManager *persistenceManager = LSIsRunningTests() ? [LSPersistenceManager persistenceManagerWithInMemoryStore] : [LSPersistenceManager persistenceManagerWithStoreAtPath:[LSApplicationDataDirectory() stringByAppendingPathComponent:@"PersistentObjects"]];
    
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
    self.navigationController.navigationBar.barTintColor = LSLighGrayColor();
    self.window.rootViewController = self.navigationController;
    
    LSSession *session = [self.applicationController.persistenceManager persistedSessionWithError:nil];
    
    if (session) {
        [self.APIManager resumeSession:session completion:^(LSUser *user, NSError *error) {
            if (user) {
                NSLog(@"Session resumed with user %@", user);
                [self presentConversationsListViewController];
            } else {
                NSLog(@"An error occurred while resuming session");
            }
        }];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
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
    [self.navigationController presentViewController:conversationController animated:YES completion:nil];
}

@end
