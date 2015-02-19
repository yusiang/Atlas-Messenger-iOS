//
//  ATLTestInterface.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 9/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ATLMTestInterface.h"
#import "ATLMTestUser.h"
#import "ATLMErrors.h"

@interface ATLMTestInterface ();

@end

@implementation ATLMTestInterface

+ (instancetype)testInterfaceWithApplicationController:(ATLMIApplicationController *)applicationController
{
    NSParameterAssert(applicationController);
    return [[self alloc] initWithApplicationController:applicationController];
}

- (id)initWithApplicationController:(ATLMIApplicationController *)applicationController
{
    self = [super init];
    if (self) {
        _testEnvironment = ATLMTestEnvironment;
        _applicationController = applicationController;
        _contentFactory = [ATLMLayerContentFactory layerContentFactoryWithLayerClient:applicationController.layerClient];
    }
    return self;
}

- (LYRClient *)authenticateLayerClient:(LYRClient *)layerClient withTestUser:(ATLMTestUser *)testUser;
{
    ATLMTestUser *user = [self registerTestUser:testUser];
    layerClient = [self connectLayerClient:layerClient andAuthenticateAsTestUser:user];
    return layerClient;
}


- (ATLMTestUser *)registerAndAuthenticateTestUser:(ATLMTestUser *)testUser
{
    ATLMTestUser *user = [self registerTestUser:testUser];
    if (user) {
        [self authenticateTestUser:user];
        [self loadContacts];
        return testUser;
    } else {
        return nil;
    }
}

- (ATLMTestUser *)registerTestUser:(ATLMTestUser *)testUser
{
    __block ATLMTestUser *registeredUser;
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.applicationController.APIManager registerUser:testUser completion:^(ATLMUser *user, NSError *error) {
        expect(user).toNot.beNil;
        expect(error).to.beNil;
        registeredUser = (ATLMTestUser *)user;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
    return registeredUser;
}

- (NSString *)authenticateTestUser:(ATLMTestUser *)testUser
{
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:3 timeoutInterval:10];

    __block NSString *userID;
    [self.applicationController.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        expect(nonce).toNot.beNil;
        expect(error).to.beNil;
        [latch decrementCount];
        [self.applicationController.APIManager authenticateWithEmail:testUser.email password:testUser.password nonce:nonce completion:^(NSString *identityToken, NSError *error) {
            expect(identityToken).toNot.beNil;
            expect(error).to.beNil;
            [latch decrementCount];
            [self.applicationController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                expect(authenticatedUserID).toNot.beNil;
                expect(error).to.beNil;
                userID = authenticatedUserID;
                [latch decrementCount];
            }];
        }];
    }];
    [latch waitTilCount:0];
    return userID;
}

- (LYRClient *)connectLayerClient:(LYRClient *)layerClient andAuthenticateAsTestUser:(ATLMTestUser *)testUser
{
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:4 timeoutInterval:10];
    [layerClient connectWithCompletion:^(BOOL success, NSError *error) {
        expect(success).to.beTruthy;
        expect(error).to.beNil;
        [latch decrementCount];
        [layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
            expect(nonce).toNot.beNil;
            expect(error).to.beNil;
            [latch decrementCount];
            [self requestIdentityTokenForUserID:testUser.userID appID:[layerClient.appID UUIDString] nonce:nonce completion:^(NSString *identityToken, NSError *error) {
                expect(identityToken).toNot.beNil;
                expect(error).to.beNil;
                [latch decrementCount];
                [layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                    expect(authenticatedUserID).toNot.beNil;
                    expect(error).to.beNil;
                    [latch decrementCount];
                }];
            }];
        }];
    }];
    [latch waitTilCount:0];
    return layerClient;
}

- (NSMutableArray *)registerTestUsersWithCount:(NSUInteger)count
{
    return [NSMutableArray new];
}

- (void)logoutIfNeeded
{
    [self deleteContacts];
    if (self.applicationController.layerClient.authenticatedUserID) {
        LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
        [self.applicationController.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
            expect(success).to.beTruthy;
            expect(error).to.beNil;
            [self.applicationController.APIManager deauthenticate];
            [latch decrementCount];
        }];
        [latch waitTilCount:0];
    }
}

