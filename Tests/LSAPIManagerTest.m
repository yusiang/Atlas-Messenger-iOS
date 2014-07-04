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

@interface LYRClient ()

- (id)initWithBaseURL:(NSURL *)baseURL appID:(NSUUID *)appID databasePath:(NSString *)path;

@end

@interface LSAPIManagerTest : XCTestCase

@end

@implementation LSAPIManagerTest

- (void)setUp
{
    [super setUp];
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:5.0];
    [[self APIManager] deleteAllContactsWithCompletion:^(BOOL completion, NSError *error) {
        [latch decrementCount];
    }];
    [latch decrementCount];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testRaisesOnAttempToInit
{
    expect([LSAPIManager new]).to.raise(NSInternalInconsistencyException);
}

- (void)testInitializingAPIManager
{
    expect([self APIManager]).notTo.beNil();
}

- (void)testPublicPropertiesOnInitializations
{
    LSAPIManager *manager = [self APIManager];
    expect(manager.authenticatedURLSessionConfiguration).to.beNil();
    expect(manager.authenticatedSession).to.beNil();
}

- (void)testRegistrationsWithNilEmail
{
    LSAPIManager *manager = [self APIManager];
    LSUser *user = [[[LSTestUser alloc] init] testUserWithNumber:1];
    user.email = nil;
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [manager registerUser:user completion:^(LSUser *user, NSError *error) {
        expect(user).to.beNil;
        expect(error).toNot.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (void)testRegistrationWithExistingEmail
{
    LSAPIManager *manager = [self APIManager];
    LSUser *user1 = [[[LSTestUser alloc] init] testUserWithNumber:1];
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:2 timeoutInterval:10];
    [manager registerUser:user1 completion:^(LSUser *user, NSError *error) {
        expect(user).toNot.beNil;
        expect(error).to.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:1];
    
    LSUser *user2 = [[[LSTestUser alloc] init] testUserWithNumber:2];
    user2.email = user1.email;
    
    [manager registerUser:user2 completion:^(LSUser *user, NSError *error) {
        expect(user).to.beNil;
        expect(error).toNot.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
    
}

- (void)testRegistrationWithValidCredentials
{
    LSAPIManager *manager = [self APIManager];
    LSUser *user1 = [[[LSTestUser alloc] init] testUserWithNumber:1];
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [manager registerUser:user1 completion:^(LSUser *user, NSError *error) {
        expect(user).toNot.beNil;
        expect(error).to.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (void)testLoginWithInvalidCredentials
{
    LSAPIManager *manager = [self APIManager];
    LSUser *user1 = [[[LSTestUser alloc] init] testUserWithNumber:1];
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:2 timeoutInterval:10];
    [manager registerUser:user1 completion:^(LSUser *user, NSError *error) {
        expect(user).toNot.beNil;
        expect(error).to.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
    
    [manager authenticateWithEmail:user1.email password:@"fakePassword" completion:^(LSUser *user, NSError *error) {
        expect(user).to.beNil;
        expect(error).toNot.beNil;
        [latch decrementCount];
    }];
}

- (void)testLoginWithValidCredentials
{
    LSAPIManager *manager = [self APIManager];
    LSUser *user1 = [[[LSTestUser alloc] init] testUserWithNumber:1];
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:2 timeoutInterval:10];
    [manager registerUser:user1 completion:^(LSUser *user, NSError *error) {
        expect(user).toNot.beNil;
        expect(error).to.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
    
    [manager authenticateWithEmail:user1.email password:user1.password completion:^(LSUser *user, NSError *error) {
        expect(user).toNot.beNil;
        expect(error).to.beNil;
        [latch decrementCount];
    }];
}

- (LSAPIManager *)APIManager
{
    LYRClient *layerClient = [[LYRClient alloc] initWithBaseURL:LSLayerBaseURL() appID:LSLayerAppID() databasePath:LSLayerPersistencePath()];
    return [LSAPIManager managerWithBaseURL:LSRailsBaseURL() layerClient:layerClient];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
