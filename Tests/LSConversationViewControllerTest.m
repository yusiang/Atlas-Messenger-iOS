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

extern NSString *const ATLConversationListViewControllerTitle;
extern NSString *const ATLConversationCollectionViewAccessibilityIdentifier;
extern NSString *const ATLAddressBarAccessibilityLabel;
extern NSString *const ATLMessageInputToolbarAccessibilityLabel;

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
    [tester waitForViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
    [tester tapViewWithAccessibilityLabel:LSComposeButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LSConversationViewControllerAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarAccessibilityLabel];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:LSDetailsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
}

- (void)testToVerifyExistingConversationViewControllerUI
{
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LSConversationViewControllerAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LSDetailsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
}

- (void)testToVerifyBackButtonFunctionality
{
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
    [tester tapViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
    [tester waitForViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
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
    [tester tapItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]  inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    [tester waitForViewWithAccessibilityLabel:LSMessageDetailViewControllerAccessibilityLabel];
}

- (void)testToVerifyDebugModeDisabledFunctionality
{
    self.testInterface.applicationController.debugModeEnabled = NO;
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
    [tester tapItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]  inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:LSMessageDetailViewControllerAccessibilityLabel];
}

@end
