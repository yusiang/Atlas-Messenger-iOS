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

extern NSString *const LSComposeButtonAccessibilityLabel;
extern NSString *const LSConversationViewControllerAccessibilityLabel;
extern NSString *const LSDetailsButtonAccessibilityLabel;
extern NSString *const LSConversationDetailViewControllerTitle;
extern NSString *const LSMessageDetailViewControllerAccessibilityLabel;

extern NSString *const LYRUIConversationListViewControllerTitle;
extern NSString *const LYRUIConversationCollectionViewAccessibilityIdentifier;
extern NSString *const LYRUIAddressBarAccessibilityLabel;
extern NSString *const LYRUIMessageInputToolbarAccessibilityLabel;

@interface LSConversationViewControllerTest : KIFTestCase

@property (nonatomic) LSTestInterface *testInterface;
@property (nonatomic) NSSet *participants;

@end

@implementation LSConversationViewControllerTest

- (void)setUp
{
    [super setUp];
    LSApplicationController *applicationController =  [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [LSTestInterface testInterfaceWithApplicationController:applicationController];
    [self.testInterface registerAndAuthenticateTestUser:[LSTestUser testUserWithNumber:0]];
    
    LSTestUser *testUser2 = [self.testInterface registerTestUser:[LSTestUser testUserWithNumber:2]];
    [self.testInterface loadContacts];
    
    self.participants = [NSSet setWithObject:testUser2.userID];
    [self.testInterface.contentFactory newConversationsWithParticipants:self.participants];
    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
}

- (void)tearDown
{
    [self.testInterface logoutIfNeeded];
    [super tearDown];
}

- (void)testToVerifyNewConversationViewControllerUI
{
    [tester waitForViewWithAccessibilityLabel:LYRUIConversationListViewControllerTitle];
    [tester tapViewWithAccessibilityLabel:LSComposeButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LSConversationViewControllerAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LYRUIAddressBarAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LYRUIMessageInputToolbarAccessibilityLabel];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:LSDetailsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LYRUIConversationListViewControllerTitle];
}

- (void)testToVerifyExistingConversationViewControllerUI
{
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:LYRUIAddressBarAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LYRUIMessageInputToolbarAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LSConversationViewControllerAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LSDetailsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LYRUIConversationListViewControllerTitle];
}

- (void)testToVerifyBackButtonFunctionality
{
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
    [tester tapViewWithAccessibilityLabel:LYRUIConversationListViewControllerTitle];
    [tester waitForViewWithAccessibilityLabel:LYRUIConversationListViewControllerTitle];
}

- (void)testToVerifyDetailsButtonFunctionality
{
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
    [tester tapViewWithAccessibilityLabel:LSDetailsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LSConversationDetailViewControllerTitle];
}

- (void)testToVerifyDebugModeEnabledFunctionality
{
    self.testInterface.applicationController.debugModeEnabled = YES;
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
    [tester tapItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]  inCollectionViewWithAccessibilityIdentifier:LYRUIConversationCollectionViewAccessibilityIdentifier];
    [tester waitForViewWithAccessibilityLabel:LSMessageDetailViewControllerAccessibilityLabel];
}

- (void)testToVerifyDebugModeDisabledFunctionality
{
    self.testInterface.applicationController.debugModeEnabled = NO;
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
    [tester tapItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]  inCollectionViewWithAccessibilityIdentifier:LYRUIConversationCollectionViewAccessibilityIdentifier];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:LSMessageDetailViewControllerAccessibilityLabel];
}

@end
