//
//  ATLMConversationViewControllerTest.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 1/15/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
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

#import "KIFTestCase.h"
#import <KIF/KIF.h>
#import "KIFSystemTestActor+ViewControllerActions.h"
#import <XCTest/XCTest.h>

#import "ATLMApplicationController.h"
#import "ATLMTestInterface.h"
#import "ATLMTestUser.h"

extern NSString *const ATLMConversationListTableViewAccessibilityLabel;
extern NSString *const ATLMConversationViewControllerAccessibilityLabel;
extern NSString *const ATLAddressBarAccessibilityLabel;
extern NSString *const ATLMSettingsButtonAccessibilityLabel;
extern NSString *const ATLMComposeButtonAccessibilityLabel;
extern NSString *const ATLMSettingsViewControllerTitle;

@interface ATLMConversationListViewControllerTest : KIFTestCase

@property (nonatomic) ATLMTestInterface *testInterface;

@end

@implementation ATLMConversationListViewControllerTest

- (void)setUp
{
    [super setUp];
    
    ATLMApplicationController *applicationController =  [(ATLMAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [ATLMTestInterface testInterfaceWithApplicationController:applicationController];
    [self.testInterface connectLayerClient];
    [self.testInterface registerTestUserWithIdentifier:@"test"];
}

- (void)tearDown
{
    [self.testInterface logoutIfNeeded];
    [super tearDown];
}

- (void)testToVerifyConversationListViewControllerUI
{
    [tester waitForViewWithAccessibilityLabel:ATLMSettingsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLMComposeButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLMConversationListTableViewAccessibilityLabel];
}

- (void)testToVerifySettingsButtonFunctionality
{
    [tester tapViewWithAccessibilityLabel:ATLMSettingsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLMSettingsViewControllerTitle];
}

- (void)testToVerifyComposeButtonFunctionality
{
    [tester tapViewWithAccessibilityLabel:ATLMComposeButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
}

- (void)testToVerifyConversationSelectionFunctionality
{
    NSString *testUserName = @"Test User2";
    [self.testInterface registerTestUserWithIdentifier:testUserName];
    
    __block NSSet *participant;
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.testInterface.applicationController.persistenceManager performUserSearchWithString:testUserName completion:^(NSArray *users, NSError *error) {
        ATLMUser *user = users.firstObject;
        participant = [NSSet setWithObject:user.participantIdentifier];
        [latch decrementCount];
    }];

    [self.testInterface.contentFactory newConversationsWithParticipants:participant];
    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:participant]];
    
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:participant]];
    [tester waitForViewWithAccessibilityLabel:ATLMConversationViewControllerAccessibilityLabel];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
}

@end
