//
//  LSAppController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSApplicationController.h"
#import "LSUtilities.h"
#import <SVProgressHUD/SVProgressHUD.h>

NSString *const LSConversationDeletedNotification = @"LSConversationDeletedNotification";
NSString *const LSUserDefaultsLayerConfigurationURLKey = @"LAYER_CONFIGURATION_URL";
static NSString *const LSUserDefaultsShouldSendPushTextKey = @"shouldSendPushText";
static NSString *const LSUserDefaultsShouldSendPushSoundKey = @"shouldSendPushSound";
static NSString *const LSUserDefaultsShouldDisplayLocalNotificationKey = @"shouldDisplayLocalNotifications";
static NSString *const LSUserDefaultsDebugModeEnabledKey = @"debugModeEnabled";

@implementation LSApplicationController

+ (instancetype)controllerWithBaseURL:(NSURL *)baseURL layerClient:(LSLayerClient *)layerClient persistenceManager:(LSPersistenceManager *)persistenceManager
{
    NSParameterAssert(baseURL);
    NSParameterAssert(layerClient);
    return [[self alloc] initWithBaseURL:baseURL layerClient:layerClient persistenceManager:persistenceManager];
}

- (id)initWithBaseURL:(NSURL *)baseURL layerClient:(LSLayerClient *)layerClient persistenceManager:(LSPersistenceManager *)persistenceManager
{
    self = [super init];
    if (self) {
        _layerClient = layerClient;
        _layerClient.delegate = self;
        _persistenceManager = persistenceManager;
        _APIManager = [LSAPIManager managerWithBaseURL:baseURL layerClient:layerClient];
        [self configureApplicationSettings];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveLayerClientWillBeginSynchronizationNotification:)
                                                     name:LYRClientWillBeginSynchronizationNotification
                                                   object:layerClient];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveLayerClientDidFinishSynchronizationNotification:)
                                                     name:LYRClientDidFinishSynchronizationNotification
                                                   object:layerClient];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - LYRClientDelegate

- (void)layerClient:(LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce
{
    NSLog(@"Layer Client did recieve authentication challenge with nonce: %@", nonce);
    LSUser *user = self.APIManager.authenticatedSession.user;
    if (!user) return;
    [self.APIManager authenticateWithEmail:user.email password:user.password nonce:nonce completion:^(NSString *identityToken, NSError *error) {
        if (error) {
            LSAlertWithError(error);
            return;
        }
        [self.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
            if (authenticatedUserID) {
                NSLog(@"Silent auth in response to auth challenge successfull");
            } else {
                LSAlertWithError(error);
            }
        }];
    }];
}

- (void)layerClient:(LYRClient *)client didAuthenticateAsUserID:(NSString *)userID
{
    NSLog(@"Layer Client did recieve authentication nonce");
}

- (void)layerClientDidDeauthenticate:(LYRClient *)client
{
    [self.APIManager deauthenticate];
    NSLog(@"Layer Client did deauthenticate");
}

- (void)layerClient:(LYRClient *)client objectsDidChange:(NSArray *)changes
{
    NSLog(@"Layer Client objects did change");
    for (NSDictionary *change in changes) {
        id changedObject = change[LYRObjectChangeObjectKey];
        if (![changedObject isKindOfClass:[LYRConversation class]]) continue;

        LYRObjectChangeType changeType = [change[LYRObjectChangeTypeKey] integerValue];
        if (changeType != LYRObjectChangeTypeDelete) continue;

        [[NSNotificationCenter defaultCenter] postNotificationName:LSConversationDeletedNotification object:changedObject];
    }
}

- (void)layerClient:(LYRClient *)client didFailOperationWithError:(NSError *)error
{
    NSLog(@"Layer Client did fail operation with error: %@", error);
    if (self.debugModeEnabled) {
        LSAlertWithError(error);
    }
}

- (void)layerClient:(LYRClient *)client willAttemptToConnect:(NSUInteger)attemptNumber afterDelay:(NSTimeInterval)delayInterval maximumNumberOfAttempts:(NSUInteger)attemptLimit
{
    if (self.debugModeEnabled) {
        if (attemptNumber == 1) {
            [SVProgressHUD showWithStatus:@"Connecting to Layer"];
        } else {
            [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Connecting to Layer in %lus (%lu of %lu)", (unsigned long)ceil(delayInterval), (unsigned long)attemptNumber, (unsigned long)attemptLimit]];
        }
    }
}

- (void)layerClientDidConnect:(LYRClient *)client
{
    if (self.debugModeEnabled) {
        [SVProgressHUD showSuccessWithStatus:@"Connected to Layer"];
    }
}

- (void)layerClient:(LYRClient *)client didLoseConnectionWithError:(NSError *)error
{
    if (self.debugModeEnabled) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Lost Connection: %@", error.localizedDescription]];
    }
}

