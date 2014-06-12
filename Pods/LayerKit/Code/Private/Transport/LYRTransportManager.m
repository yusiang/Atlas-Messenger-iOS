//
//  LYRTransportManager.m
//  LayerKit
//
//  Created by Blake Watters on 4/11/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRTransportManager.h"
#import <TMemoryBuffer.h>
#import "TCompactProtocol.h"
#import "LYRTransportErrors.h"
#import "LYRAuthenticationChallenge.h"
#import "LYRSPDYURLSessionProtocol.h"
#import "LYRHTTPResponseSerializer.h"
#import "LYRAuthenticationChallenge.h"
#import <SPDYProtocol.h>
#import <SPDYSessionManager.h>
#import "messaging.h"

NSInteger const LYRTransportDefaultMaxConcurrentRequests = 10;
NSInteger const LYRTransportDefaultRequestTimeout = 10;
NSString *const LYRTransportInitCheckEndpoint = @"init";
NSString *const LYRTransportHeaderFieldWWWAuthenticate = @"Www-Authenticate";
NSString *const LYRTransportHeaderFieldXLayerUserID = @"X-Layer-User-Id";
NSString *const LYRTransportHeaderFieldXLayerSessionToken = @"X-Layer-Session-Token";
NSString *const LYRTransportHeaderFieldXLayerSessionTTL = @"X-Layer-Session-Ttl";

// TODO: Move to LYRHTTP...
typedef NS_ENUM(NSUInteger, LYRTransportResponseStatus) {
    /**
     Returned when the remote service has successfully responded.
     */
    LYRTransportResponseStatusCodeOK = 200,
    /**
     Returned when the remote service has responded with an authentication challenge.
     */
    LYRTransportResponseStatusCodeUnauthorized = 401,
    /**
     Returned when the remote service has responded with an unrecoverable server error.
     */
    LYRTransportResponseStatusCodeServerError = 500,
};

static NSString *LYRAuthorizationHeaderFieldValueFromDictionary(NSDictionary *authorizationDictionary)
{
    return [NSString stringWithFormat:@"Layer realm=\"%@\", app-id=\"%@\", identity-token=\"%@\"", authorizationDictionary[@"realm"], authorizationDictionary[@"app-id"], authorizationDictionary[@"identity-token"]];
}

@interface LYRTransportManager () <NSURLSessionDelegate, SPDYTLSTrustEvaluator>
@property (nonatomic) NSOperationQueue *requestsQueue;
@property (nonatomic, readwrite) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic) NSURL *baseURL;
@property (nonatomic, readwrite) NSString *sessionToken;
@property (nonatomic) NSString *realm;
@end

@interface SPDYSessionManager (private)
+ (NSMutableDictionary *)_sessionPool:(bool)cellular;
@end

@implementation LYRTransportManager

