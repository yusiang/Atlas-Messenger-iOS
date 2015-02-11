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
@property (nonatomic) LSTestUser *participant;
@property (nonatomic) NSSet *participantIdentifiers;

@end

@implementation LSConversationDetailViewControllerTest

- (void)setUp
{
    [super setUp];

    LSApplicationController *applicationController =  [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [LSTestInterface testInterfaceWithApplicationController:applicationController];
    [self.testInterface registerAndAuthenticateTestUser:[LSTestUser testUserWithNumber:0]];
    
    self.participant = [self.testInterface registerTestUser:[LSTestUser testUserWithNumber:2]];
    [self.testInterface loadContacts];
    
    self.participantIdentifiers = [NSSet setWithObject:self.participant.participantIdentifier];
    self.conversation = [self.testInterface.contentFactory newConversationsWithParticipants:self.participantIdentifiers];
    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participantIdentifiers]];
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
    [tester tapViewWithAccessibilityLabel:@"Remove"];
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
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participantIdentifiers]];
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

- (void)testToVerifyParticipantBlockingFunctionality
{
    [self navigateToConversationDetailViewController];
    
    [tester swipeViewWithAccessibilityLabel:self.participant.fullName inDirection:KIFSwipeDirectionLeft];
    [tester waitForViewWithAccessibilityLabel:@"Block"];
    [tester tapViewWithAccessibilityLabel:@"Block"];
    [tester waitForViewWithAccessibilityLabel:@"Blocked"];
    
    LYRPolicy *policy = self.testInterface.applicationController.layerClient.policies.firstObject;
    expect(policy).toNot.beNil;
    expect(policy.sentByUserID).to.equal(self.participant.participantIdentifier);
}

- (void)testToVerifyParticipantUnBlockingFunctionality
{
    LYRPolicy *policy = [LYRPolicy policyWithType:LYRPolicyTypeBlock];
    policy.sentByUserID = self.participant.participantIdentifier;
    NSError *error;
    [self.testInterface.applicationController.layerClient addPolicy:policy error:&error];
    expect(error).to.beNil;
    
    LYRPolicy *newPolicy = self.testInterface.applicationController.layerClient.policies.firstObject;
    expect(newPolicy).toNot.beNil;
    expect(newPolicy.sentByUserID).to.equal(self.participant.participantIdentifier);
    
    [self navigateToConversationDetailViewController];
    [tester waitForViewWithAccessibilityLabel:@"Blocked"];
    [tester swipeViewWithAccessibilityLabel:self.participant.fullName inDirection:KIFSwipeDirectionLeft];
    [tester waitForViewWithAccessibilityLabel:@"Unblock"];
    [tester tapViewWithAccessibilityLabel:@"Unblock"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Blocked"];
    
    NSOrderedSet *policies = self.testInterface.applicationController.layerClient.policies;
    expect(policies).to.beNil;
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

- (void)navigateToConversationDetailViewController
{
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participantIdentifiers]];
    [tester tapViewWithAccessibilityLabel:LSDetailsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LSConversationDetailViewControllerTitle];
}

@end
