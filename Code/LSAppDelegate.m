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
#import "LSLocalNotificationUtilities.h"
#import "LSPartnerAPIManager.h"

extern void LYRSetLogLevelFromEnvironment();
extern NSString *LYRApplicationDataDirectory(void);
extern dispatch_once_t LYRConfigurationURLOnceToken;

void LYRTestResetConfiguration(void)
{
    extern dispatch_once_t LYRDefaultConfigurationDispatchOnceToken;
    
    NSString *archivePath = [LYRApplicationDataDirectory() stringByAppendingPathComponent:@"LayerConfiguration.plist"];
    [[NSFileManager defaultManager] removeItemAtPath:archivePath error:nil];
    
    // Ensure the next call through `LYRDefaultConfiguration` will reload
    LYRDefaultConfigurationDispatchOnceToken = 0;
    LYRConfigurationURLOnceToken = 0;
}

@interface LSAppDelegate () <LSAuthenticationTableViewControllerDelegate>

@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic) UINavigationController *authenticatedNavigationController;
@property (nonatomic) LSAuthenticationTableViewController *authenticationViewController;
@property (nonatomic) LSSplashView *splashView;
@property (nonatomic) LSEnvironment environment;
@property (nonatomic) LSLocalNotificationUtilities *localNotificationUtilities;

@end

@interface LYRClient ()

@property (nonatomic) NSURL *configurationURL;
- (void)refreshConfiguration;

@end

@implementation LSAppDelegate

@synthesize window;

// Fake Commit to build an app
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup environment configuration
    [self configureApplication:application forEnvironment:LYRUIProduction];
    LYRSetLogLevelFromEnvironment();
    
    // Setup notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidAuthenticateNotification:)
                                                 name:LSUserDidAuthenticateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidDeauthenticateNotification:)
                                                 name:LSUserDidDeauthenticateNotification
                                               object:nil];
    // Setup application
    [self setRootViewController];
    
    // Setup SDKs
    [self initializeCrashlytics];
    [self initializeHockeyApp];
    
    // Setup Screenshot Listener for Bugs
    [self setupScreenShotListener];

    // Configure Sample App UI Appearance
    [self configureGlobalUserInterfaceAttributes];
    
    // ConversationListViewController Config
    _cellClass = [LYRUIConversationTableViewCell class];
    _rowHeight = 72;
    _allowsEditing = NO;
    _displaysConversationImage = NO;
    _displaysSettingsButton = YES;
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self.localNotificationUtilities setShouldListenForChanges:NO];
    [self resumeSession];
    [self loadContacts];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSUInteger unreadMessageCount = [self.applicationController.layerClient countOfUnreadMessagesInConversation:nil];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadMessageCount];
    if (self.applicationController.shouldDisplayLocalNotifications) {
        [self.localNotificationUtilities setShouldListenForChanges:YES];
    }
}

#pragma mark - Setup Methods

- (void)setRootViewController
{
    self.authenticationViewController = [LSAuthenticationTableViewController new];
    self.authenticationViewController.applicationController = self.applicationController;
    self.authenticationViewController.delegate = self;
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.authenticationViewController];
    self.navigationController.navigationBarHidden = TRUE;
    self.navigationController.navigationBar.barTintColor = LSLighGrayColor();
    self.navigationController.navigationBar.tintColor = LSBlueColor();
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    [self addSplashView];
}

- (void)configureApplication:(UIApplication *)application forEnvironment:(LSEnvironment)environment
{
    self.environment = environment;
    
    // Configure Layer Base URL
    NSString *configURLString = LSLayerConfigurationURL(self.environment);
    NSString *currentConfigURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"LAYER_CONFIGURATION_URL"];
    if (![currentConfigURL isEqualToString:configURLString]) {
        [[NSUserDefaults standardUserDefaults] setObject:LSLayerConfigurationURL(self.environment) forKey:@"LAYER_CONFIGURATION_URL"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    LYRTestResetConfiguration();
    
    // Configure application controllers
    LYRClient *client = [LYRClient clientWithAppID:LSLayerAppID(self.environment)];
    self.applicationController = [LSApplicationController controllerWithBaseURL:LSRailsBaseURL()
                                                                    layerClient:client
                                                             persistenceManager:LSPersitenceManager()];
    
    self.localNotificationUtilities = [LSLocalNotificationUtilities initWithLayerClient:self.applicationController.layerClient];
    self.authenticationViewController.applicationController = self.applicationController;
    
    // Connect Layer SDK
    [self.applicationController.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
            NSLog(@"Error connecting Layer: %@", error);
        } else {
            NSLog(@"Layer Client is connected");
            if (self.applicationController.layerClient.authenticatedUserID) {
                if ([self resumeSession]) {
                    [self presentConversationsListViewController];
                } else {
                    [self.applicationController.layerClient deauthenticateWithCompletion:nil];
                }
            }
        }
        [self removeSplashView];
    }];
    
    [self registerForRemoteNotifications:application];
}

