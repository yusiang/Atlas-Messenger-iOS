//
//  LSDataSourceTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 11/15/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LYRUITestInterface.h"
#import "LYRUIConversationViewController.h"
#import "LYRUIMessageInputToolbar.h"
#import "LYRUIMessageComposeTextView.h"
#import "LYRUIConversationDataSource.h"
#import "LSTestObserver.h"

@interface LSDataSourceTest : XCTestCase

@property (nonatomic) LYRUITestInterface *testInterface;

@end

@implementation LSDataSourceTest

- (void)setUp {
    [super setUp];
    
    LSApplicationController *applicationController =  [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [LYRUITestInterface testInterfaceWithApplicationController:applicationController];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testToEnsureConversationIdentifiersGetUpdated
{
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:3]];
    [tester waitForTimeInterval:2];
    [self conversationIDUpdateWithNumber:10];
}

- (void)conversationIDUpdateWithNumber:(NSUInteger)number
{
    LSTestObserver *observer = [LSTestObserver initWithClass:[LYRConversation class] changeType:LYRObjectChangeTypeUpdate property:@"identifier"];
    id delegateMock = OCMProtocolMock(@protocol(LSTestObserverDelegate));
    observer.delegate = delegateMock;
    
    for (int i = 0; i < number; i++) {
        [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
            expect(invocation).notTo.beNil;
        }] testObserver:observer objectDidChange:[OCMArg any]];
        
        NSSet *participants = [NSSet setWithObject:@"00000001"];
        [self.testInterface.contentFactory conversationsWithParticipants:participants number:1];
        [delegateMock verifyWithDelay:5];
    }
}

@end
