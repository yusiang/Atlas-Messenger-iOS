//
//  ATLMAPIManagerTest.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 6/30/14.
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

#import "ATLMAPIManager.h"
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import "ATLMUtilities.h"
#import "ATLMPersistenceManager.h"
#import "LYRCountdownLatch.h"
#import "ATLMApplicationController.h"
#import "ATLMAppDelegate.h"
#import "ATLMTestUser.h"
#import "ATLMTestInterface.h"

@interface ATLMAPIManagerTest : XCTestCase

@property (nonatomic) ATLMTestInterface *testInterface;

@end

@implementation ATLMAPIManagerTest

- (void)setUp
{
    [super setUp];
    ATLMApplicationController *applicationController =  [(ATLMAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [ATLMTestInterface testInterfaceWithApplicationController:applicationController];
}

- (void)tearDown
{
    [self.testInterface logoutIfNeeded];
    [super tearDown];
}

- (void)testRaisesOnAttempToInitx
{
    expect(^{ [ATLMAPIManager new]; }).to.raise(NSInternalInconsistencyException);
}

- (void)testInitializingAPIManager
{
    ATLMAPIManager *manager = [ATLMAPIManager managerWithBaseURL:[NSURL URLWithString:@"http://baseURLstring"] layerClient:self.testInterface.applicationController.layerClient];
    expect(manager).toNot.beNil();
}

- (void)testPublicPropertiesOnInitialization
{
    expect(self.testInterface.applicationController.APIManager.authenticatedURLSessionConfiguration).to.beNil();
    expect(self.testInterface.applicationController.APIManager.authenticatedSession).to.beNil();
}

- (void)testRegistrationsWithNilEmail
{
    ATLMUser *user = [ATLMTestUser testUserWithNumber:1];
    user.email = nil;
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.testInterface.applicationController.APIManager registerUser:user completion:^(ATLMUser *user, NSError *error) {
        expect(user).to.beNil;
        expect(error).toNot.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (void)testRegistrationWithExistingEmail
{
    ATLMTestUser *user1 = [self.testInterface registerTestUser:[ATLMTestUser testUserWithNumber:1]];
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.testInterface.applicationController.APIManager registerUser:user1 completion:^(ATLMUser *user, NSError *error) {
        expect(user).to.beNil;
        expect(error).toNot.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
    
}

- (void)testRegistrationWithValidCredentials
{
    [self.testInterface registerTestUser:[ATLMTestUser testUserWithNumber:1]];
}

- (void)testLoginWithInvalidCredentials
{
    ATLMTestUser *user = [ATLMTestUser testUserWithNumber:1];
    [self.testInterface registerTestUser:user];
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.testInterface.applicationController.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        expect(nonce).toNot.beNil;
        expect(error).to.beNil;
        [self.testInterface.applicationController.APIManager authenticateWithEmail:user.email password:@"fakePassword" nonce:nonce completion:^(NSString *identityToken, NSError *error) {
            expect(identityToken).to.beNil;
            expect(error).toNot.beNil;
            [latch decrementCount];
        }];
    }];
    [latch waitTilCount:0];
}

- (void)testLoginWithValidCredentials
{
    ATLMTestUser *user = [self.testInterface registerTestUser:[ATLMTestUser testUserWithNumber:1]];
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:3 timeoutInterval:10];
    [self.testInterface.applicationController.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        expect(nonce).toNot.beNil;
        expect(error).to.beNil;
        [latch decrementCount];
        [self.testInterface.applicationController.APIManager authenticateWithEmail:user.email password:user.password nonce:nonce completion:^(NSString *identityToken, NSError *error) {
            expect(identityToken).toNot.beNil;
            expect(error).to.beNil;
            [latch decrementCount];
            [self.testInterface.applicationController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                expect(authenticatedUserID).toNot.beNil;
                expect(error).to.beNil;
                [latch decrementCount];
            }];
        }];
    }];
    [latch waitTilCount:0];
}

- (void)testLoadingAllContactsForAuthenticatedUser
{
    [self.testInterface registerTestUser:[ATLMTestUser testUserWithNumber:1]];
    [self.testInterface loadContacts];
}

- (void)testDeletingAllContactsForAuthenticatedUser
{
    [self.testInterface registerTestUser:[ATLMTestUser testUserWithNumber:1]];
    [self.testInterface deleteContacts];
}

- (void)testToVerifyResumingSession
{
    [self.testInterface registerAndAuthenticateTestUser:[ATLMTestUser testUserWithNumber:1]];
   
    [tester waitForTimeInterval:2];
    [self.testInterface.applicationController.layerClient disconnect];
    
    ATLMSession *session = self.testInterface.applicationController.APIManager.authenticatedSession;
    expect(session).toNot.beNil;
    expect(session.user.email).to.equal([ATLMTestUser testUserWithNumber:1].email);
    NSError *error;
    [self.testInterface.applicationController.APIManager resumeSession:session error:&error];
    expect(error).to.beNil;
}

- (void)testToVerifyLogout
{
    [self.testInterface registerAndAuthenticateTestUser:[ATLMTestUser testUserWithNumber:1]];
    [self.testInterface logoutIfNeeded];
}



@end
