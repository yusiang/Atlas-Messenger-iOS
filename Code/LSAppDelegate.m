//
//  LSAppDelegate.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <LayerKit/LayerKit.h>
#import "LSAppDelegate.h"
#import "LSUIConversationListViewController.h"
#import "LSAPIManager.h"
#import "LSUtilities.h"
#import "LYRUIConstants.h"
#import <Crashlytics/Crashlytics.h>
#import <HockeySDK/HockeySDK.h>
#import "LSAuthenticationTableViewController.h"
#import "LSSplashView.h"

extern void LYRSetLogLevelFromEnvironment();

@interface LSAppDelegate ()

@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic) LSAuthenticationTableViewController *authenticationViewController;
@property (nonatomic) LSSplashView *splashView;

@end

@implementation LSAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        LSAlertWithError([NSError new]);
        NSLog(@"app recieved notification from remote%@",notification);
        [self application:application didReceiveRemoteNotification:(NSDictionary*)notification];
    }else{
        NSLog(@"app did not recieve notification");
    }
   
    // Set LayerKit log level
    LYRSetLogLevelFromEnvironment();
    
    // Setup environment configuration
    LSEnvironment environment = LSTestEnvironment;
    
    // Kicking off Crashlytics
    [Crashlytics startWithAPIKey:@"0a0f48084316c34c98d99db32b6d9f9a93416892"];
    
    // Setup notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidAuthenticateNotification:) name:LSUserDidAuthenticateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeauthenticateNotification:) name:LSUserDidDeauthenticateNotification object:nil];
    
    // Configure application controllers
    LYRClient *layerClient = [LYRClient clientWithAppID:LSLayerAppID(environment)];
    LSPersistenceManager *persistenceManager = LSPersitenceManager();
    self.applicationController = [LSApplicationController controllerWithBaseURL:LSRailsBaseURL() layerClient:layerClient persistenceManager:persistenceManager];
    
    // Ask LayerKit to connect

    __weak LSApplicationController *wController = self.applicationController;
    [self.applicationController.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
            LSAlertWithError(error);
            [self.splashView animateLogoWithCompletion:^{
                [self removeSplashView];
            }];
        }
        if (success) {
            NSLog(@"Layer Client is connected");
            LSSession *session = [wController.persistenceManager persistedSessionWithError:nil];
            [self updateCrashlyticsWithUser:session.user];
            NSError *error;
            // If we have a session, resume
            if ([wController.APIManager resumeSession:session error:&error]) {
                NSLog(@"Session resumed: %@", session);
                [self loadContacts];
                [self presentConversationsListViewController];
                // If we have an authenticated user ID and no session, we must log out
            } else if (wController.layerClient.authenticatedUserID){
                [self.applicationController.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
                    NSLog(@"Encountered error while resuming session but Layer client is authenticated. Deauthenticating client...");
                    [self.splashView animateLogoWithCompletion:^{
                        [self removeSplashView];
                    }];
                }];
            } else {
                [self.splashView animateLogoWithCompletion:^{
                    [self removeSplashView];
                }];
            }
        }
    }];
    
    self.authenticationViewController = [LSAuthenticationTableViewController new];
    self.authenticationViewController.applicationController = self.applicationController;
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.authenticationViewController];
    self.navigationController.navigationBarHidden = TRUE;
    self.navigationController.navigationBar.barTintColor = LSLighGrayColor();
    self.navigationController.navigationBar.tintColor = LSBlueColor();
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    self.splashView = [[LSSplashView alloc] initWithFrame:self.window.bounds];
    [self.window addSubview:self.splashView];
    
    // Update the app ID and configuration URL in the crash metadata.
    [Crashlytics setObjectValue:LSLayerConfigurationURL(environment) forKey:@"ConfigurationURL"];
    [Crashlytics setObjectValue:LSLayerAppID(environment) forKey:@"AppID"];
    
//    // Start HockeyApp
//    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"1681559bb4230a669d8b057adf8e4ae3"];
//    [BITHockeyManager sharedHockeyManager].disableCrashManager = YES;
//    [[BITHockeyManager sharedHockeyManager] startManager];
//    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    
    // Declaring that I want to recieve push!
//    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
//        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound
//                                                                                             categories:nil];
//        [application registerUserNotificationSettings:notificationSettings];
//        [application registerForRemoteNotifications];
//    } else {
//        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
//    }
    
    [self configureGlobalUserInterfaceAttributes];
    
    [self getUnreadMessageCount];
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
    // Coming back to the foreground so we refresh the contact list
    [self loadContacts];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Application failed to register for remote notifications with error %@", error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Registering for Push Failed" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    self.applicationController.deviceToken = deviceToken;
    NSError *error;
    BOOL success = [self.applicationController.layerClient updateRemoteNotificationDeviceToken:deviceToken error:&error];
    if (success) {
        NSLog(@"Application did register for remote notifications");
    } else {
        NSLog(@"Error updating Layer device token for push:%@", error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Updating Device Token Failed" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    __block NSURL *messageID = [NSURL URLWithString:[[userInfo valueForKeyPath:@"layer.event_url"] uppercaseString]];
    NSError *error;
    BOOL success = [self.applicationController.layerClient synchronizeWithRemoteNotification:userInfo completion:^(UIBackgroundFetchResult fetchResult, NSError *error) {
        if (fetchResult == UIBackgroundFetchResultFailed) {
            NSLog(@"Failed processing remote notification: %@", error);
        }
        completionHandler(fetchResult);
    }];
    if (success) {
        NSLog(@"Application did complete remote notification sync");
    } else {
        NSLog(@"Error handling push notification: %@", error);
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
    {
        
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
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    self.viewController = [LSUIConversationListViewController conversationListViewControllerWithLayerClient:self.applicationController.layerClient];
    self.viewController.applicationController = self.applicationController;
    self.viewController.allowsEditing = FALSE;
    self.viewController.showsConversationImage = FALSE;
    
    UINavigationController *conversationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    [self.navigationController presentViewController:conversationController animated:YES completion:^{
        [self.authenticationViewController resetState];
        [self removeSplashView];
    }];
    
}

- (void)removeSplashView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.splashView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.splashView removeFromSuperview];
        self.splashView = nil;
    }];
}

- (void)configureGlobalUserInterfaceAttributes
{
    [[UINavigationBar appearance] setTintColor:LSBlueColor()];
    [[UINavigationBar appearance] setBarTintColor:LSLighGrayColor()];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18]}];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:LSBlueColor()];

}

- (void)getUnreadMessageCount
{
    __block NSUInteger unreadMessage = 0;
    __block NSString *userID = self.applicationController.layerClient.authenticatedUserID;
    NSSet *conversations = [self.applicationController.layerClient conversationsForIdentifiers:nil];
    for (LYRConversation *conversation in conversations) {
        NSOrderedSet *messages = [self.applicationController.layerClient messagesForConversation:conversation];
        for (LYRMessage *message in messages) {
            LYRRecipientStatus status = (LYRRecipientStatus)[message.recipientStatusByUserID objectForKey:userID];
            if (status == LYRRecipientStatusDelivered) {
                unreadMessage += 1;
            }
        }
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadMessage];
}

@end