- (void)loadContacts
{
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.applicationController.APIManager loadContactsWithCompletion:^(NSSet *contacts, NSError *error) {
        if (error) {
            expect(error.code).to.equal(ATLMRequestInProgress);
        } else {
            expect(contacts).toNot.beNil;
            expect(error).to.beNil;
            NSError *persistenceError;
            BOOL success = [self.applicationController.persistenceManager persistUsers:contacts error:&persistenceError];
            expect(success).to.beTruthy;
        }
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (NSSet *)fetchContacts
{
    NSError *error;
    NSSet *persistedUsers = [self.applicationController.persistenceManager persistedUsersWithError:&error];
    expect(error).to.beNil;
    expect(persistedUsers).toNot.beNil;
    return persistedUsers;
}

- (void)deauthenticateLayerClientIfNeeded:(LYRClient *)layerClient
{
    if (layerClient.authenticatedUserID) {
        [self logoutIfNeeded];
    }
}

- (void)deleteContacts
{
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.applicationController.APIManager deleteAllContactsWithCompletion:^(BOOL completion, NSError *error) {
        expect(completion).to.beTruthy;
        expect(error).to.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
    
    NSError *error;
    BOOL success = [self.applicationController.persistenceManager deleteAllObjects:&error];
    expect(error).to.beNil;
    expect(success).to.beTruthy;
}

- (ATLMUser *)randomUser
{
    NSError *error;
    NSSet *users = [self.applicationController.persistenceManager persistedUsersWithError:&error];
    expect(users).toNot.beNil;
    expect(error).to.beNil;
    
    NSMutableSet *mutableUsers = [users mutableCopy];
    [mutableUsers removeObject:self.applicationController.APIManager.authenticatedSession.user];
    
    int randomNumber = arc4random_uniform((int)users.count);
    ATLMUser *user = [[users allObjects] objectAtIndex:randomNumber];
    
    return user;
}

- (ATLMUser *)userForIdentifier:(NSString *)identifier
{
    ATLMUser *user = [self.applicationController.persistenceManager userForIdentifier:identifier];
    expect(user).to.beNil;
    return  user;
}

- (NSString *)conversationLabelForParticipants:(NSSet *)participantIDs
{
    NSMutableSet *participantIdentifiers = [NSMutableSet setWithSet:participantIDs];
    
    if ([participantIdentifiers containsObject:self.applicationController.layerClient.authenticatedUserID]) {
        [participantIdentifiers removeObject:self.applicationController.layerClient.authenticatedUserID];
    }
    
    if (!participantIdentifiers.count > 0) return @"Personal Conversation";
    
    NSSet *participants = [self.applicationController.persistenceManager usersForIdentifiers:participantIdentifiers];
    
    if (!participants.count > 0) return @"No Matching Participants";
    
    ATLMUser *firstUser = [[participants allObjects] objectAtIndex:0];
    NSString *conversationLabel = firstUser.fullName;
    for (int i = 1; i < [[participants allObjects] count]; i++) {
        ATLMUser *user = [[participants allObjects] objectAtIndex:i];
        conversationLabel = [NSString stringWithFormat:@"%@, %@", conversationLabel, user.fullName];
    }
    return conversationLabel;
}

- (NSString *)selectionIndicatorAccessibilityLabelForUser:(ATLMUser *)testUser;
{
    return [NSString stringWithFormat:@"%@ selected", testUser.fullName];
}

- (void)requestIdentityTokenForUserID:(NSString *)userID appID:(NSString *)appID nonce:(NSString *)nonce completion:(void(^)(NSString *identityToken, NSError *error))completion
{
    NSParameterAssert(userID);
    NSParameterAssert(appID);
    NSParameterAssert(nonce);
    NSParameterAssert(completion);
    
    NSURL *identityTokenURL = [NSURL URLWithString:@"https://layer-identity-provider.herokuapp.com/identity_tokens"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:identityTokenURL];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSDictionary *parameters = @{ @"app_id": appID, @"user_id": userID, @"nonce": nonce };
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    request.HTTPBody = requestBody;
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        // Deserialize the response
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(![responseObject valueForKey:@"error"])
        {
            NSString *identityToken = responseObject[@"identity_token"];
            completion(identityToken, nil);
        }
        else
        {
            NSString *domain = @"layer-identity-provider.herokuapp.com";
            NSInteger code = [responseObject[@"status"] integerValue];
            NSDictionary *userInfo =
            @{
              NSLocalizedDescriptionKey: @"Layer Identity Provider Returned an Error.",
              NSLocalizedRecoverySuggestionErrorKey: @"There may be a problem with your APPID."
              };
            
            NSError *error = [[NSError alloc] initWithDomain:domain code:code userInfo:userInfo];
            completion(nil, error);
        }
        
    }] resume];
}


@end
