//
//  LYRClient.m
//  LayerKit
//
//  Created by Klemen Verdnik on 7/23/13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

#import "LYRClient+Private.h"
#import "LYRIdentityToken.h"
#import "LYRSynchronizationManager.h"
#import "LYRSynchronizationErrors.h"
#import "LYRTransportManager.h"
#import "LYRTransportErrors.h"
#import "LYRConversation+Internal.h"
#import "LYRMessage+Internal.h"
#import "LYRErrors.h"

// DDLog specifics
#import <DDASLLogger.h>
#import <DDTTYLogger.h>
#import "LYRDDLogFormatter.h"

// Default baseURL when the client is initialized via `init`
static NSString *const LYRClientDefaultBaseURLString = @"https://localhost:7072";
static NSUInteger const LYRClientDefaultPort = 5555;
NSString *const LYRClientCryptographicKeyPairIdentifier = @"com.layer.LYRClient.keyPairIdentifier";

NSString *const LYRSessionFilename = @"LayerSession.plist";

NSString *const LYRClientErrorDomain = @"com.layer.LayerKit.Client";

NSString *const LYRClientDidAuthenticateNotification = @"LYRClientDidAuthenticateNotification";
NSString *const LYRClientAuthenticatedUserIDUserInfoKey = @"authenticatedUserID";
NSString *const LYRClientDidDeauthenticateNotification = @"LYRClientDidDeauthenticateNotification";

NSString *LYRApplicationDataDirectory(void)
{
#if TARGET_OS_IPHONE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
#else
    NSFileManager *sharedFM = [NSFileManager defaultManager];
    
    NSArray *possibleURLs = [sharedFM URLsForDirectory:NSApplicationSupportDirectory
                                             inDomains:NSUserDomainMask];
    NSURL *appSupportDir = nil;
    NSURL *appDirectory = nil;
    
    if ([possibleURLs count] >= 1) {
        appSupportDir = [possibleURLs objectAtIndex:0];
    }
    
    if (appSupportDir) {
        NSString *executableName = [[[NSBundle mainBundle] executablePath] lastPathComponent];
        appDirectory = [appSupportDir URLByAppendingPathComponent:executableName];
        return [appDirectory path];
    }
    
    return nil;
#endif
}

@interface LYRClient () <LYRSynchronizationManagerDelegate>
@end

@implementation LYRClient

