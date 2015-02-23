//
//  ATLMSettingsViewControllerTest.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 1/20/15.
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

#import "ATLMTestInterface.h"
#import "ATLMTestUser.h"
#import "ATLMSettingsHeaderView.h"
#import "ATLMSettingsViewController.h"

extern NSString *const ATLMConversationListTableViewAccessibilityLabel;
extern NSString *const ATLMSettingsTableViewAccessibilityIdentifier;
extern NSString *const ATLMSettingsHeaderAccessibilityLabel;
extern NSString *const ATLMPushNotificationSettingSwitch;
extern NSString *const ATLMLocalNotificationSettingSwitch;
extern NSString *const ATLMDebugModeSettingSwitch;


@interface ATLMSettingsViewControllerTest : KIFTestCase

@property (nonatomic) ATLMTestInterface *testInterface;

@end

@implementation ATLMSettingsViewControllerTest
//
//- (void)setUp
//{
//    [super setUp];
//    ATLMIApplicationController *applicationController =  [(ATLMAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
//    self.testInterface = [ATLMTestInterface testInterfaceWithApplicationController:applicationController];
//    [self.testInterface registerAndAuthenticateTestUser:[ATLMTestUser testUserWithNumber:0]];
//    
//}
//
//- (void)tearDown
//{
//    [self.testInterface logoutIfNeeded];
//    [super tearDown];
//}
//
//- (void)testToVerifyHeaderUI
//{
//    [tester tapViewWithAccessibilityLabel:@"Settings"];
//    ATLMUser *user = self.testInterface.applicationController.APIManager.authenticatedSession.user;
//    [tester waitForViewWithAccessibilityLabel:ATLMSettingsHeaderAccessibilityLabel];
//    [tester waitForViewWithAccessibilityLabel:user.fullName];
//    [tester waitForViewWithAccessibilityLabel:@"Connected"];
//}
//
//- (void)testToVerifyDoneButtonFunctionality
//{
//    [tester tapViewWithAccessibilityLabel:@"Settings"];
//    [tester tapViewWithAccessibilityLabel:@"Done"];
//    [tester waitForViewWithAccessibilityLabel:ATLMConversationListTableViewAccessibilityLabel];
//}
//
//- (void)testToVerifySettingsDelegateFunctionalityOnDoneButtonTap
//{
//    ATLMSettingsViewController *controller = [[ATLMSettingsViewController alloc] init];
//    controller.applicationController = self.testInterface.applicationController;
//    id delegateMock = OCMProtocolMock(@protocol(ATLMSettingsViewControllerDelegate));
//    controller.settingsDelegate = delegateMock;
//    
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
//    [system presentModalViewController:navigationController configurationBlock:nil];
//    
//    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
//        
//    }] settingsViewControllerDidFinish:[OCMArg any]];
//    
//    [tester tapViewWithAccessibilityLabel:@"Done"];
//    [delegateMock verify];
//}
//
//- (void)testToVerifySettingsDelegateFunctionalityOnLogoutButtonTap
//{
//    ATLMSettingsViewController *controller = [[ATLMSettingsViewController alloc] init];
//    controller.applicationController = self.testInterface.applicationController;
//    id delegateMock = OCMProtocolMock(@protocol(ATLMSettingsViewControllerDelegate));
//    controller.settingsDelegate = delegateMock;
//    
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
//    [system presentModalViewController:navigationController configurationBlock:nil];
//
//    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
//        
//    }] logoutTappedInSettingsViewController:[OCMArg any]];
//    
//    [tester swipeViewWithAccessibilityLabel:ATLMSettingsHeaderAccessibilityLabel inDirection:KIFSwipeDirectionUp];
//    [tester waitForViewWithAccessibilityLabel:@"Log Out"];
//    [tester tapViewWithAccessibilityLabel:@"Log Out"];
//    [delegateMock verify];
//}
//
//- (void)testToVerifySendPushNotificationSwitchFunctionality
//{
//    [tester tapViewWithAccessibilityLabel:@"Settings"];
//    UISwitch *switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:ATLMPushNotificationSettingSwitch];
//    expect(switchControl.on).to.beFalsy;
//    [tester setOn:YES forSwitchWithAccessibilityLabel:ATLMPushNotificationSettingSwitch];
//    [self.testInterface logoutIfNeeded];
//   
//    ATLMTestUser *user = [ATLMTestUser testUserWithNumber:0];
//    [self.testInterface authenticateTestUser:user];
//    [tester tapViewWithAccessibilityLabel:@"Settings"];
//    switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:ATLMPushNotificationSettingSwitch];
//    expect(switchControl.on).to.beTruthy;
//    [tester setOn:NO forSwitchWithAccessibilityLabel:ATLMPushNotificationSettingSwitch];
//    [self.testInterface logoutIfNeeded];
//    
//    [self.testInterface authenticateTestUser:user];
//    [tester tapViewWithAccessibilityLabel:@"Settings"];
//    switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:ATLMPushNotificationSettingSwitch];
//    expect(switchControl.on).to.beFalsy;
//}
//
//- (void)testToVerifyDisplayLocalNotificationSwitchFunctionality
//{
//    [tester tapViewWithAccessibilityLabel:@"Settings"];
//    UISwitch *switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:ATLMLocalNotificationSettingSwitch];
//    expect(switchControl.on).to.beFalsy;
//    [tester setOn:YES forSwitchWithAccessibilityLabel:ATLMLocalNotificationSettingSwitch];
//    [self.testInterface logoutIfNeeded];
//    
//    ATLMTestUser *user = [ATLMTestUser testUserWithNumber:0];
//    [self.testInterface authenticateTestUser:user];
//    [tester tapViewWithAccessibilityLabel:@"Settings"];
//    switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:ATLMLocalNotificationSettingSwitch];
//    expect(switchControl.on).to.beTruthy;
//    [tester setOn:NO forSwitchWithAccessibilityLabel:ATLMLocalNotificationSettingSwitch];
//    [self.testInterface logoutIfNeeded];
//    
//    [self.testInterface authenticateTestUser:user];
//    [tester tapViewWithAccessibilityLabel:@"Settings"];
//    switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:ATLMLocalNotificationSettingSwitch];
//    expect(switchControl.on).to.beFalsy;
//}
//
//- (void)testTiVerifyDebugModeSwitchFunctionality
//{
//    [tester tapViewWithAccessibilityLabel:@"Settings"];
//    UISwitch *switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:ATLMDebugModeSettingSwitch];
//    expect(switchControl.on).to.beFalsy;
//    [tester setOn:YES forSwitchWithAccessibilityLabel:ATLMDebugModeSettingSwitch];
//    [self.testInterface logoutIfNeeded];
//    
//    ATLMTestUser *user = [ATLMTestUser testUserWithNumber:0];
//    [self.testInterface authenticateTestUser:user];
//    [tester tapViewWithAccessibilityLabel:@"Settings"];
//    switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:ATLMDebugModeSettingSwitch];
//    expect(switchControl.on).to.beTruthy;
//    [tester setOn:NO forSwitchWithAccessibilityLabel:ATLMDebugModeSettingSwitch];
//    [self.testInterface logoutIfNeeded];
//    
//    [self.testInterface authenticateTestUser:user];
//    [tester tapViewWithAccessibilityLabel:@"Settings"];
//    switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:ATLMDebugModeSettingSwitch];
//    expect(switchControl.on).to.beFalsy;
//}
//
//- (void)testToVerifyLayerStatistics
//{
//    [tester tapViewWithAccessibilityLabel:@"Settings"];
//    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
//    NSError *error;
//    NSUInteger conversationCount = [self.testInterface.applicationController.layerClient countForQuery:query error:&error];
//    expect(error).to.beFalsy;
//    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Conversations:, %lu", (unsigned long)conversationCount]];
//    
//    query = [LYRQuery queryWithClass:[LYRMessage class]];
//    NSUInteger messageCount = [self.testInterface.applicationController.layerClient countForQuery:query error:&error];
//    expect(error).to.beFalsy;
//    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Messages:, %lu", (unsigned long)messageCount]];
//    
//    query = [LYRQuery queryWithClass:[LYRMessage class]];
//    query.predicate = [LYRPredicate predicateWithProperty:@"isUnread" operator:LYRPredicateOperatorIsEqualTo value:@(YES)];
//    NSUInteger unreadMessageCount = [self.testInterface.applicationController.layerClient countForQuery:query error:&error];
//    expect(error).to.beFalsy;
//    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Unread Messages:, %lu", (unsigned long)unreadMessageCount]];
//}
//
//- (void)testToVerifyLogoutButtonFunctionality
//{
//    [tester tapViewWithAccessibilityLabel:@"Settings"];
//    [tester swipeViewWithAccessibilityLabel:ATLMSettingsHeaderAccessibilityLabel inDirection:KIFSwipeDirectionUp];
//    [tester waitForViewWithAccessibilityLabel:@"Log Out"];
//    [tester tapViewWithAccessibilityLabel:@"Log Out"];
//}
//
@end
