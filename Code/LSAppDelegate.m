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

static void LSAlertWithError(NSError *error)
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unexpected Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

static BOOL LSIsRunningTests(void)
{
    return NSClassFromString(@"XCTestCase") != Nil;
}

static NSString *LSApplicationDataDirectory(void)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
}

static NSURL *LSLayerBaseURL(void)
{
    if (LSIsRunningTests()) {
        NSString *environmentHost = [NSProcessInfo processInfo].environment[@"LAYER_TEST_HOST"];
        if (environmentHost) {
            return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@:7072", environmentHost]];
        }
    }
    return [NSURL URLWithString:@"https://10.66.0.35:7072"];
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
    
    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-1000-8000-000000000000"];
    LYRClient *layerClient = [[LYRClient alloc] initWithBaseURL:LSLayerBaseURL() appID:appID];
    self.layerClient = layerClient;
    
    [layerClient startWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"Started with success: %d, %@", success, error);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidAuthenticateNotification:) name:LSUserDidAuthenticateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeauthenticateNotification:) name:LSUserDidDeauthenticateNotification object:nil];
    
    self.persistenceManager = LSIsRunningTests() ? [LSPersistenceManager persistenceManagerWithInMemoryStore] : [LSPersistenceManager persistenceManagerWithStoreAtPath:[LSApplicationDataDirectory() stringByAppendingPathComponent:@"PersistentObjects"]];
    self.APIManager = [LSAPIManager managerWithBaseURL:[NSURL URLWithString:@"http://10.66.0.35:8080/"] layerClient:layerClient];
    
    LSAuthenticationViewController *authenticationViewController = [LSAuthenticationViewController new];
    authenticationViewController.layerClient = self.layerClient;
    authenticationViewController.APIManager = self.APIManager;
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:authenticationViewController];
    self.window.rootViewController = self.navigationController;
    
    LSSession *session = [self.persistenceManager persistedSessionWithError:nil];
    if (session) {
        [self.APIManager resumeSession:session completion:^(LSUser *user, NSError *error) {
            if (user) {
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
    LSSession *session = self.APIManager.authenticatedSession;
    BOOL success = [self.persistenceManager persistSession:session error:&error];
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
    BOOL success = [self.persistenceManager persistSession:nil error:&error];
    if (success) {
        NSLog(@"Cleared persisted user session");
    } else {
        NSLog(@"Failed clearing persistent user session: %@", error);
        LSAlertWithError(error);
    }
    
    [self.layerClient deauthenticate];
    [self.navigationController dismissViewControllerAnimated:YES completion:NO];
}

- (void)loadContacts
{
    NSLog(@"Loading contacts...");
    [self.APIManager loadContactsWithCompletion:^(NSSet *contacts, NSError *error) {
        if (contacts) {
            NSError *persistenceError = nil;
            BOOL success = [self.persistenceManager persistUsers:contacts error:&persistenceError];
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
    conversationListViewController.layerClient = self.layerClient;
    conversationListViewController.APIManager = self.APIManager;
    conversationListViewController.persistenceManager = self.persistenceManager;
    UINavigationController *conversationController = [[UINavigationController alloc] initWithRootViewController:conversationListViewController];
    [self.navigationController presentViewController:conversationController animated:YES completion:nil];
}

@end