- (id)initWithBaseURL:(NSURL *)baseURL appID:(NSUUID *)appID identity:(SecIdentityRef)identity sessionToken:(NSString *)sessionToken
{
    if (!baseURL) [NSException raise:NSInvalidArgumentException format:@"Cannot intialize a %@ without a `baseURL`.", [self class]];
    if (!appID) [NSException raise:NSInvalidArgumentException format:@"Cannot intialize a %@ without an `appID`.", [self class]];
    if (!identity) [NSException raise:NSInvalidArgumentException format:@"Cannot intialize a %@ without an `identity`.", [self class]];
    self = [super init];
    if (self) {
        _requestsQueue = [[NSOperationQueue alloc] init];
        _requestsQueue.maxConcurrentOperationCount = LYRTransportDefaultMaxConcurrentRequests;
        _baseURL = baseURL;
        _identity = identity;
        _sessionToken = sessionToken;
        _appID = appID;
        
        // Pre-configure NSURLSesssion to use SPDY protocol.
        _sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionConfiguration.protocolClasses = @[[LYRSPDYURLSessionProtocol class]];
        [self updateSessionConfigurationHTTPHeaders];
        LYRLogVerbose(@"initialized with baseURL:%@ sessionToken:%@ appID:%@", baseURL, sessionToken, appID.UUIDString);
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Failed to call designated initializer. Call `%@` instead", NSStringFromSelector(@selector(initWithBaseURL:appID:identity:sessionToken:))] userInfo:nil];
}

- (void)updateSessionConfigurationHTTPHeaders
{
    NSString *sessionTokenHeaderValue = [NSString stringWithFormat:@"Layer session-token=\"%@\"", self.sessionToken ? self.sessionToken : @"notdefined"];
    NSString *type = [NSString stringWithFormat:@"application/vnd.layer.messaging+thrift;version=%d", [LYRTmessagingConstants VERSION]];
    self.sessionConfiguration.HTTPAdditionalHeaders = @{ @"Authorization": sessionTokenHeaderValue, @"User-Agent": LYRHTTPUserAgentString(), @"Content-Type": type, @"Accept": type };
}

- (void)connectWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    // Configure SPDY configuration
    SPDYConfiguration *spdyConfiguration = [SPDYConfiguration defaultConfiguration];
    spdyConfiguration.enableSettingsMinorVersion = NO; // NPN override
    spdyConfiguration.tlsSettings = @{(NSString *)kCFStreamSSLValidatesCertificateChain:@(NO),
                                      (NSString *)kCFStreamSSLIsServer:@(NO),
                                      (NSString *)kCFStreamSSLLevel:(NSString *)kCFStreamSocketSecurityLevelTLSv1,
                                      (NSString *)kCFStreamSSLCertificates:@[(__bridge id)self.identity]};
    [SPDYProtocol setConfiguration:spdyConfiguration];
    [SPDYProtocol setTLSTrustEvaluator:self];

    // Create NSURLSession using the configurationn) {
    NSURLSession *URLSession = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:self.requestsQueue];

    // Make a first request to the server to see if we can establish
    // a connection using the certifice.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:LYRTransportInitCheckEndpoint relativeToURL:_baseURL]];
    request.HTTPMethod = @"GET";
    LYRLogInfo(@"connecting to: %@", request.URL);
    
    [[URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Validate any existing credentials
        NSError *noAuthChallengeError;
        LYRAuthenticationChallenge *challenge = [LYRAuthenticationChallenge authenticationChallengeWithResponse:response];
        if (!response && !challenge && !error) error = [NSError errorWithDomain:LYRTransportErrorDomain code:LYRTransportErrorUnprocessableResponse userInfo:@{ @"response": (response ?: [NSNull null]) }];
        else if (challenge) error = challenge.errorRespresentation;
        if ([self isConnected]) LYRLogInfo(@"connected");
        if (completion) completion(challenge == nil, error);
    }] resume];
    [URLSession finishTasksAndInvalidate];
}

- (void)disconnect
{
    // Close down all sessions (which results in a closed TCP socket)
    [[self SPDYSessions] makeObjectsPerformSelector:@selector(close)];
}

- (NSArray *)SPDYSessions
{
    return [LYRSPDYURLSessionProtocol sessions];
}

- (BOOL)isConnected
{
    // If there are any open sessions (TCP sockets open) method
    // should return YES; otherwise NO.
    NSArray *sessions = [self SPDYSessions];
    return [(NSNumber *)[sessions valueForKeyPath:@"@sum.isOpen"] integerValue];
}

- (void)deauthenticate
{
    self.sessionToken = nil;
    self.sessionConfiguration.HTTPAdditionalHeaders = @{ @"User-Agent": LYRHTTPUserAgentString() };
}

- (void)requestAuthenticationNonceWithCompletion:(void (^)(NSString *nonce, NSError *error))completion
{
    if (!completion) [NSException raise:NSInvalidArgumentException format:@"`completion` cannot be `nil`."];
    if (!self.isConnected) {
        NSError *error = [NSError errorWithDomain:LYRTransportErrorDomain code:LYRTransportErrorNotConnected userInfo:@{ NSLocalizedDescriptionKey: @"Cannot request authentication nonce: not connected." }];
        completion(nil, error);
        return;
    }
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfiguration.protocolClasses = @[[LYRSPDYURLSessionProtocol class]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:LYRTransportInitCheckEndpoint relativeToURL:_baseURL]];
    [request setValue:nil forHTTPHeaderField:@"Authorization"];
    
    NSURLSession *URLSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:self.requestsQueue];
    [[URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Validate any existing credentials
        NSError *noAuthChallengeError;
        LYRAuthenticationChallenge *challenge = [LYRAuthenticationChallenge authenticationChallengeWithResponse:response];
        if (challenge) {
            self.realm = challenge.realm;
        } else {
            noAuthChallengeError = [NSError errorWithDomain:LYRTransportErrorDomain code:LYRTransportErrorUnprocessableResponse userInfo:@{ @"response": (response ?: [NSNull null]) }];
        }
        if ([self isConnected]) {
            LYRLogInfo(@"connected");
        }
        if (completion) {
            completion(challenge.nonce, error ? error : noAuthChallengeError);
        }
    }] resume];
}

