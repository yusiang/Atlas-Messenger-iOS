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
#import <HockeySDK/HockeySDK.h>
#import "LSConversationListViewController.h"

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
    // Kicking off Crashlytics
    
    LSEnvironment environment = LSDevelopmentEnvironment;
    
    [Crashlytics startWithAPIKey:@"0a0f48084316c34c98d99db32b6d9f9a93416892"];
    
    LYRSetLogLevelFromEnvironment();
   
    NSString *currentConfigURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"LAYER_CONFIGURATION_URL"];
    if (![currentConfigURL isEqualToString:LSLayerConfigurationURL(environment)]) {
        LYRTestCleanKeychain();
        [[NSUserDefaults standardUserDefaults] setObject:LSLayerConfigurationURL(environment) forKey:@"LAYER_CONFIGURATION_URL"];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidAuthenticateNotification:) name:LSUserDidAuthenticateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeauthenticateNotification:) name:LSUserDidDeauthenticateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadContacts) name:@"loadContacts" object:nil];
    
    LYRClient *layerClient = [LYRClient clientWithAppID:LSLayerAppID(environment)];
    LSPersistenceManager *persistenceManager = LSPersitenceManager();
    
    self.applicationController = [LSApplicationController controllerWithBaseURL:LSRailsBaseURL() layerClient:layerClient persistenceManager:persistenceManager];
    
    __block LSApplicationController *wController = self.applicationController;
    [self.applicationController.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"Layer Client is connected");
            LSSession *session = [wController.persistenceManager persistedSessionWithError:nil];
            [self updateCrashlyticsWithUser:session.user];
            NSError *error = nil;
            if ([wController.APIManager resumeSession:session error:&error]) {
                NSLog(@"Session resumed: %@", session);
                [self loadContacts];
                [self presentConversationsListViewController];
            } else if (wController.layerClient.authenticatedUserID){
                [self.applicationController.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
                    NSLog(@"Encountered error while resuming session but Layer client is authenticated. Deauthenticating client...");
                }];
            }
        }
    }];

    LSAuthenticationViewController *authenticationViewController = [LSAuthenticationViewController new];
    authenticationViewController.layerClient = self.applicationController.layerClient;
    authenticationViewController.APIManager = self.applicationController.APIManager;
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:authenticationViewController];
    self.navigationController.navigationBarHidden = TRUE;
    self.navigationController.navigationBar.barTintColor = LSLighGrayColor();
    self.navigationController.navigationBar.tintColor = LSBlueColor();
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    // update the app ID and configuration URL in the crash metadata.
    [Crashlytics setObjectValue:LSLayerConfigurationURL(environment) forKey:@"ConfigurationURL"];
    [Crashlytics setObjectValue:LSLayerAppID(environment) forKey:@"AppID"];

    // Start HockeyApp
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"1681559bb4230a669d8b057adf8e4ae3"];
    [BITHockeyManager sharedHockeyManager].disableCrashManager = YES;
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];

    // Declaring that I want to recieve push!
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    
    return YES;
}

- (void)updateCrashlyticsWithUser:(LSUser *)authenticatedUser
{
    // Note: If authenticatedUser is nil, this will nil out everything which is what we want.
    [Crashlytics setUserName:authenticatedUser.fullName];
    [Crashlytics setUserEmail:authenticatedUser.email];
    [Crashlytics setUserIdentifier:authenticatedUser.userID];
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

    [self updateCrashlyticsWithUser:session.user];

    [self loadContacts];
    [self presentConversationsListViewController];
}

- (void)userDidDeauthenticateNotification:(NSNotification *)notification
{
    NSError *error = nil;
    BOOL success = [self.applicationController.persistenceManager persistSession:nil error:&error];

    // nil out all crashlytics user information.
    [self updateCrashlyticsWithUser:nil];

    if (success) {
        NSLog(@"Cleared persisted user session");
    } else {
        NSLog(@"Failed clearing persistent user session: %@", error);
        LSAlertWithError(error);
    }

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
    conversationListViewController.applicationController = self.applicationController;
    conversationListViewController.layerClient = self.applicationController.layerClient;
    conversationListViewController.APIManager = self.applicationController.APIManager;
    conversationListViewController.persistenceManager = self.applicationController.persistenceManager;
    
    UINavigationController *conversationController = [[UINavigationController alloc] initWithRootViewController:conversationListViewController];
    conversationController.navigationBar.barTintColor = LSLighGrayColor();
    conversationController.navigationBar.tintColor = LSBlueColor();
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSFontAttributeName: LSMediumFont(14)}];
    [self.navigationController presentViewController:conversationController animated:YES completion:^{
        //
    }];
}

@end
