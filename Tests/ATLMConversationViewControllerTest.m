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

extern NSString *const ATLMComposeButtonAccessibilityLabel;
extern NSString *const ATLMConversationViewControllerAccessibilityLabel;
extern NSString *const ATLMDetailsButtonAccessibilityLabel;
extern NSString *const ATLMConversationDetailViewControllerTitle;
extern NSString *const ATLMMessageDetailViewControllerAccessibilityLabel;

extern NSString *const ATLConversationListViewControllerTitle;
extern NSString *const ATLConversationCollectionViewAccessibilityIdentifier;
extern NSString *const ATLAddressBarAccessibilityLabel;
extern NSString *const ATLMessageInputToolbarAccessibilityLabel;

@interface ATLMConversationViewControllerTest : KIFTestCase

@property (nonatomic) ATLMTestInterface *testInterface;
@property (nonatomic) NSSet *participants;

@end

@implementation ATLMConversationViewControllerTest

//- (void)setUp
//{
//    [super setUp];
//    ATLMApplicationController *applicationController =  [(ATLMAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
//    self.testInterface = [ATLMTestInterface testInterfaceWithApplicationController:applicationController];
//
//    
//    self.participants = [NSSet setWithObject:testUser2.userID];
//    [self.testInterface.contentFactory newConversationsWithParticipants:self.participants];
//    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
//}
//
//- (void)tearDown
//{
//    [self.testInterface logoutIfNeeded];
//    [super tearDown];
//}
//
//- (void)testToVerifyNewConversationViewControllerUI
//{
//    [tester waitForViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
//    [tester tapViewWithAccessibilityLabel:ATLMComposeButtonAccessibilityLabel];
//    [tester waitForViewWithAccessibilityLabel:ATLMConversationViewControllerAccessibilityLabel];
//    [tester waitForViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
//    [tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarAccessibilityLabel];
//    [tester waitForAbsenceOfViewWithAccessibilityLabel:ATLMDetailsButtonAccessibilityLabel];
//    [tester waitForViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
//}
//
//- (void)testToVerifyExistingConversationViewControllerUI
//{
//    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
//    [tester waitForAbsenceOfViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
//    [tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarAccessibilityLabel];
//    [tester waitForViewWithAccessibilityLabel:ATLMConversationViewControllerAccessibilityLabel];
//    [tester waitForViewWithAccessibilityLabel:ATLMDetailsButtonAccessibilityLabel];
//    [tester waitForViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
//}
//
//- (void)testToVerifyBackButtonFunctionality
//{
//    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
//    [tester tapViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
//    [tester waitForViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
//}
//
//- (void)testToVerifyDetailsButtonFunctionality
//{
//    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
//    [tester tapViewWithAccessibilityLabel:ATLMDetailsButtonAccessibilityLabel];
//    [tester waitForViewWithAccessibilityLabel:ATLMConversationDetailViewControllerTitle];
//}
//
//- (void)testToVerifyDebugModeEnabledFunctionality
//{
//    self.testInterface.applicationController.debugModeEnabled = YES;
//    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
//    [tester tapItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]  inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
//    [tester waitForViewWithAccessibilityLabel:ATLMMessageDetailViewControllerAccessibilityLabel];
//}
//
//- (void)testToVerifyDebugModeDisabledFunctionality
//{
//    self.testInterface.applicationController.debugModeEnabled = NO;
//    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
//    [tester tapItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]  inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
//    [tester waitForAbsenceOfViewWithAccessibilityLabel:ATLMMessageDetailViewControllerAccessibilityLabel];
//}

@end
