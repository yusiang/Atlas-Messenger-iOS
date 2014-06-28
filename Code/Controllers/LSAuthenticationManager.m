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

@interface LSAuthenticationManager () <NSURLSessionDelegate>

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) LSUserManager *userManager;
@property (nonatomic, readwrite) NSString *authToken;
@property (nonatomic, readwrite) NSString *email;

@end

@implementation LSAuthenticationManager


- (id)initWithBaseURL:(NSString *)baseURL
{
    self = [super init];
    if (self) {
        self.baseURL = [NSURL URLWithString:baseURL];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.HTTPAdditionalHeaders = @{ @"Accept": @"application/json", @"Content-Type": @"application/json" };
        self.urlSession = [NSURLSession sessionWithConfiguration:configuration];
        
        self.userManager = [[LSUserManager alloc] init];
        
    }
    return self;
}

- (void)signUpUser:(LSUser *)user completion:(void (^)(BOOL success, NSError *error))completion
{
    NSError *error;
    
    if (!user.email) {
        error = [NSError errorWithDomain:@"Registration Error" code:101 userInfo:@{@"description" : @"Please enter an email in order to register"}];
    }
    
    if (!user.firstName) {
        error = [NSError errorWithDomain:@"Registration Error" code:101 userInfo:@{@"description" : @"Please enter an email in order to register"}];
    }
    
    if (!user.lastName) {
        error = [NSError errorWithDomain:@"Registration Error" code:101 userInfo:@{@"description" : @"Please enter an email in order to register"}];
    }
    
    if (!user.password || !user.confirmation || ![user.password isEqualToString:user.confirmation]) {
        error = [NSError errorWithDomain:@"Registration Error" code:101 userInfo:@{@"description" : @"Please enter matching passwords in order to register"}];
    }
    
    if (!error) {
        NSURL *URL = [NSURL URLWithString:@"users.json" relativeToURL:self.baseURL];
        
        NSDictionary *parameters = @{ @"user": @{ @"first_name": user.firstName, @"last_name": user.lastName, @"email": user.email, @"password": user.password, @"password_confirmation": user.confirmation}};
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        request.HTTPMethod = @"POST";
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
        
        [[self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSLog(@"Got response: %@, data: %@, error: %@", response, data, error);
            if (response && data) {
                NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"Get the info: %@", info);
                
                [self loginWithEmail:info[@"email"] password:user.password completion:^(BOOL success, NSError *error) {
                    if (!error) {
                        completion(YES, error);
                    } else {
                        completion(NO, error);
                    }
                }];
                
            } else {
                NSLog(@"Failed with error: %@", error);
                completion (NO, error);
            }
        }] resume];
    } else {
        completion(NO, error);
    }
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(void(^)(BOOL success, NSError *error))completion
{
    NSError *error;
    
    if (!email) {
        error = [NSError errorWithDomain:@"Login Error" code:101 userInfo:@{@"description" : @"Please enter your Email address in order to Login"}];
    }
    
    if (!password) {
        error = [NSError errorWithDomain:@"Login Error" code:101 userInfo:@{@"description" : @"Please enter your password in order to login"}];
    }
    
    if (!error) {
        [self.layerController.client requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
            if (nonce) {
                
                NSURL *URL = [NSURL URLWithString:@"users/sign_in.json" relativeToURL:self.baseURL];
                
                NSDictionary *parameters = @{ @"user": @{ @"email": email, @"password":  password}, @"nonce": nonce };
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
                request.HTTPMethod = @"POST";
                request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
                
                [[self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    NSLog(@"Got response: %@, data: %@, error: %@", response, data, error);
                    if (response && data) {
                        NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        NSLog(@"Get the info: %@", info);
                        if(info[@"layer_identity_token"]) {
                            
                            self.email = email;
                            self.authToken = info[@"authentication_token"];
                            
                            [self.userManager persistAuthenticatedEmail:email withInfo:info];
                            
                            [self.layerController.client authenticateWithIdentityToken:info[@"layer_identity_token"] completion:^(NSString *authenticatedUserID, NSError *error) {
                                [self fetchAllContactsWithCompletion:^(BOOL success, NSError *error) {
                                    
                                }];
                                NSLog(@"Authenticated with layer userID:%@, error=%@", authenticatedUserID, error);
                                [self.userManager setLoggedInUserIdentifier:authenticatedUserID];
                                completion(YES, error);
                            }];
                            
                        } else {
                            NSLog(@"Failed with error: %@", info[@"error"]);
                            if (info[@"error"]) error = [NSError errorWithDomain:@"LayerSample" code:401 userInfo:@{ NSLocalizedDescriptionKey: info[@"error"] }];
                            completion (NO, error);
                        }
                    } else {
                        NSLog(@"Failed with error: %@", error);
                        completion (NO, error);
                    }
                }] resume];
            }
            completion(NO, error);
        }];
    }
}

- (void)resumeSessionWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    
}

- (void)logoutWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    
}

- (void)fetchAllContactsWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    NSURL *URL = [NSURL URLWithString:@"users.json" relativeToURL:self.baseURL];
    
    self.urlSession = [self authenticatedURLSessionConfiguration];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    
    [[self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"Got response: %@, data: %@, error: %@", response, data, error);
        if (response && data) {
           
            NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
             NSLog(@"Get the info: %@", info);
            
            LSUserManager *manager = [[LSUserManager alloc] init];
            [manager persistApplicationContacts:info];
            completion(YES, error);
            
        } else {
            NSLog(@"Failed with error: %@", error);
            completion (NO, error);
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

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    
}

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

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    
}
@end
