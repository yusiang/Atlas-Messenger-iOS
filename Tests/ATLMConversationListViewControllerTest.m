//
//  ATLMConversationViewControllerTest.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 1/15/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
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
