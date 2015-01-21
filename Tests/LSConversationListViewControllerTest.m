//
//  LSConversationViewControllerTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 1/15/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "KIFTestCase.h"
#import <KIF/KIF.h>
#import "KIFSystemTestActor+ViewControllerActions.h"
#import <XCTest/XCTest.h>

#import "LSApplicationController.h"
#import "LSTestInterface.h"
#import "LSTestUser.h"

extern NSString *const LSConversationListTableViewAccessibilityLabel;
extern NSString *const LSConversationViewControllerAccessibilityLabel;
extern NSString *const LYRUIAddressBarAccessibilityLabel;
extern NSString *const LSSettingsButtonAccessibilityLabel;
extern NSString *const LSComposeButtonAccessibilityLabel;
extern NSString *const LSSettingsViewControllerTitle;

@interface LSConversationListViewControllerTest : KIFTestCase

@property (nonatomic) LSTestInterface *testInterface;

@end

@implementation LSConversationListViewControllerTest

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

- (void)testToVerifyConversationListViewControllerUI
{
    [tester waitForViewWithAccessibilityLabel:LSSettingsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LSComposeButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LSConversationListTableViewAccessibilityLabel];
}

- (void)testToVerifySettingsButtonFunctionality
{
    [tester tapViewWithAccessibilityLabel:LSSettingsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LSSettingsViewControllerTitle];
}

- (void)testToVerifyComposeButtonFunctionality
{
    [tester tapViewWithAccessibilityLabel:LSComposeButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LYRUIAddressBarAccessibilityLabel];
}

- (void)testToVerifyConversationSelectionFunctionality
{
    LSTestUser *testUser2 = [self.testInterface registerTestUser:[LSTestUser testUserWithNumber:2]];
    [self.testInterface loadContacts];
    
    NSSet *participants = [NSSet setWithObject:testUser2.userID];
    [self.testInterface.contentFactory newConversationsWithParticipants:participants];
    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:participants]];
    
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:participants]];
    [tester waitForViewWithAccessibilityLabel:LSConversationViewControllerAccessibilityLabel];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:LYRUIAddressBarAccessibilityLabel];
}

@end