+ (void)load
{
    // TODO: Compile and register logger only in case of #ifdef DEBUG
    // Register a logger for the Apple System Log facility (iOS console.app alternative).
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    // Register a logger for the XCode LLDB output console.
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    // Let's set our custom log formatter.
    [[DDASLLogger sharedInstance] setLogFormatter:[LYRDDLogFormatter new]];
    [[DDTTYLogger sharedInstance] setLogFormatter:[LYRDDLogFormatter new]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    // TODO: Pack version information inside a static lib (is now the time to go with our own podspec?)
    LYRLogInfo(@"LayerKit client v%@ loaded", @"0.0.0b");
}

+ (instancetype)clientWithAppID:(NSUUID *)appID
{
    return [[LYRClient alloc] initWithBaseURL:[NSURL URLWithString:LYRClientDefaultBaseURLString] appID:appID];
}

- (id)initWithBaseURL:(NSURL *)baseURL appID:(NSUUID *)appID
{
    if (!baseURL) [NSException raise:NSInvalidArgumentException format:@"Cannot initialize a client with a nil `baseURL`."];
    if (!appID) [NSException raise:NSInvalidArgumentException format:@"Cannot initialize a client with a nil `appID`."];
    self = [super init];
    if (self) {
        LYRLogVerbose(@"Initalizing with baseURL: %@", baseURL);
        _appID = appID;
        _baseURL = baseURL;
        _persistenceManager = [LYRSynchronizationDataSource dataSourceWithUpToDateDatabaseAtPath:nil];
        _synchronizationManager = [[LYRSynchronizationManager alloc] initWithBaseURL:self.baseURL sessionConfiguration:self.transportManager.sessionConfiguration datasource:_persistenceManager delegate:self];
        
        // Initialize authorization baseURL
        NSURLComponents *components = [NSURLComponents componentsWithURL:baseURL resolvingAgainstBaseURL:YES];
        components.scheme = @"http"; // TODO: This is no bueno.
        components.port = @(LYRClientDefaultPort);
        NSURL *authorizationBaseURL = [components URL];
        _cryptographer = [[LYRCryptographer alloc] initWithKeyPairIdentifier:LYRClientCryptographicKeyPairIdentifier authorizationBaseURL:authorizationBaseURL];

        // Attempt to load a previously persisted session. Authentication with Herald will be completed in callbacks, see `setupConnectionCallbacks`
        NSString *pathToPersistedSession = [LYRApplicationDataDirectory() stringByAppendingPathComponent:LYRSessionFilename];
        _session = [NSKeyedUnarchiver unarchiveObjectWithFile:pathToPersistedSession];
        LYRLogVerbose(@"Path to persisted session: %@", pathToPersistedSession);
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Failed to call designated initialized: invoke `%@` instead.", NSStringFromSelector(@selector(clientWithAppID:))]
                                 userInfo:nil];
}

#pragma mark - LYRClient specific

- (void)startTransportWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    NSError *error = nil;
    if (!self.cryptographer.keyPair) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Configuration error: Unable to find key pair in keychain." };
        error = [NSError errorWithDomain:LYRClientErrorDomain code:LYRClientErrorKeyPairNotFound userInfo:userInfo];
        if (completion) completion(NO, error);
        return;
    }
    
    if (!self.cryptographer.certificate) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Configuration error: Unable to find signed certificate in keychain." };
        error = [NSError errorWithDomain:LYRClientErrorDomain code:LYRClientErrorCertificateNotFound userInfo:userInfo];
        if (completion) completion(NO, error);
        return;
    }
    
    if (!self.cryptographer.identityRef) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Configuration error: Unable to find cryptographic identity in keychain." };
        error = [NSError errorWithDomain:LYRClientErrorDomain code:LYRClientErrorIdentityNotFound userInfo:userInfo];
        if (completion) completion(NO, error);
        return;
    }
    
    if (!self.transportManager) _transportManager = [[LYRTransportManager alloc] initWithBaseURL:self.baseURL appID:self.appID identity:self.cryptographer.identityRef sessionToken:self.session.token];

    self.synchronizationManager.sessionConfiguration = self.transportManager.sessionConfiguration;
    
    // TODO: MSG-28 We can't get a truthful value on how many SPDY sessions are currently open
    // That's why we don't have an isConnected check before calling the 'connect' on transport manager.
    [self.transportManager connectWithCompletion:^(BOOL success, NSError *error) {
        if (!success && error.code == LYRTransportErrorAuthenticationChallenge) {
            // Clear session state, since it's not valid anymore
            [self clearAuthenticationStateAndNotify:NO];
            // If we encounter an authentication challenge during connect we consider the connection a success, but invoke the delegate to handle the challenge.
            NSString *nonce = error.userInfo[LYRTransportErrorAuthenticationNonceUserInfoKey];
            [self.delegate layerClient:self didReceiveAuthenticationChallengeWithNonce:nonce];
            if (completion) completion(YES, nil);
            return;
        }
        if (completion) completion(success, error);
        if (success) LYRLogInfo(@"connected");
    }];
}

- (void)startWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    if (self.transportManager.isConnected) {
        NSError *error = [NSError errorWithDomain:LYRClientErrorDomain code:LYRClientErrorAlreadyConnected userInfo:@{ NSLocalizedDescriptionKey: @"The client is already connected." }];
        LYRLogWarn(@"will not continue. %@ already running", self);
        if (completion) completion(NO, error);
        return;
    }
    
    // Ensure we have cryptographic assets for handling any authentication challenges
    NSError *error = nil;
    if (!self.cryptographer.hasCryptographicAssets && ![self.cryptographer loadCryptographicAssetsFromKeychain:&error]) {
        [self.cryptographer obtainCryptographicAssets:^(BOOL success, NSError *error) {
            if (success) {
                LYRLogVerbose(@"obtained cryptographic assets");
                [self startTransportWithCompletion:completion];
            } else {
                // Failed trying to register cryptographic assets
                LYRLogError(@"failed to obtain cryptographic assets: %@", error);
                if (completion) completion(NO, error);
            }
        }];
        return;
    } else {
        [self startTransportWithCompletion:completion];
    }
}

