//
//  LSLayerController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSLayerController.h"
#import "LSAuthenticationManager.h"
#import "LYRTestingContext.h"
#import "LYRTestProvider.h"
#import "LYRTestUtilities.h"
#import "LSUser.h"

@implementation LSLayerController

- (id)initWithClient:(LYRClient *)client
{
    self = [super init];
    if (self) {
        _client = client;
        client.delegate = self;
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer. Call `initWithClient:` instead." userInfo:nil];
}

#pragma mark
#pragma mark LSLayerController Public Methods

-(void)authenticateUser:(NSString *)userID completion:(void (^)(NSError *))completion
{
    NSLog(@"The LYRClient is %@", self.client);
    [self.client startWithCompletion:^(BOOL success, NSError *error) {
        NSAssert(!error, @"Can't continue without a connected layer client");
        NSAssert(userID, @"Cannont continue without a userID");
        [self.client requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
            NSAssert(nonce, @"Cannont continue with a nil nonce");
            NSString *identityToken = [[LYRTestingContext sharedContext].provider JWSIdentityTokenForUserID:userID nonce:nonce];
            [self.client authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                NSAssert(!error, @"Failure authentication client for userID %@", userID);
                NSOrderedSet *conversations = [self.client conversationsForIdentifiers:nil];
                NSLog(@"The conversations are %@", conversations);
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
//    LSAuthenticationManager *connectionManager = [[LSAuthenticationManager alloc] init];
//    [connectionManager requestLayerIdentityTokenWithNonce:nonce completion:^(NSString *identityToken, NSError *error) {
//        completion(identityToken, error);
//    }];
}

- (void)authenticateLayerClientWithIdenityToken:(NSString *)string completion:(void (^)(NSError *error))completion
{
    [self.client authenticateWithIdentityToken:string completion:^(NSString *authenticatedUserID, NSError *error) {
        completion(error);
    }];
}

- (void)logout
{
    [self.client deauthenticate];
}

#pragma mark
#pragma mark LYRClientDelegate Methods

- (void)layerClient:(LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce
{
//    NSString *identityToken = [[LYRTestingContext sharedContext].provider JWSIdentityTokenForUserID:@"383727293" nonce:nonce];
//    [self.client authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
//        if(!error) NSLog(@"Success");
//    }];
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

//============Transition Guide Stuff=================//
- (void)sendMessage
{
    // 1. Initialize a conversation object
    LYRConversation *conversation =[self.client conversationWithIdentifier:nil participants:@[@"USER_IDENTIFIER"]];

    // 2. Initialize the message content via LYRMessageParts
    LYRMessagePart *messagePart = [LYRMessagePart messagePartWithText:@"Hey there, how are you?"];

    // 3. Initialize a message object with the content
    LYRMessage *message = [self.client messageWithConversation:conversation parts:@[messagePart]];

    // 4. Send the message within the context of the conversation
    NSError *error;
    [self.client sendMessage:message error:&error];
    
    NSOrderedSet *messages = [self.client messagesForConversation:conversation];
    
    NSOrderedSet *conversations = [self.client conversationsForIdentifiers:nil];

}
@end
