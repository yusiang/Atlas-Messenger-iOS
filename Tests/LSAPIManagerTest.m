//
//  LSAPIManagerTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LSAPIManager.h"
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import "LSTestUser.h"
#import "LSUtilities.h"
#import "LSPersistenceManager.h"
#import "LSTestUser.h"
#import "LYRCountdownLatch.h"
#import "LSApplicationController.h"
#import "LSAppDelegate.h"

@interface LYRClient ()

- (id)initWithBaseURL:(NSURL *)baseURL appID:(NSUUID *)appID databasePath:(NSString *)path;

@end

@interface LSAPIManagerTest : XCTestCase

@property (nonatomic, strong) LSAPIManager *APIManager;

@end

@implementation LSAPIManagerTest

- (void)setUp
{
    [super setUp];
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:5.0];
    [self.APIManager deleteAllContactsWithCompletion:^(BOOL completion, NSError *error) {
        [latch decrementCount];
    }];
    [latch decrementCount];
}

- (void)tearDown
{
    [super tearDown];
    self.APIManager = nil;
}

- (void)testRaisesOnAttempToInit
{
    expect([LSAPIManager new]).to.raise(NSInternalInconsistencyException);
}

- (void)testInitializingAPIManager
{
    expect(self.APIManager).notTo.beNil();
}

- (void)testPublicPropertiesOnInitialization
{
    expect(self.APIManager.authenticatedURLSessionConfiguration).to.beNil();
    expect(self.APIManager.authenticatedSession).to.beNil();
}

- (void)testRegistrationsWithNilEmail
{
    LSUser *user = [LSTestUser testUserWithNumber:1];
    user.email = nil;
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.APIManager registerUser:user completion:^(LSUser *user, NSError *error) {
        expect(user).to.beNil;
        expect(error).toNot.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (void)testRegistrationWithExistingEmail
{
    LSUser *user1 = [LSTestUser testUserWithNumber:1];
    [self registerUser:user1];
   
    LSUser *user2 = [LSTestUser testUserWithNumber:2];
    user2.email = user1.email;
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.APIManager registerUser:user2 completion:^(LSUser *user, NSError *error) {
        expect(user).to.beNil;
        expect(error).toNot.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
    
}

- (void)testRegistrationWithValidCredentials
{
    [self registerUser:[LSTestUser testUserWithNumber:1]];
}

- (void)testLoginWithInvalidCredentials
{
    LSUser *user = [LSTestUser testUserWithNumber:1];
    [self registerUser:user];
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.APIManager authenticateWithEmail:user.email password:@"fakePassword" completion:^(LSUser *user, NSError *error) {
        expect(user).to.beNil;
        expect(error).toNot.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (void)testLoginWithValidCredentials
{
    LSUser *user = [LSTestUser testUserWithNumber:1];
    [self registerUser:user];
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.APIManager authenticateWithEmail:user.email password:user.password completion:^(LSUser *user, NSError *error) {
        expect(user).toNot.beNil;
        expect(error).to.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (void)testLoadingAllContactsForAuthenticatedUser
{
    [self registerUser:[LSTestUser testUserWithNumber:1]];
    
    [self.APIManager deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        expect(success).to.beTruthy;
        expect(error).to.beNil;
    }];
    
    [self registerUser:[LSTestUser testUserWithNumber:2]];

    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.APIManager loadContactsWithCompletion:^(NSSet *contacts, NSError *error) {
        expect(contacts).toNot.beNil;
        expect(contacts.count).to.equal(1);
        expect(error).to.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
    
}

- (void)testDeletingAllContactsForAuthenticatedUser
{
    [self registerUser:[LSTestUser testUserWithNumber:1]];
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.APIManager deleteAllContactsWithCompletion:^(BOOL completion, NSError *error) {
        expect(completion).to.beTruthy;
        expect(error).to.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (void)testToVerifyResumingSession
{
    [self registerUser:[LSTestUser testUserWithNumber:1]];
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    
    LSSession *session = self.APIManager.authenticatedSession;
    [self.APIManager resumeSession:session completion:^(LSUser *user, NSError *error) {
        expect(user).toNot.beNil;
        expect(user).to.equal([LSTestUser testUserWithNumber:1]);
        expect(error).to.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (void)testToVerifyLogout
{
    [self registerUser:[LSTestUser testUserWithNumber:1]];
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.APIManager deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        expect(success).to.beTruthy;
        expect(error).to.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
    
}
- (LSAPIManager *)APIManager
{
    if (!_APIManager) {
        LSApplicationController *controller = [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
        _APIManager = controller.APIManager;
    }
    return _APIManager;
}

- (void)registerUser:(LSUser *)user
{
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.APIManager registerUser:user completion:^(LSUser *user, NSError *error) {
        expect(user).toNot.beNil;
        expect(error).to.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
