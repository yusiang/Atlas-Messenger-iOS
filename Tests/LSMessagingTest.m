//
//  LSMessagingTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 7/14/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LSAPIManager.h"
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import "LYRUITestUser.h"
#import "LSUtilities.h"
#import "LSPersistenceManager.h"
#import "LYRUITestUser.h"
#import "LYRCountdownLatch.h"
#import "LSApplicationController.h"
#import "LSAppDelegate.h"
#import <KIF/KIF.h>
#import "KIFSystemTestActor+ViewControllerActions.h"
#import "KIFUITestActor+LSAdditions.h"
#import "LSNotificationObserver.h"
#import "LYRUITestInterface.h"
#import "LYRUILayerContentFactory.h"

@interface LSMessagingTest : XCTestCase <LSNotificationObserverDelegate>

@property (nonatomic, strong) LSAPIManager *APIManager;
@property (nonatomic, strong) LSApplicationController *controller;
@property (nonatomic, strong) LYRUITestInterface *testInterface;
@property (nonatomic, strong) LYRUILayerContentFactory *layerContentFactory;

@end

@implementation LSMessagingTest

- (void)setUp
{
    [super setUp];
    
    LSApplicationController *applicationController =  [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [LYRUITestInterface testInterfaceWithApplicationController:applicationController];
    self.layerContentFactory = [LYRUILayerContentFactory layerContentFactoryWithLayerClient:applicationController.layerClient];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testSending5000Messages
{
    NSString *testUser0 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:0]];
    NSString *testUser1 = [self.testInterface randomUser].userID;
    NSString *testUser2 = [self.testInterface randomUser].userID;
    
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:3]];
    
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObjects:testUser0, testUser1, testUser2, nil] number:100];

    [tester waitForTimeInterval:20];
    [self deauthenticate];
    
    [tester waitForTimeInterval:2];
    [self loginUser:[LYRUITestUser testUserWithNumber:1]];
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:30];
    [[NSNotificationCenter defaultCenter] addObserverForName:LYRClientObjectsDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSLog(@"%@", note);
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (void)testSendingDanAndNoahAFuckTonOfMessages
{
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:3]];
    
    NSSet *participants = [NSSet setWithObjects:@"e51e1517-d2b5-42b3-ad47-499ccdedd6fc", @"4261656f-da0e-44da-b5e5-84a9b267a6dd", @"b79671cf-a132-45f9-9249-ac397d6e6c76", @"7c58970e-8803-464f-83df-9389cdbfdf01", nil];
    for (int i = 0; i < 10; i++) {
         [self.layerContentFactory conversationsWithParticipants:participants number:1];
        [tester waitForTimeInterval:10];
    }
    [tester waitForTimeInterval:20];
}

- (LSUser *)registerUser:(LSUser *)testUser
{
    __block LSUser *authenticatedUser;
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.APIManager registerUser:testUser completion:^(LSUser *user, NSError *error) {
        expect(user).toNot.beNil;
        expect(error).to.beNil;
        authenticatedUser = user;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
    return authenticatedUser;
}

- (LSUser *)loginUser:(LSUser *)testUser
{
     __block LSUser *authenticatedUser;
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    
    [self.controller.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        expect(nonce).toNot.beNil;
        expect(error).to.beNil;
        [self.APIManager authenticateWithEmail:testUser.email password:testUser.password nonce:nonce completion:^(NSString *identityToken, NSError *error) {
            expect(identityToken).toNot.beNil;
            expect(error).to.beNil;
            [self.controller.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                expect(authenticatedUserID).toNot.beNil;
                expect(error).to.beNil;
                [latch decrementCount];
            }];
        }];
    }];

    [latch waitTilCount:0];
    return authenticatedUser;
}

- (void)deauthenticate
{
    [self.APIManager deauthenticate];
    expect(self.APIManager.authenticatedSession).to.beNil;
    expect(self.APIManager.authenticatedURLSessionConfiguration).to.beNil;
}

- (void)sendMessageWithText:(NSString *)sampleText conversation:(LYRConversation *)conversation
{
    LYRMessagePart *part = [LYRMessagePart messagePartWithText:sampleText];
    LYRMessage *message = [LYRMessage messageWithConversation:conversation parts:@[part]];
    
    NSError *error;
    BOOL success = [self.controller.layerClient sendMessage:message error:&error];
    expect(success).to.beTruthy;
}
@end
