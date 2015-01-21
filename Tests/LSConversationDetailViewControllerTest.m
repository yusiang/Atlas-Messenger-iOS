//
//  LSConversationDetailViewControllerTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 1/15/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "KIFTestCase.h"
#import <KIF/KIF.h>
#import "KIFSystemTestActor+ViewControllerActions.h"

#import "LSApplicationController.h"
#import "LSTestInterface.h"
#import "LSTestUser.h"

#import "LSConversationDetailViewController.h"

extern NSString *const LSConversationDetailViewControllerTitle;
extern NSString *const LSAddParticipantsAccessibilityLabel;
extern NSString *const LSConversationListTableViewAccessibilityLabel;
extern NSString *const LSDetailsButtonAccessibilityLabel;
extern NSString *const LSConversationNamePlaceholderText;

@interface LSConversationDetailViewControllerTest : KIFTestCase <LSConversationDetailViewControllerDelegate, LSConversationDetailViewControllerDataSource>

@property (nonatomic) LYRConversation *conversation;
@property (nonatomic) LSTestInterface *testInterface;
@property (nonatomic) NSSet *participants;

@end

@implementation LSConversationDetailViewControllerTest

- (void)setUp
{
    [super setUp];
    LSApplicationController *applicationController =  [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [LSTestInterface testInterfaceWithApplicationController:applicationController];
    [self.testInterface registerAndAuthenticateTestUser:[LSTestUser testUserWithNumber:0]];
    
    LSTestUser *testUser2 = [self.testInterface registerTestUser:[LSTestUser testUserWithNumber:2]];
    [self.testInterface loadContacts];
    
    self.participants = [NSSet setWithObject:testUser2.userID];
    self.conversation = [self.testInterface.contentFactory newConversationsWithParticipants:self.participants];
    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
}

- (void)tearDown
{
    [self.testInterface logoutIfNeeded];
    [super tearDown];
}

- (void)testToVerifyConversationDetailViewControllerUI
{
    LSConversationDetailViewController *controller = [LSConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.detailDataSource = self;
    controller.detailDelegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    [tester waitForTimeInterval:10];
}

- (void)testToVerifyConversationDetailViewControllerDelegateOnParticpantAdd
{
    LSTestUser *testUser3 = [self.testInterface registerTestUser:[LSTestUser testUserWithNumber:3]];
    [self.testInterface loadContacts];
    
    LSConversationDetailViewController *controller = [LSConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    id delegateMock = OCMProtocolMock(@protocol(LSConversationDetailViewControllerDelegate));
    controller.detailDelegate = delegateMock;
    controller.detailDataSource = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        
    }] conversationDetailViewController:[OCMArg any] didChangeConversation:[OCMArg any]];
    
    [tester waitForViewWithAccessibilityLabel:[[LSTestUser testUserWithNumber:2] fullName]];
    [tester tapViewWithAccessibilityLabel:LSAddParticipantsAccessibilityLabel];
    [tester tapViewWithAccessibilityLabel:testUser3.fullName];

    [delegateMock verify];
}

- (void)testToVerifyConversationDetailViewControllerDelegateOnParticpantDelete
{
    LSConversationDetailViewController *controller = [LSConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    id delegateMock = OCMProtocolMock(@protocol(LSConversationDetailViewControllerDelegate));
    controller.detailDelegate = delegateMock;
    controller.detailDataSource = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        
    }] conversationDetailViewController:[OCMArg any] didChangeConversation:[OCMArg any]];
    
    [tester waitForViewWithAccessibilityLabel:[[LSTestUser testUserWithNumber:2] fullName]];
    [tester swipeViewWithAccessibilityLabel:[[LSTestUser testUserWithNumber:2] fullName] inDirection:KIFSwipeDirectionLeft];
    [tester tapViewWithAccessibilityLabel:@"Delete"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:[[LSTestUser testUserWithNumber:2] fullName]];
    [delegateMock verify];
}

- (void)testToVeriyConversationDetailViewDelegateOnLocationShare
{
//    LSConversationDetailViewController *controller = [LSConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
//    controller.applicationController = self.testInterface.applicationController;
//    id delegateMock = OCMProtocolMock(@protocol(LSConversationDetailViewControllerDelegate));
//    controller.detailDelegate = delegateMock;
//    controller.detailDataSource = self;
//    
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
//    [system presentModalViewController:navigationController configurationBlock:nil];
//    
//    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
//        
//    }] conversationDetailViewController:[OCMArg any] didShareLocation:[OCMArg any]];
//    
//    [tester tapViewWithAccessibilityLabel:@"Share My Location"];
//    [delegateMock verifyWithDelay:2];
}

- (void)testToVerifyConversationDetailViewDataSource
{
    LSConversationDetailViewController *controller = [LSConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    id delegateMock = OCMProtocolMock(@protocol(LSConversationDetailViewControllerDataSource));
    controller.detailDataSource = delegateMock;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];

    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        
    }] conversationDetailViewController:[OCMArg any] participantForIdentifier:[OCMArg any]];
    
    [tester waitForViewWithAccessibilityLabel:[[LSTestUser testUserWithNumber:2] fullName]];
    [delegateMock verify];
}

- (void)testToVerifyConversationDeletionFunctionality
{
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participants]];
    [tester tapViewWithAccessibilityLabel:LSDetailsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LSConversationDetailViewControllerTitle];
    
    [tester tapViewWithAccessibilityLabel:@"Global Delete Conversation"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:LSConversationDetailViewControllerTitle];
    [tester waitForViewWithAccessibilityLabel:LSConversationListTableViewAccessibilityLabel];
}

- (void)testToVerifyMetadataFunctionality
{
    LSConversationDetailViewController *controller = [LSConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    id delegateMock = OCMProtocolMock(@protocol(LSConversationDetailViewControllerDataSource));
    controller.detailDataSource = delegateMock;
    controller.detailDataSource = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    
    NSString *conversationName = @"New Name";
    [tester tapViewWithAccessibilityLabel:LSConversationNamePlaceholderText];
    [tester enterText:conversationName intoViewWithAccessibilityLabel:LSConversationNamePlaceholderText];
    [tester tapViewWithAccessibilityLabel:@"done"];
    
    [tester waitForViewWithAccessibilityLabel:conversationName];
    expect([self.conversation.metadata valueForKey:LSConversationMetadataNameKey]).to.equal(conversationName);

}

- (void)conversationDetailViewController:(LSConversationDetailViewController *)conversationDetailViewController didChangeConversation:(LYRConversation *)conversation
{
    expect(conversationDetailViewController).toNot.beNil;
    expect(conversation).toNot.beNil;
}

- (void)conversationDetailViewController:(LSConversationDetailViewController *)conversationDetailViewController didShareLocation:(CLLocation *)location
{
    expect(conversationDetailViewController).toNot.beNil;
    expect(location).toNot.beNil;
}

- (id<LYRUIParticipant>)conversationDetailViewController:(LSConversationDetailViewController *)conversationDetailViewController participantForIdentifier:(NSString *)participantIdentifier
{
    expect(conversationDetailViewController).toNot.beNil;
    expect(participantIdentifier).toNot.beNil;
    return [self.testInterface userForIdentifier:participantIdentifier];
}


@end