- (void)layerClientDidDisconnect:(LYRClient *)client
{
    if (self.debugModeEnabled) {
        [SVProgressHUD showSuccessWithStatus:@"Disconnected from Layer"];
    }
}

#pragma mark - Notification Handlers

- (void)didReceiveLayerClientWillBeginSynchronizationNotification:(NSNotification *)notification
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didReceiveLayerClientDidFinishSynchronizationNotification:(NSNotification *)notification
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Class Getters

+ (NSString *)versionString
{
    NSDictionary *infoDictionary = [NSBundle mainBundle].infoDictionary;
    NSString *marketingVersion = infoDictionary[@"CFBundleShortVersionString"];
    NSString *bundleVersion = infoDictionary[@"CFBundleVersion"];
    NSDictionary *layerKitBuildInformation = infoDictionary[@"LYRBuildInformation"];
    NSString *layerKitVersion = layerKitBuildInformation[@"LYRBuildLayerKitVersion"];

    NSMutableString *versionString = [[NSMutableString alloc] initWithFormat:@"LayerSample v%@ (%@)", marketingVersion, bundleVersion];
    if (layerKitVersion) {
        [versionString appendFormat:@" - LayerKit v%@", layerKitVersion];
    }
    
    return versionString;
}

+ (NSString *)buildInformationString
{
    NSDictionary *buildInformation = [NSBundle mainBundle].infoDictionary[@"LYRBuildInformation"];
    
    if (!buildInformation) {
        return [NSString stringWithFormat:@"Non-Release Build"];
    }
    
    NSString *buildSHA = buildInformation[@"LYRBuildShortSha"];
    NSString *builderName = buildInformation[@"LYRBuildBuilderName"];
    NSString *builderEmail = buildInformation[@"LYRBuildBuilderEmail"];
    
    return [NSString stringWithFormat:@"Built by %@ (%@) SHA: %@", builderName, builderEmail, buildSHA];
}

+ (NSString *)layerServerHostname
{
    NSString *configURLString = [[NSUserDefaults standardUserDefaults] objectForKey:LSUserDefaultsLayerConfigurationURLKey];
    NSURL *URL = [NSURL URLWithString:configURLString];
    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    return URLComponents.host;
}

#pragma mark - Application Settings Configuration

- (void)configureApplicationSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{
        LSUserDefaultsShouldSendPushTextKey: @YES,
        LSUserDefaultsShouldSendPushSoundKey: @YES,
        LSUserDefaultsShouldDisplayLocalNotificationKey: @NO,
        LSUserDefaultsDebugModeEnabledKey: @NO,
    }];
}

- (void)setShouldSendPushText:(BOOL)shouldSendPushText
{
    [self setApplicationSetting:shouldSendPushText forKey:LSUserDefaultsShouldSendPushTextKey];
}

- (void)setShouldSendPushSound:(BOOL)shouldSendPushSound
{
    [self setApplicationSetting:shouldSendPushSound forKey:LSUserDefaultsShouldSendPushSoundKey];
}

- (void)setShouldDisplayLocalNotifications:(BOOL)shouldDisplayLocalNotifications
{
    [self setApplicationSetting:shouldDisplayLocalNotifications forKey:LSUserDefaultsShouldDisplayLocalNotificationKey];
}

- (void)setDebugModeEnabled:(BOOL)debugModeEnabled
{
     [self setApplicationSetting:debugModeEnabled forKey:LSUserDefaultsDebugModeEnabledKey];
}

- (BOOL)shouldSendPushText
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:LSUserDefaultsShouldSendPushTextKey];
}

- (BOOL)shouldSendPushSound
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:LSUserDefaultsShouldSendPushSoundKey];
}

- (BOOL)shouldDisplayLocalNotifications
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:LSUserDefaultsShouldDisplayLocalNotificationKey];
}

- (BOOL)debugModeEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:LSUserDefaultsDebugModeEnabledKey];
}

- (void)setApplicationSetting:(BOOL)setting forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setBool:setting forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
