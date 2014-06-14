//
//  LYRTestingContext.m
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRTestingContext.h"
#import "LYRTestUtilities.h"
#import "LYRCountDownLatch.h"
#import "LYRTestSPDYTrustEvaluator.h"
#import "LYRLog.h"
#import "messaging.h"
#import "LYRTransportManager.h"
#import "LYRSPDYURLSessionProtocol.h"

extern NSString *const LYRClientCryptographicKeyPairIdentifier;
NSString *LYRHTTPUserAgentString();

@interface LYRTestingContext ()
@property (nonatomic, strong) NSMutableDictionary *authenticatedSessionsByUserID;
@property (nonatomic, readonly) LYRTransportManager *transportManager;
@end

@implementation LYRTestingContext

+ (instancetype)sharedContext
{
    static LYRTestingContext *sharedContext;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedContext = [LYRTestingContext new];
    });
    return sharedContext;
}

- (id)init
{
    self = [super init];
    if (self) {
        _authenticatedSessionsByUserID = [NSMutableDictionary new];
        _provider = LYRSharedTestProvider();
        _cryptographer = [[LYRCryptographer alloc] initWithKeyPairIdentifier:LYRClientCryptographicKeyPairIdentifier authorizationBaseURL:LYRTestHTTPBaseURL()];
        LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10.0];
        [_cryptographer obtainCryptographicAssets:^(BOOL success, NSError *error) {
            if (!success) LYRLogError(@"Failed obtaining cryptographic assets: %@", error);
            [latch decrementCount];
        }];
        [latch waitTilCount:0];
        
        _transportManager = [[LYRTransportManager alloc] initWithBaseURL:LYRTestSPDYBaseURL() appID:_provider.primaryAppID identity:_cryptographer.identityRef sessionToken:nil];
        
        SPDYConfiguration *spdyConfiguration = [SPDYConfiguration defaultConfiguration];
        spdyConfiguration.enableSettingsMinorVersion = NO; // NPN override
        spdyConfiguration.tlsSettings = @{ (NSString *)kCFStreamSSLValidatesCertificateChain: @(NO),
                                           (NSString *)kCFStreamSSLIsServer: @(NO),
                                           (NSString *)kCFStreamSSLLevel: (NSString *)kCFStreamSocketSecurityLevelTLSv1,
                                           (NSString *)kCFStreamSSLCertificates: @[ (__bridge id)_cryptographer.identityRef ] };
        [SPDYProtocol setConfiguration:spdyConfiguration];
        [SPDYProtocol setTLSTrustEvaluator:[LYRTestSPDYTrustEvaluator sharedTrustEvaluator]];
    }
    return self;
}

- (NSUUID *)appID
{
    return self.provider.primaryAppID;
}

- (SecIdentityRef)identity
{
    return self.cryptographer.identityRef;
}

- (void)connect
{
    if (!self.transportManager.isConnected) {
        LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10.0];
        [self.transportManager connectWithCompletion:^(BOOL success, NSError *error) {
            if (!success) {
                LYRLogError(@"Failed to establish connection to remote host: %@", error);
            }
            [latch decrementCount];
        }];
        [latch waitTilCount:0];
    }
}

- (LYRSession *)authenticatedSessionWithUserID:(NSString *)userID
{
    __block LYRSession *session = self.authenticatedSessionsByUserID[userID];
    if (session) return session;
    
    [self connect];
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:2 timeoutInterval:5.0];
    NSString *authenticatedUserID = userID ?: [[NSUUID UUID] UUIDString];
    userID = userID ?: authenticatedUserID;
    [self.transportManager requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        [latch decrementCount];
        if (nonce) {
            NSString *identityToken = [self.provider JWSIdentityTokenForUserID:authenticatedUserID nonce:nonce];
            [self.transportManager authenticateWithIdentityToken:identityToken completion:^(NSDictionary *authenticationInfo, NSError *error) {
                if (authenticationInfo) {
                    session = [LYRSession sessionWithToken:authenticationInfo[@"sessionToken"]
                                                       TTL:[authenticationInfo[@"TTL"] integerValue]
                                                layerUserID:authenticationInfo[@"userID"]
                                            providerUserID:authenticatedUserID
                                                     appID:self.provider.primaryAppID];
                    self.authenticatedSessionsByUserID[userID] = session;
                } else {
                    LYRLogError(@"Failed authentication with identityToken '%@': %@", identityToken, error);
                }
                [latch decrementCount];
            }];
        } else {
            LYRLogError(@"Failed to obtain nonce: %@", error);
        }
    }];
    [latch waitTilCount:0];
    if (latch.count != 0) LYRLogError(@"Failed obtaining authenticated user ID: %@", userID);
    return session;
}

- (NSURLSessionConfiguration *)URLSessionConfigurationWithSession:(LYRSession *)session
{
    LYRSession *sessionForConfiguration = session ?: [self authenticatedSessionWithUserID:nil];
    NSString *sessionTokenHeaderValue = [NSString stringWithFormat:@"Layer session-token=\"%@\"", sessionForConfiguration.token];
    NSString *type = [NSString stringWithFormat:@"application/vnd.layer.messaging+thrift;version=%d", [LYRTmessagingConstants VERSION]];

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{ @"Authorization": sessionTokenHeaderValue, @"User-Agent": LYRHTTPUserAgentString(), @"Content-Type": type, @"Accept": type };
    configuration.protocolClasses = @[[LYRSPDYURLSessionProtocol class]];
    return configuration;
}

- (BOOL)identityExistsInKeychain
{
    NSDictionary *query = @{ (__bridge id)kSecClass: (__bridge id)kSecClassIdentity,
                             (__bridge id)kSecAttrIssuer: [LYRCertificate issuerData],
                             (__bridge id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPrivate };
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    return (status == noErr);
}

- (BOOL)saveCryptographicAssetsToKeychain:(NSError **)error
{
    BOOL success;
    if (![self.cryptographer.keyPair existsInKeychain]) {
        success = [self.cryptographer.keyPair saveToKeychain:error];
        if (!success) return NO;
    }
    if (![self.cryptographer.certificate existsInKeychain]) {
        success = [self.cryptographer.certificate saveToKeychain:error];
        if (!success) return NO;
    }
    
    if (![self identityExistsInKeychain]) {
        /**
         NOTE: Major WTF ahead. For whatever reason if you save a SecIdentityRef to the Keychain and specify
         the `kSecClass` it will not work. You must insert the identity alone.
         */
        NSDictionary *attributes = @{ (__bridge id)kSecValueRef: (__bridge id)self.cryptographer.identityRef };
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
        if (status != noErr) {
            if (error) *error = [NSError errorWithDomain:LYRSecurityErrorDomain code:status userInfo:nil];
            return NO;
        }
    }
    return YES;
}

@end
