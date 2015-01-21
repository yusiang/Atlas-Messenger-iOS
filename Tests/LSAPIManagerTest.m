//
//  LSAPIManagerTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSAPIManager.h"
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import "LSUtilities.h"
#import "LSPersistenceManager.h"
#import "LYRCountdownLatch.h"
#import "LSApplicationController.h"
#import "LSAppDelegate.h"
#import "LSTestUser.h"
#import "LSTestInterface.h"

@interface LSAPIManagerTest : XCTestCase

@property (nonatomic) LSTestInterface *testInterface;

@end

@implementation LSAPIManagerTest

- (void)setUp
{
    [super setUp];
    LSApplicationController *applicationController =  [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [LSTestInterface testInterfaceWithApplicationController:applicationController];
}

- (void)tearDown
{
    [self.testInterface logoutIfNeeded];
    [super tearDown];
}

- (void)testRaisesOnAttempToInitx
{
    expect(^{ [LSAPIManager new]; }).to.raise(NSInternalInconsistencyException);
}

- (void)testInitializingAPIManager
{
    LSAPIManager *manager = [LSAPIManager managerWithBaseURL:[NSURL URLWithString:@"http://baseURLstring"] layerClient:self.testInterface.applicationController.layerClient];
    expect(manager).toNot.beNil();
}

- (void)testPublicPropertiesOnInitialization
{
    expect(self.testInterface.applicationController.APIManager.authenticatedURLSessionConfiguration).to.beNil();
    expect(self.testInterface.applicationController.APIManager.authenticatedSession).to.beNil();
}

- (void)testRegistrationsWithNilEmail
{
    LSUser *user = [LSTestUser testUserWithNumber:1];
    user.email = nil;
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.testInterface.applicationController.APIManager registerUser:user completion:^(LSUser *user, NSError *error) {
        expect(user).to.beNil;
        expect(error).toNot.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (void)testRegistrationWithExistingEmail
{
    LSTestUser *user1 = [self.testInterface registerTestUser:[LSTestUser testUserWithNumber:1]];
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.testInterface.applicationController.APIManager registerUser:user1 completion:^(LSUser *user, NSError *error) {
        expect(user).to.beNil;
        expect(error).toNot.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
    
}

- (void)testRegistrationWithValidCredentials
{
    [self.testInterface registerTestUser:[LSTestUser testUserWithNumber:1]];
}

- (void)testLoginWithInvalidCredentials
{
    LSTestUser *user = [LSTestUser testUserWithNumber:1];
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
    LSTestUser *user = [self.testInterface registerTestUser:[LSTestUser testUserWithNumber:1]];
    
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
    [self.testInterface registerTestUser:[LSTestUser testUserWithNumber:1]];
    [self.testInterface loadContacts];
}

- (void)testDeletingAllContactsForAuthenticatedUser
{
    [self.testInterface registerTestUser:[LSTestUser testUserWithNumber:1]];
    [self.testInterface deleteContacts];
}

- (void)testToVerifyResumingSession
{
    [self.testInterface registerAndAuthenticateTestUser:[LSTestUser testUserWithNumber:1]];
   
    [tester waitForTimeInterval:2];
    [self.testInterface.applicationController.layerClient disconnect];
    
    LSSession *session = self.testInterface.applicationController.APIManager.authenticatedSession;
    expect(session).toNot.beNil;
    expect(session.user.email).to.equal([LSTestUser testUserWithNumber:1].email);
    NSError *error;
    [self.testInterface.applicationController.APIManager resumeSession:session error:&error];
    expect(error).to.beNil;
}

- (void)testToVerifyLogout
{
    [self.testInterface registerAndAuthenticateTestUser:[LSTestUser testUserWithNumber:1]];
    [self.testInterface logoutIfNeeded];
}



@end
