//
//  LSSettingsViewControllerTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 1/20/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "KIFTestCase.h"
#import <KIF/KIF.h>
#import "KIFSystemTestActor+ViewControllerActions.h"
#import <XCTest/XCTest.h>

#import "LSTestInterface.h"
#import "LSTestUser.h"
#import "LSSettingsHeaderView.h"
#import "LSSettingsViewController.h"

extern NSString *const LSConversationListTableViewAccessibilityLabel;
extern NSString *const LSSettingsTableViewAccessibilityIdentifier;
extern NSString *const LSSettingsHeaderAccessibilityLabel;
extern NSString *const LSPushNotificationSettingSwitch;
extern NSString *const LSLocalNotificationSettingSwitch;
extern NSString *const LSDebugModeSettingSwitch;


@interface LSSettingsViewControllerTest : KIFTestCase

@property (nonatomic) LSTestInterface *testInterface;

@end

@implementation LSSettingsViewControllerTest

- (void)setUp
{
    [super setUp];
    LSApplicationController *applicationController =  [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [LSTestInterface testInterfaceWithApplicationController:applicationController];
    [self.testInterface registerAndAuthenticateTestUser:[LSTestUser testUserWithNumber:0]];
    
}

- (void)tearDown
{
    [self.testInterface logoutIfNeeded];
    [super tearDown];
}

- (void)testToVerifyHeaderUI
{
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    LSUser *user = self.testInterface.applicationController.APIManager.authenticatedSession.user;
    [tester waitForViewWithAccessibilityLabel:LSSettingsHeaderAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:user.fullName];
    [tester waitForViewWithAccessibilityLabel:@"Connected"];
}

- (void)testToVerifyDoneButtonFunctionality
{
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester waitForViewWithAccessibilityLabel:LSConversationListTableViewAccessibilityLabel];
}

- (void)testToVerifySettingsDelegateFunctionalityOnDoneButtonTap
{
    LSSettingsViewController *controller = [[LSSettingsViewController alloc] init];
    controller.applicationController = self.testInterface.applicationController;
    id delegateMock = OCMProtocolMock(@protocol(LSSettingsViewControllerDelegate));
    controller.settingsDelegate = delegateMock;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        
    }] settingsViewControllerDidFinish:[OCMArg any]];
    
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [delegateMock verify];
}

- (void)testToVerifySettingsDelegateFunctionalityOnLogoutButtonTap
{
    LSSettingsViewController *controller = [[LSSettingsViewController alloc] init];
    controller.applicationController = self.testInterface.applicationController;
    id delegateMock = OCMProtocolMock(@protocol(LSSettingsViewControllerDelegate));
    controller.settingsDelegate = delegateMock;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];

    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        
    }] logoutTappedInSettingsViewController:[OCMArg any]];
    
    [tester swipeViewWithAccessibilityLabel:LSSettingsHeaderAccessibilityLabel inDirection:KIFSwipeDirectionUp];
    [tester waitForViewWithAccessibilityLabel:@"Log Out"];
    [tester tapViewWithAccessibilityLabel:@"Log Out"];
    [delegateMock verify];
}

- (void)testToVerifySendPushNotificationSwitchFunctionality
{
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    UISwitch *switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:LSPushNotificationSettingSwitch];
    expect(switchControl.on).to.beFalsy;
    [tester setOn:YES forSwitchWithAccessibilityLabel:LSPushNotificationSettingSwitch];
    [self.testInterface logoutIfNeeded];
   
    LSTestUser *user = [LSTestUser testUserWithNumber:0];
    [self.testInterface authenticateTestUser:user];
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:LSPushNotificationSettingSwitch];
    expect(switchControl.on).to.beTruthy;
    [tester setOn:NO forSwitchWithAccessibilityLabel:LSPushNotificationSettingSwitch];
    [self.testInterface logoutIfNeeded];
    
    [self.testInterface authenticateTestUser:user];
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:LSPushNotificationSettingSwitch];
    expect(switchControl.on).to.beFalsy;
}

- (void)testToVerifyDisplayLocalNotificationSwitchFunctionality
{
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    UISwitch *switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:LSLocalNotificationSettingSwitch];
    expect(switchControl.on).to.beFalsy;
    [tester setOn:YES forSwitchWithAccessibilityLabel:LSLocalNotificationSettingSwitch];
    [self.testInterface logoutIfNeeded];
    
    LSTestUser *user = [LSTestUser testUserWithNumber:0];
    [self.testInterface authenticateTestUser:user];
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:LSLocalNotificationSettingSwitch];
    expect(switchControl.on).to.beTruthy;
    [tester setOn:NO forSwitchWithAccessibilityLabel:LSLocalNotificationSettingSwitch];
    [self.testInterface logoutIfNeeded];
    
    [self.testInterface authenticateTestUser:user];
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:LSLocalNotificationSettingSwitch];
    expect(switchControl.on).to.beFalsy;
}

- (void)testTiVerifyDebugModeSwitchFunctionality
{
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    UISwitch *switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:LSDebugModeSettingSwitch];
    expect(switchControl.on).to.beFalsy;
    [tester setOn:YES forSwitchWithAccessibilityLabel:LSDebugModeSettingSwitch];
    [self.testInterface logoutIfNeeded];
    
    LSTestUser *user = [LSTestUser testUserWithNumber:0];
    [self.testInterface authenticateTestUser:user];
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:LSDebugModeSettingSwitch];
    expect(switchControl.on).to.beTruthy;
    [tester setOn:NO forSwitchWithAccessibilityLabel:LSDebugModeSettingSwitch];
    [self.testInterface logoutIfNeeded];
    
    [self.testInterface authenticateTestUser:user];
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    switchControl = (UISwitch *)[tester waitForTappableViewWithAccessibilityLabel:LSDebugModeSettingSwitch];
    expect(switchControl.on).to.beFalsy;
}

- (void)testToVerifyLayerStatistics
{
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    NSError *error;
    NSUInteger conversationCount = [self.testInterface.applicationController.layerClient countForQuery:query error:&error];
    expect(error).to.beFalsy;
    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Conversations:, %lu", (unsigned long)conversationCount]];
    
    query = [LYRQuery queryWithClass:[LYRMessage class]];
    NSUInteger messageCount = [self.testInterface.applicationController.layerClient countForQuery:query error:&error];
    expect(error).to.beFalsy;
    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Messages:, %lu", (unsigned long)messageCount]];
    
    query = [LYRQuery queryWithClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"isUnread" operator:LYRPredicateOperatorIsEqualTo value:@(YES)];
    NSUInteger unreadMessageCount = [self.testInterface.applicationController.layerClient countForQuery:query error:&error];
    expect(error).to.beFalsy;
    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Unread Messages:, %lu", (unsigned long)unreadMessageCount]];
}

- (void)testToVerifyLogoutButtonFunctionality
{
    [tester tapViewWithAccessibilityLabel:@"Settings"];
    [tester swipeViewWithAccessibilityLabel:LSSettingsHeaderAccessibilityLabel inDirection:KIFSwipeDirectionUp];
    [tester waitForViewWithAccessibilityLabel:@"Log Out"];
    [tester tapViewWithAccessibilityLabel:@"Log Out"];
}

@end