- (void)authenticateWithIdentityToken:(NSString *)identityToken completion:(void (^)(NSDictionary *authenticationInfo, NSError *error))completion
{
    if (!completion) [NSException raise:NSInvalidArgumentException format:@"Cannot perform authentication with a completion block."];
    if (!self.isConnected) {
        NSError *error = [NSError errorWithDomain:LYRTransportErrorDomain code:LYRTransportErrorNotConnected userInfo:@{ NSLocalizedDescriptionKey: @"Cannot request authentication nonce: not connected." }];
        completion(nil, error);
        return;
    }
    if (!self.realm) {
        NSError *error = [NSError errorWithDomain:LYRTransportErrorDomain code:LYRTransportErrorNoAuthenticationRealm userInfo:@{ NSLocalizedDescriptionKey: @"Cannot authenticate: no authentication realm has been established." }];
        completion(nil, error);
        return;
    }
    
    // Make an HTTP GET request with "Authorization" header field included
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:LYRTransportInitCheckEndpoint relativeToURL:_baseURL]];
    // Clear out the old session token, since we want to request a new one
    self.sessionToken = nil;
    [self updateSessionConfigurationHTTPHeaders];
    
    // Let's compose a string with realm, identity token and appID information
    NSString *headerFieldValue = LYRAuthorizationHeaderFieldValueFromDictionary(@{ @"realm": self.realm,
                                                                                   @"identity-token": identityToken,
                                                                                   @"app-id": self.appID.UUIDString.lowercaseString });
    [request setValue:headerFieldValue forHTTPHeaderField:@"Authorization"];
    
    // Perform the request
    NSURLSession *URLSession = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:self.requestsQueue];
    [[URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        switch (HTTPResponse.statusCode) {
            case LYRTransportResponseStatusCodeOK: {
                // Store session info, if it exists
                NSString *sessionToken = [HTTPResponse allHeaderFields][LYRTransportHeaderFieldXLayerSessionToken];
                NSString *sessionTTL = [HTTPResponse allHeaderFields][LYRTransportHeaderFieldXLayerSessionTTL];
                NSString *userID = [HTTPResponse allHeaderFields][LYRTransportHeaderFieldXLayerUserID];
                self.sessionToken = sessionToken;
                [self updateSessionConfigurationHTTPHeaders];
                NSUUID *userUUID = [[NSUUID alloc] initWithUUIDString:userID];
                NSDictionary *authenticationInfo = @{ @"sessionToken": sessionToken, @"TTL": sessionTTL, @"userID": userUUID };
                return completion(authenticationInfo, nil);
                break;
            }
            case LYRTransportResponseStatusCodeUnauthorized: {
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey:@"Authentication failed: invalid identity token.", @"identityToken":  identityToken };
                NSError *error = [NSError errorWithDomain:LYRTransportErrorDomain code:LYRTransportResponseStatusCodeUnauthorized userInfo:userInfo];
                completion(NO, error);
                break;
            }
            default: {
                completion(NO, error);
                break;
            }
        }
    }] resume];
    [URLSession finishTasksAndInvalidate];
}

#pragma mark SPDYTLSTrustEveluator delegate methods

- (BOOL)evaluateServerTrust:(SecTrustRef)trust forHost:(NSString *)host
{
    // TODO: evaluate server trust with the one in the keychain
    LYRLogWarn(@"TODO - should evaluate server trust for host: %@!", host);
    return YES;
}

@end
