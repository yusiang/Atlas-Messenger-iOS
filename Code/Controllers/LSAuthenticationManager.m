//
//  LSConnectionManager.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSAuthenticationManager.h"
#import "LSUserManager.h"
#import "LSUser.h"
#import "LSHTTPResponseSerializer.h"

@interface LSAuthenticationManager () <NSURLSessionDelegate>

@property (nonatomic) NSURL *baseURL;
@property (nonatomic) NSURLSession *URLSession;
@property (nonatomic) LSUserManager *userManager;
@property (nonatomic, readwrite) NSString *authToken;
@property (nonatomic, readwrite) NSString *email;

@end

@implementation LSAuthenticationManager


- (id)initWithBaseURL:(NSString *)baseURL layerClient:(LYRClient *)layerClient
{
    self = [super init];
    if (self) {
        _baseURL = [NSURL URLWithString:baseURL];
        _layerClient = layerClient;
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.HTTPAdditionalHeaders = @{ @"Accept": @"application/json", @"Content-Type": @"application/json" };
        _URLSession = [NSURLSession sessionWithConfiguration:configuration];
        _userManager = [[LSUserManager alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidAuthenticateNotification:) name:LSUserDidAuthenticateNotification object:nil];
    }
    return self;
}

- (void)signUpUser:(LSUser *)user completion:(void (^)(LSUser *user, NSError *error))completion
{
    NSParameterAssert(completion);
    NSError *error = nil;
    if (! [user validate:&error]) {
        completion(nil, error);
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:@"users.json" relativeToURL:self.baseURL];
    NSDictionary *parameters = @{ @"user": @{ @"first_name": user.firstName, @"last_name": user.lastName, @"email": user.email, @"password": user.password, @"password_confirmation": user.confirmation}};
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"Got response: %@, data: %@, error: %@", response, data, error);
        if (!response && error) {
            NSLog(@"Failed with error: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        NSError *serializationError = nil;
        NSDictionary *userDetails = nil;
        BOOL success = [LSHTTPResponseSerializer responseObject:&userDetails withData:data response:(NSHTTPURLResponse *)response error:&serializationError];
        if (success) {
            NSLog(@"Loaded User Response: %@", userDetails);
            [self loginWithEmail:user.email password:user.password completion:completion];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, serializationError);
            });
        }
    }] resume];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(void(^)(LSUser *user, NSError *error))completion
{
    NSParameterAssert(completion);
    
    if (!email.length) {
        NSError *error = [NSError errorWithDomain:@"Login Error" code:101 userInfo:@{ NSLocalizedDescriptionKey : @"Please enter your Email address in order to Login"}];
        completion(nil, error);
        return;
    }
    
    if (!password.length) {
        NSError *error = [NSError errorWithDomain:@"Login Error" code:101 userInfo:@{ NSLocalizedDescriptionKey : @"Please enter your password in order to login"}];
        completion(nil, error);
        return;
    }
    
    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        if (!nonce) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        NSURL *URL = [NSURL URLWithString:@"users/sign_in.json" relativeToURL:self.baseURL];
        NSDictionary *parameters = @{ @"user": @{ @"email": email, @"password": password }, @"nonce": nonce };
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        request.HTTPMethod = @"POST";
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
        
        [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!response && error) {
                completion(nil, error);
                return;
            }
            
            NSError *serializationError = nil;
            NSDictionary *loginInfo = nil;
            BOOL success = [LSHTTPResponseSerializer responseObject:&loginInfo withData:data response:(NSHTTPURLResponse *)response error:&serializationError];
            if (!success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, serializationError);
                });
            } else {
                self.email = email;
                self.authToken = loginInfo[@"authentication_token"];
                [self.userManager persistAuthenticatedEmail:email withInfo:loginInfo];
                [self.URLSession finishTasksAndInvalidate];
                self.URLSession = [self authenticatedURLSessionConfiguration];
                
                [self.layerClient authenticateWithIdentityToken:loginInfo[@"layer_identity_token"] completion:^(NSString *authenticatedUserID, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"Authenticated with layer userID:%@, error=%@", authenticatedUserID, error);
                        [self.userManager setLoggedInUserIdentifier:authenticatedUserID];
                        completion(self.userManager.loggedInUser, error);
                    });
                }];
            }
        }] resume];
    }];
}

- (void)userDidAuthenticateNotification:(NSNotification *)notification
{
    [self fetchAllContactsWithCompletion:nil];
}

- (void)resumeSessionWithCompletion:(void(^)(LSUser *user, NSError *error))completion
{
    
}

- (void)logoutWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    
}

- (void)fetchAllContactsWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    NSURL *URL = [NSURL URLWithString:@"users.json" relativeToURL:self.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"Got response: %@, data: %@, error: %@", response, data, error);
        if (response && data) {
           
            NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
             NSLog(@"Get the info: %@", info);
            
            LSUserManager *manager = [[LSUserManager alloc] init];
            [manager persistApplicationContacts:info];
            if (completion) completion(YES, error);
        } else {
            NSLog(@"Failed with error: %@", error);
            if (completion) completion (NO, error);
        }
    }] resume];
}

- (NSURLSession *)authenticatedURLSessionConfiguration
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{ @"Accept": @"application/json", @"Content-Type": @"application/json", @"HTTP_X_AUTH_EMAIL" : self.email, @"HTTP_X_AUTH_TOKEN": self.authToken};
    return [NSURLSession sessionWithConfiguration:configuration];
}

#pragma mark
#pragma mark NSURLSessionDelegate Methods

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        if([challenge.protectionSpace.host isEqualToString:@"api-beta.layer.com"]){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}

@end
