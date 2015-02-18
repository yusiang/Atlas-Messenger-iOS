//
//  ATLMApplicationController.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "ATLMApplicationController.h"
#import "ATLMUtilities.h"
#import <SVProgressHUD/SVProgressHUD.h>

NSString *const ATLMConversationMetadataDidChangeNotification = @"LSConversationMetadataDidChangeNotification";
NSString *const ATLMConversationParticipantsDidChangeNotification = @"LSConversationParticipantsDidChangeNotification";
NSString *const ATLMConversationDeletedNotification = @"LSConversationDeletedNotification";
NSString *const ATLMUserDefaultsLayerConfigurationURLKey = @"LAYER_CONFIGURATION_URL";
static NSString *const ATLMUserDefaultsShouldSendPushTextKey = @"shouldSendPushText";
static NSString *const ATLMUserDefaultsShouldSendPushSoundKey = @"shouldSendPushSound";
static NSString *const ATLMUserDefaultsShouldDisplayLocalNotificationKey = @"shouldDisplayLocalNotifications";
static NSString *const ATLMUserDefaultsDebugModeEnabledKey = @"debugModeEnabled";

@implementation ATLMApplicationController

+ (instancetype)controllerWithBaseURL:(NSURL *)baseURL layerClient:(ATLMLayerClient *)layerClient persistenceManager:(ATLMPersistenceManager *)persistenceManager
{
    NSParameterAssert(baseURL);
    NSParameterAssert(layerClient);
    return [[self alloc] initWithBaseURL:baseURL layerClient:layerClient persistenceManager:persistenceManager];
}

- (id)initWithBaseURL:(NSURL *)baseURL layerClient:(ATLMLayerClient *)layerClient persistenceManager:(ATLMPersistenceManager *)persistenceManager
{
    self = [super init];
    if (self) {
        _layerClient = layerClient;
        _layerClient.delegate = self;
        _persistenceManager = persistenceManager;
        _APIManager = [ATLMAPIManager managerWithBaseURL:baseURL layerClient:layerClient];
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
    ATLMUser *user = self.APIManager.authenticatedSession.user;
    if (!user) return;
    [self.APIManager authenticateWithEmail:user.email password:user.password nonce:nonce completion:^(NSString *identityToken, NSError *error) {
        if (error) {
            ATLMAlertWithError(error);
            return;
        }
        [self.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
            if (authenticatedUserID) {
                NSLog(@"Silent auth in response to auth challenge successfull");
            } else {
                ATLMAlertWithError(error);
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
        NSString *changedProperty = change[LYRObjectChangePropertyKey];

        if (changeType == LYRObjectChangeTypeUpdate && [changedProperty isEqualToString:@"metadata"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ATLMConversationMetadataDidChangeNotification object:changedObject];
        }

        if (changeType == LYRObjectChangeTypeUpdate && [changedProperty isEqualToString:@"participants"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ATLMConversationParticipantsDidChangeNotification object:changedObject];
        }

        if (changeType == LYRObjectChangeTypeDelete) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ATLMConversationDeletedNotification object:changedObject];
        }
    }
}

- (void)layerClient:(LYRClient *)client didFailOperationWithError:(NSError *)error
{
    NSLog(@"Layer Client did fail operation with error: %@", error);
    if (self.debugModeEnabled) {
        ATLMAlertWithError(error);
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
    NSString *configURLString = [[NSUserDefaults standardUserDefaults] objectForKey:ATLMUserDefaultsLayerConfigurationURLKey];
    NSURL *URL = [NSURL URLWithString:configURLString];
    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    return URLComponents.host;
}

#pragma mark - Application Settings Configuration

- (void)configureApplicationSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{
        ATLMUserDefaultsShouldSendPushTextKey: @YES,
        ATLMUserDefaultsShouldSendPushSoundKey: @YES,
        ATLMUserDefaultsShouldDisplayLocalNotificationKey: @NO,
        ATLMUserDefaultsDebugModeEnabledKey: @NO,
    }];
}

- (void)setShouldSendPushText:(BOOL)shouldSendPushText
{
    [self setApplicationSetting:shouldSendPushText forKey:ATLMUserDefaultsShouldSendPushTextKey];
}

- (void)setShouldSendPushSound:(BOOL)shouldSendPushSound
{
    [self setApplicationSetting:shouldSendPushSound forKey:ATLMUserDefaultsShouldSendPushSoundKey];
}

- (void)setShouldDisplayLocalNotifications:(BOOL)shouldDisplayLocalNotifications
{
    [self setApplicationSetting:shouldDisplayLocalNotifications forKey:ATLMUserDefaultsShouldDisplayLocalNotificationKey];
}

- (void)setDebugModeEnabled:(BOOL)debugModeEnabled
{
     [self setApplicationSetting:debugModeEnabled forKey:ATLMUserDefaultsDebugModeEnabledKey];
}

- (BOOL)shouldSendPushText
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:ATLMUserDefaultsShouldSendPushTextKey];
}

- (BOOL)shouldSendPushSound
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:ATLMUserDefaultsShouldSendPushSoundKey];
}

- (BOOL)shouldDisplayLocalNotifications
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:ATLMUserDefaultsShouldDisplayLocalNotificationKey];
}

- (BOOL)debugModeEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:ATLMUserDefaultsDebugModeEnabledKey];
}

- (void)setApplicationSetting:(BOOL)setting forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setBool:setting forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
