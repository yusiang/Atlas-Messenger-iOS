//
//  LSLayerController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSLayerController.h"
#import "LSParseController.h"
#import "LSConnectionManager.h"

@implementation LSLayerController

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

#pragma mark
#pragma mark LSLayerController Public Methods

- (void)initializeLayerClientWithCompletion:(void (^)(NSError *))completion
{
    
    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"57692e74-f27e-11e3-b94b-202b01000604"];
    self.client = [LYRClient clientWithAppID:appID];
    [self.client setDelegate:self];
    [self.client startWithCompletion:^(BOOL success, NSError *error) {
        completion(error);
    }];
}

- (void)authenticateLayerClientWithCompletion:(void (^)(NSError * error))completion
{
    [self requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        [self requestIdentityTokenWithNonce:nonce completion:^(NSString *identityToken, NSError *error) {
            [self authenticateLayerClientWithIdenityToken:identityToken completion:^(NSError *error) {
                if (!error) {
                    NSLog(@"Layer client is authenticated");
                }
                completion(error);
            }];
        }];
    }];
}

#pragma mark
#pragma mark LYRClientAuthentication Methods

- (void)requestAuthenticationNonceWithCompletion:(void (^)(NSString *nonce, NSError *error))completion
{
    [self.client requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        completion(nonce, error);
    }];
}

- (void)requestIdentityTokenWithNonce:(NSString *)nonce completion:(void (^)(NSString *idenityToken, NSError *error))completion
{
    LSConnectionManager *connectionManager = [[LSConnectionManager alloc] init];
    [connectionManager requestLayerIdentityTokenWithNonce:nonce completion:^(NSString *identityToken, NSError *error) {
        completion(identityToken, error);
    }];
}

-(void)authenticateLayerClientWithIdenityToken:(NSString *)string completion:(void (^)(NSError *error))completion
{
    [self.client authenticateWithIdentityToken:string completion:^(NSString *authenticatedUserID, NSError *error) {
        completion(error);
    }];
}

#pragma mark
#pragma mark LYRClientDelegate Methods

- (void)layerClient:(LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce
{
    NSLog(@"Client Did Recieve Authentication Challenge");
    [self reauthenticateLayerClientWithNonce:nonce completion:^(NSError *error) {
        if(!error) NSLog(@"Client Reauthentication Succesful");
    }];
}

- (void)layerClient:(LYRClient *)client didAuthenticateAsUserID:(NSString *)userID
{
    NSLog(@"Client Did Authenticate As %@", userID);
}

- (void)layerClientDidDeauthenticate:(LYRClient *)client
{
    NSLog(@"Client Did Deauthenticate");
}

#pragma mark
#pragma mark Private Implementation Methods

- (void)reauthenticateLayerClientWithNonce:(NSString *)nonce completion:(void(^)(NSError *error))completion
{
    [self requestIdentityTokenWithNonce:nonce completion:^(NSString *identityToken, NSError *error) {
        [self authenticateLayerClientWithIdenityToken:identityToken completion:^(NSError *error) {
            if (!error) {
                NSLog(@"Layer client is authenticated");
            }
            completion(error);
        }];
    }];
}


@end
