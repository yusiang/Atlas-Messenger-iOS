//
//  LSAppDelegate.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <LayerKit/LayerKit.h>
#import "LSAppDelegate.h"
#import "LSConversationListViewController.h"
#import "LSAPIManager.h"
#import "LSUtilities.h"
#import "LSUIConstants.h"
#import <Crashlytics/Crashlytics.h>
#import <Instabug/Instabug.h>
#import <HockeySDK/HockeySDK.h>

NSData *LYRIssuerData(void)
{
    static NSString *issuerInBase64 = @"MQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ0FMSUZPUk5JQTEWMBQGA1UEBxMNU0FOIEZSQU5DSVNDTzEOMAwGA1UEChMFTEFZRVIxFjAUBgNVBAsTDVBMQVRGT1JNIFRFQU0xEjAQBgNVBAMTCUxBWUVSLkNPTTEcMBoGCSqGSIb3DQEJARYNZGV2QGxheWVyLmNvbQ==";
    static NSData *layerCertificateIssuer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        layerCertificateIssuer = [[NSData alloc] initWithBase64EncodedString:issuerInBase64 options:0];
    });
    return layerCertificateIssuer;
}

void LYRTestDeleteKeysFromKeychain(void)
{
    NSDictionary *query = @{ (__bridge id)kSecClass: (__bridge id)kSecClassKey,
                             (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA };
    
    OSStatus err = SecItemDelete((__bridge CFDictionaryRef)query);
    if(!(err == noErr || err == errSecItemNotFound)) {
        NSLog(@"SecItemDeleteError: %d", (int)err);
    }
}

BOOL LYRTestDeleteCertificatesFromKeychain(void)
{
    NSDictionary *query = @{ (__bridge id)kSecClass: (__bridge id)kSecClassCertificate,
                             (__bridge id)kSecAttrIssuer: LYRIssuerData() };
    
    OSStatus err = SecItemDelete((__bridge CFDictionaryRef)query);
    if(!(err == noErr || err == errSecItemNotFound)) {
        NSLog(@"SecItemDeleteError: %d", (int)err);
        return NO;
    }
    return YES;
}

BOOL LYRTestDeleteIdentitiesFromKeychain(void)
{
    NSDictionary *query = @{ (__bridge id)kSecClass: (__bridge id)kSecClassIdentity,
                             (__bridge id)kSecAttrIssuer: LYRIssuerData() };
    OSStatus err = SecItemDelete((__bridge CFDictionaryRef)query);
    if(!(err == noErr || err == errSecItemNotFound)) {
        NSLog(@"SecItemDeleteError: %d", (int)err);
        return NO;
    }
    return YES;
}

void LYRTestCleanKeychain(void)
{
    LYRTestDeleteKeysFromKeychain();
    LYRTestDeleteCertificatesFromKeychain();
    LYRTestDeleteIdentitiesFromKeychain();
}

extern void LYRSetLogLevelFromEnvironment();

@interface LSAppDelegate ()

@property (nonatomic) UINavigationController *navigationController;

@end

@implementation LSAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    LYRSetLogLevelFromEnvironment();
    LYRTestCleanKeychain();
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidAuthenticateNotification:) name:LSUserDidAuthenticateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeauthenticateNotification:) name:LSUserDidDeauthenticateNotification object:nil];
    
    // Set Layer backend via configuration URL
    [[NSUserDefaults standardUserDefaults] setObject:@"https://na-3.preview.layer.com/client_configuration.json" forKey:@"LAYER_CONFIGURATION_URL"];
    
    LYRClient *layerClient = [LYRClient clientWithAppID:LSLayerAppID()];
    LSPersistenceManager *persistenceManager = LSPersitenceManager();
    
    self.applicationController = [LSApplicationController controllerWithBaseURL:LSRailsBaseURL() layerClient:layerClient persistenceManager:persistenceManager];
    
    [self.applicationController.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"Started with success: %d, %@", success, error);
    }];

    LSAuthenticationViewController *authenticationViewController = [LSAuthenticationViewController new];
    authenticationViewController.layerClient = self.applicationController.layerClient;
    authenticationViewController.APIManager = self.applicationController.APIManager;
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:authenticationViewController];
    self.navigationController.navigationBarHidden = TRUE;
    self.navigationController.navigationBar.barTintColor = LSLighGrayColor();
    self.navigationController.navigationBar.tintColor = LSBlueColor();
    self.window.rootViewController = self.navigationController;
    
    LSSession *session = [self.applicationController.persistenceManager persistedSessionWithError:nil];
    
    NSError *error = nil;
    if ([self.applicationController.APIManager resumeSession:session error:&error]) {
        NSLog(@"Session resumed: %@", session);
        [self loadContacts];
        [self presentConversationsListViewController];
    }
    
    [self.window makeKeyAndVisible];
    
    // Kicking off Crashlytics
    [Crashlytics startWithAPIKey:@"0a0f48084316c34c98d99db32b6d9f9a93416892"];

    // Start HockeyApp
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"1681559bb4230a669d8b057adf8e4ae3"];
    [BITHockeyManager sharedHockeyManager].disableCrashManager = YES;
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];

    // Kicking off Instabug
    [Instabug startWithToken:@"d17f36fc46f0b8073b5db3feb2d09888" captureSource:IBGCaptureSourceUIKit invocationEvent:IBGInvocationEventShake];

    // Declaring that I want to recieve push!
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadContacts) name:@"loadContacts" object:nil];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self loadContacts];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Application failed to register for remote notifications with error %@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSError *error;
    BOOL success = [self.applicationController.layerClient updateRemoteNotificationDeviceToken:deviceToken error:&error];
    if (success) {
        NSLog(@"Application did register for remote notifications");
    } else {
        NSLog(@"Error updating Layer device token for push:%@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSError *error;
    BOOL success = [self.applicationController.layerClient synchronizeWithRemoteNotification:userInfo completion:^(UIBackgroundFetchResult fetchResult, NSError *error) {
        if (fetchResult == UIBackgroundFetchResultFailed) {
            NSLog(@"Failed processing remote notification: %@", error);
        }
        completionHandler(fetchResult);
    }];
    if (success) {
        NSLog(@"Application did remote notification sycn");
    } else {
        NSLog(@"Error handling push notification: %@", error);
        completionHandler(UIBackgroundFetchResultNoData);
    }
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
    
    [self.applicationController.layerClient deauthenticateWithCompletion:NULL];
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
                [[NSNotificationCenter defaultCenter] postNotificationName:@"contactsPersited" object:nil];
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
    [self.navigationController presentViewController:conversationController animated:YES completion:^{
        //
    }];
    //[self.navigationController presentViewController:conversationController animated:YES completion:nil];
}

@end
