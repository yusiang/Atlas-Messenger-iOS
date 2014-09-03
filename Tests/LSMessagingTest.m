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

@interface LSMessagingTest : XCTestCase <LSNotificationObserverDelegate>

@property (nonatomic, strong) LSAPIManager *APIManager;
@property (nonatomic, strong) LSApplicationController *controller;

@end

@implementation LSMessagingTest

- (void)setUp
{
    [super setUp];
    
    _controller = [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    _APIManager = self.controller.APIManager;
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:5.0];
    [self.APIManager deleteAllContactsWithCompletion:^(BOOL completion, NSError *error) {
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSending5000Messages
{
    LSUser *user1 = [self registerUser:[LYRUITestUser testUserWithNumber:1]];
    [tester waitForTimeInterval:2];
    
    [self deauthenticate];
    
    LSUser *user2 = [self registerUser:[LYRUITestUser testUserWithNumber:2]];
    [tester waitForTimeInterval:2];
    
    LYRConversation *conversation = [LYRConversation conversationWithParticipants:@[user1.userID, user2.userID]];
    
    for (int i = 0; i < 1000; i++) {
        NSLog(@"Message Sent %d", i);
        [self sendMessageWithText:@"Sample Message" conversation:conversation];
    }
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
    [self.APIManager authenticateWithEmail:testUser.email password:testUser.password completion:^(LSUser *user, NSError *error) {
        expect(user).toNot.beNil;
        expect(error).to.beNil;
        authenticatedUser = user;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
    return authenticatedUser;
}

- (void)deauthenticate
{
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.APIManager deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        expect(success).to.beTruthy;
        expect(error).to.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
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
