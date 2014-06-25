//
//  LSLayerController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSLayerController.h"
#import "LSConnectionManager.h"
#import "LYRTestingContext.h"
#import "LYRTestProvider.h"
#import "LYRTestUtilities.h"
#import "LSUser.h"

@interface LYRClient ()

- (id)initWithBaseURL:(NSURL *)baseURL appID:(NSUUID *)appID;

@end

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
    NSUUID *uuid = [NSUUID UUID];
    self.client = [[LYRClient alloc] initWithBaseURL:LYRTestSPDYBaseURL() appID:[LYRTestingContext sharedContext].appID];
    [self.client setDelegate:self];
}

-(void)authenticateUser:(NSString *)userID completion:(void (^)(NSError *))completion
{
    [self.client startWithCompletion:^(BOOL success, NSError *error) {
        NSAssert(!error, @"Can't continue without a connected layer client");
        NSAssert(userID, @"Cannont continue without a userID");
        [self.client requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
            NSAssert(nonce, @"Cannont continue with a nil nonce");
            NSString *identityToken = [[LYRTestingContext sharedContext].provider JWSIdentityTokenForUserID:userID nonce:nonce];
            [self.client authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                NSAssert(!error, @"Failure authentication client for userID %@", userID);
                completion(error);
            }];
        }];
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

- (void)authenticateLayerClientWithIdenityToken:(NSString *)string completion:(void (^)(NSError *error))completion
{
    [self.client authenticateWithIdentityToken:string completion:^(NSString *authenticatedUserID, NSError *error) {
        completion(error);
    }];
}

#pragma mark
#pragma mark LYRClientDelegate Methods

- (void)layerClient:(LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce
{
    NSString *identityToken = [[LYRTestingContext sharedContext].provider JWSIdentityTokenForUserID:@"383727293" nonce:nonce];
    [self.client authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
        if(!error) NSLog(@"Success");
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

- (void)sendMessage:(NSString *)messageText inConversation:(LYRConversation *)conversation
{
    LYRMessagePart *part = [LYRMessagePart messagePartWithText:messageText];
    LYRMessage *message = [self.client messageWithConversation:conversation parts:@[part]];
    
    NSError *error;
    [self.client sendMessage:message error:&error];
    NSLog(@"The error is %@", error);
}

- (void)sendImage:(UIImage *)image inConversation:(LYRConversation *)conversation
{
    LYRMessagePart *part = [LYRMessagePart messagePartWithMIMEType:LYRMIMETypeImagePNG data:UIImagePNGRepresentation(image)];
    LYRMessage *message = [self.client messageWithConversation:conversation parts:@[part]];

    NSError *error;
    [self.client sendMessage:message error:&error];
    NSLog(@"The error is %@", error);
}

-(LYRConversation *)conversationForParticipants:(NSArray *)particiapnts
{
    NSMutableArray *conversationParticipants = [[NSMutableArray alloc] init];
    for (LSUser *user in particiapnts) {
        [conversationParticipants addObject:user.identifier];
    }
    return [self.client conversationWithIdentifier:nil participants:conversationParticipants];
}

@end
