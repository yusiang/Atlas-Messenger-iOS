//
//  LSAPIManager.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSAPIManager.h"
#import "LSUser.h"
#import "LSHTTPResponseSerializer.h"
#import "LSErrors.h"

NSString *const LSUserDidAuthenticateNotification = @"LSUserDidAuthenticateNotification";
NSString *const LSUserDidDeauthenticateNotification = @"LSUserDidDeauthenticateNotification";

@interface LSAPIManager () <NSURLSessionDelegate>

@property (nonatomic, readonly) LYRClient *layerClient;
@property (nonatomic) NSURL *baseURL;
@property (nonatomic) NSURLSession *URLSession;

@end

@implementation LSAPIManager

+ (instancetype)managerWithBaseURL:(NSURL *)baseURL layerClient:(LYRClient *)layerClient
{
    NSParameterAssert(baseURL);
    NSParameterAssert(layerClient);
    return [[self alloc] initWithBaseURL:baseURL layerClient:layerClient];
}

- (id)initWithBaseURL:(NSURL *)baseURL layerClient:(LYRClient *)layerClient
{
    self = [super init];
    if (self) {
        _baseURL = baseURL;
        _layerClient = layerClient;
        _URLSession = [self defaultURLSession];
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}

- (NSURLSession *)defaultURLSession
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{@"Accept": @"application/json", @"Content-Type": @"application/json", @"X_LAYER_APP_ID": self.layerClient.appID.UUIDString};
    return [NSURLSession sessionWithConfiguration:configuration];
}

#pragma mark - Public Authentication Methods

- (void)registerUser:(LSUser *)user completion:(void (^)(LSUser *user, NSError *error))completion
{
    NSParameterAssert(completion);
    
    NSError *error;
    if (![user validate:&error]) {
        completion(nil, error);
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:@"users.json" relativeToURL:self.baseURL];
    NSDictionary *parameters = @{@"user": @{@"first_name": user.firstName, @"last_name": user.lastName, @"email": user.email, @"password": user.password, @"password_confirmation": user.passwordConfirmation}};
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!response && error) {
            NSLog(@"Failed with error: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        NSError *serializationError;
        NSDictionary *userDetails;
        BOOL success = [LSHTTPResponseSerializer responseObject:&userDetails withData:data response:(NSHTTPURLResponse *)response error:&serializationError];
        if (success) {
            user.userID = userDetails[@"id"];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(user, serializationError);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, serializationError);
            });
        }
    }] resume];
}

- (void)authenticateWithEmail:(NSString *)email password:(NSString *)password nonce:(NSString *)nonce completion:(void (^)(NSString *identityToken, NSError *error))completion;
{
    NSParameterAssert(completion);
    
    if (!email.length) {
        NSError *error = [NSError errorWithDomain:LSErrorDomain code:LSInvalidEmailAddress userInfo:@{NSLocalizedDescriptionKey: @"Please enter your Email address in order to Login"}];
        completion(nil, error);
        return;
    }
    
    if (!password.length) {
        NSError *error = [NSError errorWithDomain:LSErrorDomain code:LSInvalidPassword userInfo:@{NSLocalizedDescriptionKey: @"Please enter your password in order to login"}];
        completion(nil, error);
        return;
    }
    
    if (!nonce.length) {
        NSError *error = [NSError errorWithDomain:LSErrorDomain code:LSInvalidAuthenticationNonce userInfo:@{NSLocalizedDescriptionKey: @"Application must supply authenticate nonce to complete"}];
        completion(nil, error);
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:@"users/sign_in.json" relativeToURL:self.baseURL];
    NSDictionary *parameters = @{@"user": @{@"email": email, @"password": password}, @"nonce": nonce};
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!response && error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        NSError *serializationError;
        NSDictionary *loginInfo;
        BOOL success = [LSHTTPResponseSerializer responseObject:&loginInfo withData:data response:(NSHTTPURLResponse *)response error:&serializationError];
        if (!success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, serializationError);
            });
        } else {
            NSString *authToken = loginInfo[@"authentication_token"];
            LSUser *user = [LSUser userFromDictionaryRepresentation:loginInfo[@"user"]];
            user.password = password;
            LSSession *session = [LSSession sessionWithAuthenticationToken:authToken user:user];
            self.authenticatedSession = session;
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(loginInfo[@"layer_identity_token"], error);
            });
        }
    }] resume];
}

- (BOOL)resumeSession:(LSSession *)session error:(NSError **)error
{
    if (session) {
        self.authenticatedSession = session;
        return YES;
    } else {
        if (error) *error = [NSError errorWithDomain:LSErrorDomain code:LSNoAuthenticatedSession userInfo:@{NSLocalizedDescriptionKey: @"No authenticated session"}];
        return NO;
    }
}

- (void)deauthenticate
{
    if (self.authenticatedSession) {
        _authenticatedSession = nil;
        _authenticatedURLSessionConfiguration = nil;
        
        [self.URLSession invalidateAndCancel];
        self.URLSession = [self defaultURLSession];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:LSUserDidDeauthenticateNotification object:self.authenticatedSession.user];
}

- (void)loadContactsWithCompletion:(void (^)(NSSet *contacts, NSError *error))completion
{
    NSParameterAssert(completion);
    
    NSURL *URL = [NSURL URLWithString:@"users.json" relativeToURL:self.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";

    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!response && error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        NSArray *userRepresentations;
        NSError *serializationError;
        BOOL success = [LSHTTPResponseSerializer responseObject:&userRepresentations withData:data response:(NSHTTPURLResponse *)response error:&serializationError];
        if (!success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, serializationError);
            });
            return;
        }
        
        NSMutableSet *contacts = [NSMutableSet new];
        for (NSDictionary *representation in userRepresentations) {
            LSUser *user = [LSUser userFromDictionaryRepresentation:representation];
            [contacts addObject:user];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(contacts, nil);
        });
    }] resume];
}

- (void)deleteAllContactsWithCompletion:(void(^)(BOOL completion, NSError *error))completion
{
    NSParameterAssert(completion);

    NSURL *URL = [NSURL URLWithString:@"users/all" relativeToURL:self.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"DELETE";

    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!response && error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, error);
            });
            return;
        }
        
        NSError *serializationError;
        BOOL success = [LSHTTPResponseSerializer responseObject:&response withData:data response:(NSHTTPURLResponse *)response error:&serializationError];
        if (!success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, serializationError);
            });
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success, nil);
        });
    }] resume];
}

#pragma mark - Private Implementation Methods

- (void)setAuthenticatedSession:(LSSession *)authenticatedSession
{
    if (authenticatedSession && !self.authenticatedSession) {
        _authenticatedSession = authenticatedSession;
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfiguration.HTTPAdditionalHeaders = @{@"Accept": @"application/json",
                                                       @"Content-Type": @"application/json",
                                                       @"X_AUTH_EMAIL": authenticatedSession.user.email,
                                                       @"X_AUTH_TOKEN": authenticatedSession.authenticationToken,
                                                       @"X_LAYER_APP_ID": self.layerClient.appID.UUIDString};
        _authenticatedURLSessionConfiguration = sessionConfiguration;
        
        [self.URLSession finishTasksAndInvalidate];
        self.URLSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:LSUserDidAuthenticateNotification object:authenticatedSession.user];
        });
    }
}

@end