- (BOOL)resumeSession
{
    LSSession *session = [self.applicationController.persistenceManager persistedSessionWithError:nil];
    if ([self.applicationController.APIManager resumeSession:session error:nil]) {
        return YES;
    }
    return NO;
}

#pragma mark - Push Notification Setup and Handlers
/**
 
 LAYER - In order to register for push notifications, your application must first declare the types of
 notifications it wishes to receive. This method handles doing so for both iOS7 and iOS8.
 
 */
- (void)registerForRemoteNotifications:(UIApplication *)application
{
    // Declaring that I want to recieve push!
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound
                                                                                             categories:nil];
        [application registerUserNotificationSettings:notificationSettings];
        [application registerForRemoteNotifications];
    } else {
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Application failed to register for remote notifications with error %@", error);
}

/**
 
 LAYER - When a user succesfully grants your application permission to receive push, the OS will call
 the following method. In your implementation of this method, your applicaiton should pass the 
 `Device Token` property to the `LYRClient` object.
 
 */
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

/**
 
 LAYER - The following method gets called at 2 different times that interest a Layer powered application. 
 
 1. When your application receives a push notification from Layer. Upon receiving a push, your application should 
 pass the `userInfo` dictionary to the `sychronizeWithRemoteNotification:completion: method. 
 
 2. When your application comes out of the background in response to a user opening the app from a push notification. 
 Your application can tell if it is coming our of the backroung by evaluating `application.applicationState`. If the 
 state is `UIApplicationSateInactive`, your application is coming out of the background and into the foreground.
 
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // Increment badge count if a message
    if ([[userInfo valueForKeyPath:@"aps.content-available"] integerValue] == 0) {
        NSInteger badgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber + 1];
    }
    
    __block LYRMessage *message = [self messageFromRemoteNotification:userInfo];
    if (application.applicationState == UIApplicationStateInactive && message) {
        [self navigateToConversationViewForMessage:message.conversation];
    }
    
    BOOL success = [self.applicationController.layerClient synchronizeWithRemoteNotification:userInfo completion:^(UIBackgroundFetchResult fetchResult, NSError *error) {
        if (fetchResult == UIBackgroundFetchResultFailed) {
            NSLog(@"Failed processing remote notification: %@", error);
        }
        
        // Try navigating once the synchronization completed
        if (application.applicationState == UIApplicationStateInactive && !message) {
            message = [self messageFromRemoteNotification:userInfo];
            [self navigateToConversationViewForMessage:message.conversation];
        }
        completionHandler(fetchResult);
    }];
    
    if (!success) {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (LYRMessage *)messageFromRemoteNotification:(NSDictionary *)remoteNotification
{
    // Fetch message object from LayerKit
    NSURL *messageURL = [NSURL URLWithString:[remoteNotification valueForKeyPath:@"layer.event_url"]];
    NSSet *messages = [self.applicationController.layerClient messagesForIdentifiers:[NSSet setWithObject:messageURL]];
    return [[messages allObjects] firstObject];
}

- (void)navigateToConversationViewForMessage:(LYRConversation *)conversation
{
    UINavigationController *controller = (UINavigationController *)self.window.rootViewController.presentedViewController;
    LSUIConversationListViewController *conversationListViewController = [controller.viewControllers objectAtIndex:0];
    [conversationListViewController selectConversation:conversation];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    LYRConversation *conversation;
    NSURL *objectURL = [NSURL URLWithString:[notification.userInfo objectForKey:LSNotificationIdentifierKey]];
    NSString *objectTypeString = [notification.userInfo valueForKey:LSNotificationClassTypeKey];
    
    if ([objectTypeString isEqualToString:LSNotificationClassTypeConversation]) {
        conversation = [self.applicationController.layerClient conversationForIdentifier:objectURL];
    } else {
        NSSet *messages = [self.applicationController.layerClient messagesForIdentifiers:[NSSet setWithObject:objectURL]];
        LYRMessage *message = [[messages allObjects] firstObject];
        conversation = message.conversation;
    }
    if (application.applicationState == UIApplicationStateInactive && conversation) {
        [self navigateToConversationViewForMessage:conversation];
    }
}

#pragma mark - SDK Initializers

- (void)initializeCrashlytics
{
    [Crashlytics startWithAPIKey:@"0a0f48084316c34c98d99db32b6d9f9a93416892"];
    [Crashlytics setObjectValue:LSLayerConfigurationURL(self.environment) forKey:@"ConfigurationURL"];
    [Crashlytics setObjectValue:LSLayerAppID(self.environment) forKey:@"AppID"];
}

- (void)initializeHockeyApp
{
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"1681559bb4230a669d8b057adf8e4ae3"];
    [BITHockeyManager sharedHockeyManager].disableCrashManager = YES;
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
}

- (void)updateCrashlyticsWithUser:(LSUser *)authenticatedUser
{
    // Note: If authenticatedUser is nil, this will nil out everything which is what we want.
    [Crashlytics setUserName:authenticatedUser.fullName];
    [Crashlytics setUserEmail:authenticatedUser.email];
    [Crashlytics setUserIdentifier:authenticatedUser.userID];
}

#pragma mark - Screen Shot Listener

- (void)setupScreenShotListener
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenshotTaken:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
}

#pragma mark - Authentication Methods

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
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        self.viewController = nil;
        self.authenticatedNavigationController = nil;
    }];
}

- (void)loadContacts
{
    [self.applicationController.APIManager loadContactsWithCompletion:^(NSSet *contacts, NSError *error) {
        if (contacts) {
            NSError *persistenceError = nil;
            BOOL success = [self.applicationController.persistenceManager persistUsers:contacts error:&persistenceError];
            if (success) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"contactsPersited" object:nil];
            } else {
                LSAlertWithError(persistenceError);
            }
        } else {
            LSAlertWithError(error);
        }
    }];

}

- (void)presentConversationsListViewController
{
    if (self.window.rootViewController.presentedViewController) {
        [self removeSplashView];
        return;
    }
    self.viewController = [LSUIConversationListViewController conversationListViewControllerWithLayerClient:self.applicationController.layerClient];
    self.viewController.applicationController = self.applicationController;
    self.viewController.displaysConversationImage = self.displaysConversationImage;
    self.viewController.cellClass = self.cellClass;
    self.viewController.rowHeight = self.rowHeight;
    self.viewController.allowsEditing = self.allowsEditing;
    self.viewController.shouldDisplaySettingsItem = self.displaysSettingsButton;
    
    self.authenticatedNavigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    [self.navigationController presentViewController:self.authenticatedNavigationController animated:YES completion:^{
        [self.authenticationViewController resetState];
        [self removeSplashView];
    }];
}

#pragma mark - Splash View Config

- (void)addSplashView
{
    if (!self.splashView) {
        self.splashView = [[LSSplashView alloc] initWithFrame:self.window.bounds];
    }
    [self.window addSubview:self.splashView];
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

#pragma mark - UI Config

- (void)configureGlobalUserInterfaceAttributes
{
    [[UINavigationBar appearance] setTintColor:LSBlueColor()];
    [[UINavigationBar appearance] setBarTintColor:LSLighGrayColor()];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: LSBoldFont(18)}];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSFontAttributeName : LSMediumFont(16)} forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:LSBlueColor()];

}

#pragma mark - Screen Shot Handler
- (void)screenshotTaken:(NSNotification *)notification
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Report Issue?"
                                                        message:@"Would you like to report a bug with the sample app?"
                                                       delegate:self
                                              cancelButtonTitle:@"Not Now" otherButtonTitles:@"Yes", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
//            LSPartnerAPIManager *manager = [LSPartnerAPIManager managerWithBaseURL:[NSURL URLWithString:@"https://layerhq.atlassian.net"]];
//            [manager attachImage:[UIImage imageNamed:@"testImage"] toIssue:nil];
        }
            break;
        case 1:
            //
            break;
        default:
            break;
    }
}

#pragma mark - Authentaction Controller Delegate Methods

- (void)authenticationTableViewController:(LSAuthenticationTableViewController *)authenticationTabelViewController didSelectEnvironment:(LSEnvironment)environment
{
    if (self.applicationController.layerClient.isConnected) {
        [self.applicationController.layerClient disconnect];
    }
    [self configureApplication:[UIApplication sharedApplication] forEnvironment:environment];
}

@end