- (void)stop
{
    [self.transportManager disconnect];
}

#pragma mark - User

- (BOOL)updateDeviceToken:(NSData *)deviceToken error:(NSError **)error
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not yet implement." userInfo:nil];
}

#pragma mark - Public Authentication

- (BOOL)isAuthenticated
{
    return self.session && !self.session.isExpired;
}

- (void)requestAuthenticationNonceWithCompletion:(void (^)(NSString *nonce, NSError *error))completion
{
    LYRLogVerbose(@"requested authentication nonce");
    [self.transportManager requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        if (nonce) {
            LYRLogVerbose(@"authentication nonce retreived: %@", nonce);
            completion(nonce, nil);
        } else {
            LYRLogWarn(@"failed to retreive authentication nonce %@", error);
            completion(nil, error);
        }
    }];
}

- (void)authenticateWithIdentityToken:(NSString *)identityTokenString completion:(void (^)(NSString *authenticatedUserID, NSError *error))completion
{
    LYRLogVerbose(@"requested authenticate with identity token: %@", identityTokenString);
    [self.transportManager authenticateWithIdentityToken:identityTokenString completion:^(NSDictionary *authenticationInfo, NSError *error) {
        LYRIdentityToken *identityToken = [LYRIdentityToken identityTokenFromJWSStringRepresentation:identityTokenString];
        if (authenticationInfo) {
            LYRLogVerbose(@"authenticated successfully: %@", authenticationInfo);
            LYRSession *session = [LYRSession sessionWithToken:authenticationInfo[@"sessionToken"]
                                                           TTL:[authenticationInfo[@"TTL"] integerValue]
                                                   layerUserID:authenticationInfo[@"userID"]
                                                providerUserID:identityToken.userID
                                                         appID:self.appID];
            self.session = session;
            NSString *pathToSave = [LYRApplicationDataDirectory() stringByAppendingPathComponent:LYRSessionFilename];
            if (![NSKeyedArchiver archiveRootObject:session toFile:pathToSave]) {
                [NSException raise:@"An error occurred while attempting to persist the session." format:@"Failed archiving to a file path: %@", pathToSave];
            }
            
            if ([self.delegate respondsToSelector:@selector(layerClient:didAuthenticateAsUserID:)]) {
                [self.delegate layerClient:self didAuthenticateAsUserID:identityToken.userID];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:LYRClientDidAuthenticateNotification object:self userInfo:@{ LYRClientAuthenticatedUserIDUserInfoKey: identityToken.userID }];
            
            // Update sync manager's session configuration
            self.synchronizationManager.sessionConfiguration = self.transportManager.sessionConfiguration;

            if (completion) completion(identityToken.userID, nil);
        } else {
            if (completion) completion(nil, error);
            LYRLogWarn(@"failed to authenticate with identity token:%@ appID:%@ %@", identityToken, _appID, error);
        }
    }];
}

- (void)deauthenticate
{
    LYRLogVerbose(@"requested deauthenticate");
    [self.transportManager deauthenticate];
    [self clearAuthenticationStateAndNotify:YES];
}

- (void)clearAuthenticationStateAndNotify:(BOOL)notify
{
    self.session = nil;
    [self.transportManager deauthenticate];
    LYRLogVerbose(@"clearing authentication state data file");
    NSString *persistedSessionPath = [LYRApplicationDataDirectory() stringByAppendingPathComponent:LYRSessionFilename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:persistedSessionPath]) {
        NSError *fileError = nil;
        if (![[NSFileManager defaultManager] removeItemAtPath:persistedSessionPath error:&fileError]) {
            LYRLogError(@"failed to remove persisted authentication state data file %@", fileError);
        }
    }
    if (notify) {
        if ([self.delegate respondsToSelector:@selector(layerClientDidDeauthenticate:)]) {
            [self.delegate layerClientDidDeauthenticate:self];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:LYRClientDidDeauthenticateNotification object:self];
    }
}

#pragma mark Conversations

