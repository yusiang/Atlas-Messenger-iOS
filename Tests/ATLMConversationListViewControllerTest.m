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

#import "ATLMIApplicationController.h"
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
    ATLMIApplicationController *applicationController =  [(ATLMAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [ATLMTestInterface testInterfaceWithApplicationController:applicationController];
    [self.testInterface registerAndAuthenticateTestUser:[ATLMTestUser testUserWithNumber:0]];
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
    ATLMTestUser *testUser2 = [self.testInterface registerTestUser:[ATLMTestUser testUserWithNumber:2]];
    [self.testInterface loadContacts];
    
    NSSet *participants = [NSSet setWithObject:testUser2.userID];
    [self.testInterface.contentFactory newConversationsWithParticipants:participants];
    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:participants]];
    
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:participants]];
    [tester waitForViewWithAccessibilityLabel:ATLMConversationViewControllerAccessibilityLabel];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
}

@end