- (LYRConversation *)conversationWithIdentifier:(NSString *)identifier participants:(NSArray *)participants
{
    LYRConversation *conversation = [LYRConversation new];
    conversation.participants = [NSSet setWithArray:participants];
    __block BOOL success;
    __block NSError *error;
    [self.persistenceManager inDatabase:^(FMDatabase *db) {
        success = [self.persistenceManager persistConversations:[NSSet setWithObject:conversation] toDatabase:db error:&error];
    }];
    if (!success) return nil;
    return conversation;
}

- (NSOrderedSet *)conversationsForIdentifiers:(NSArray *)conversationIdentifiers
{
    __block NSOrderedSet *conversations;
    [self.persistenceManager inDatabase:^(FMDatabase *db) {
        if (conversationIdentifiers) {
            conversations = [self.persistenceManager conversationsForIdentifiers:[NSOrderedSet orderedSetWithArray:conversationIdentifiers] inDatabase:db error:nil];
        } else {
            conversations = [NSOrderedSet orderedSetWithSet:[self.persistenceManager conversationsInDatabase:db error:nil]];
        }
    }];
    return conversations;
}

- (NSOrderedSet *)messagesForIdentifiers:(NSArray *)messageIdentifiers
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not yet implemented" userInfo:nil];
}

- (NSOrderedSet *)messagesForConversation:(LYRConversation *)conversation
{
    __block NSOrderedSet *messages;
    [self.persistenceManager inDatabase:^(FMDatabase *db) {
        messages = [self.persistenceManager messagesForConversation:conversation inDatabase:db error:nil];
    }];
    return messages;
}

#pragma mark Messages

- (LYRMessage *)messageWithConversation:(LYRConversation *)conversation parts:(NSArray *)messageParts
{
    LYRMessage *message = [LYRMessage messageWithDatabaseIdentifier:LYRSequenceNotDefined];
    message.conversation = conversation;
    message.parts = messageParts;
    message.sentByUserID = self.session.providerUserID;
    return message;
}

- (LYRMessage *)messageInReplyToMessage:(LYRMessage *)message withParts:(NSArray *)messageParts
{
    LYRMessage *reply = [LYRMessage messageWithDatabaseIdentifier:LYRSequenceNotDefined];
    reply.conversation = message.conversation;
    reply.parts = messageParts;
    reply.sentByUserID = self.session.providerUserID;
    return reply;
}

- (BOOL)sendMessage:(LYRMessage *)message error:(NSError **)error
{
    if (!message.conversation) {
        if (error) *error = [NSError errorWithDomain:LYRErrorDomain code:LYRErrorInvalidMessage userInfo:@{ NSLocalizedDescriptionKey: @"Cannot send a Message that is not part of a Conversation." }];
        return NO;
    }
    if (![message.parts count]) {
        if (error) *error = [NSError errorWithDomain:LYRErrorDomain code:LYRErrorInvalidMessage userInfo:@{ NSLocalizedDescriptionKey: @"Cannot send a Message without any parts." }];
        return NO;
    }
    
    __block BOOL success;
    __block NSError *outError;
    [self.persistenceManager performTransactionWithBlock:^(FMDatabase *db, BOOL *shouldRollback) {
        // Insert a message into the database
        success = [self.persistenceManager persistMessage:message toDatabase:db error:&outError];
        if (!success) return;
        
        // Insert a message order index for newly inserted message
        success = [self.persistenceManager addMessageOrderIndexForMessage:message inDatabase:db error:&outError];
        if (!success) return;
    }];
    if (error) *error = outError;
    return success;
}

#pragma mark - LYRSynchronizationManagerDelegate methods implementation

- (void)synchronizationManager:(LYRSynchronizationManager *)synchronizationManager didFailWithError:(NSError *)error
{
    if (error.code == LYRTransportErrorAuthenticationChallenge) {
        [self clearAuthenticationStateAndNotify:NO];
        NSString *nonce = error.userInfo[LYRTransportErrorAuthenticationNonceUserInfoKey];
        if ([self.delegate respondsToSelector:@selector(layerClient:didReceiveAuthenticationChallengeWithNonce:)]) {
            [self.delegate layerClient:self didReceiveAuthenticationChallengeWithNonce:nonce];
        }
    }
}

@end
