//
//  ATLMConversationDetailViewControllerTest.m
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

#import "ATLMApplicationController.h"
#import "ATLMTestInterface.h"
#import "ATLMTestUser.h"

#import "ATLMConversationDetailViewController.h"

extern NSString *const ATLMConversationDetailViewControllerTitle;
extern NSString *const ATLMAddParticipantsAccessibilityLabel;
extern NSString *const ATLMConversationListTableViewAccessibilityLabel;
extern NSString *const ATLMDetailsButtonAccessibilityLabel;
extern NSString *const ATLMConversationNamePlaceholderText;

@interface ATLMConversationDetailViewControllerTest : KIFTestCase <ATLMConversationDetailViewControllerDelegate, ATLMConversationDetailViewControllerDataSource>

@property (nonatomic) LYRConversation *conversation;
@property (nonatomic) ATLMTestInterface *testInterface;
@property (nonatomic) ATLMTestUser *participant;
@property (nonatomic) NSSet *participantIdentifiers;

@end

@implementation ATLMConversationDetailViewControllerTest

- (void)setUp
{
    [super setUp];

    ATLMApplicationController *applicationController =  [(ATLMAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [ATLMTestInterface testInterfaceWithApplicationController:applicationController];
    [self.testInterface registerAndAuthenticateTestUser:[ATLMTestUser testUserWithNumber:0]];
    
    self.participant = [self.testInterface registerTestUser:[ATLMTestUser testUserWithNumber:2]];
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
    ATLMConversationDetailViewController *controller = [ATLMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.detailDataSource = self;
    controller.detailDelegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    [tester waitForTimeInterval:10];
}

- (void)testToVerifyConversationDetailViewControllerDelegateOnParticpantAdd
{
    ATLMTestUser *testUser3 = [self.testInterface registerTestUser:[ATLMTestUser testUserWithNumber:3]];
    [self.testInterface loadContacts];
    
    ATLMConversationDetailViewController *controller = [ATLMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    id delegateMock = OCMProtocolMock(@protocol(ATLMConversationDetailViewControllerDelegate));
    controller.detailDelegate = delegateMock;
    controller.detailDataSource = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        
    }] conversationDetailViewController:[OCMArg any] didChangeConversation:[OCMArg any]];
    
    [tester waitForViewWithAccessibilityLabel:[[ATLMTestUser testUserWithNumber:2] fullName]];
    [tester tapViewWithAccessibilityLabel:ATLMAddParticipantsAccessibilityLabel];
    [tester tapViewWithAccessibilityLabel:testUser3.fullName];

    [delegateMock verify];
}

- (void)testToVerifyConversationDetailViewControllerDelegateOnParticpantDelete
{
    ATLMConversationDetailViewController *controller = [ATLMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    id delegateMock = OCMProtocolMock(@protocol(ATLMConversationDetailViewControllerDelegate));
    controller.detailDelegate = delegateMock;
    controller.detailDataSource = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        
    }] conversationDetailViewController:[OCMArg any] didChangeConversation:[OCMArg any]];
    
    [tester waitForViewWithAccessibilityLabel:[[ATLMTestUser testUserWithNumber:2] fullName]];
    [tester swipeViewWithAccessibilityLabel:[[ATLMTestUser testUserWithNumber:2] fullName] inDirection:KIFSwipeDirectionLeft];
    [tester tapViewWithAccessibilityLabel:@"Remove"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:[[ATLMTestUser testUserWithNumber:2] fullName]];
    [delegateMock verify];
}

- (void)testToVeriyConversationDetailViewDelegateOnLocationShare
{
//    ATLMConversationDetailViewController *controller = [ATLMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
//    controller.applicationController = self.testInterface.applicationController;
//    id delegateMock = OCMProtocolMock(@protocol(ATLMConversationDetailViewControllerDelegate));
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
    ATLMConversationDetailViewController *controller = [ATLMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    id delegateMock = OCMProtocolMock(@protocol(ATLMConversationDetailViewControllerDataSource));
    controller.detailDataSource = delegateMock;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];

    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        
    }] conversationDetailViewController:[OCMArg any] participantForIdentifier:[OCMArg any]];
    
    [tester waitForViewWithAccessibilityLabel:[[ATLMTestUser testUserWithNumber:2] fullName]];
    [delegateMock verify];
}

- (void)testToVerifyConversationDeletionFunctionality
{
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participantIdentifiers]];
    [tester tapViewWithAccessibilityLabel:ATLMDetailsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLMConversationDetailViewControllerTitle];
    
    [tester tapViewWithAccessibilityLabel:@"Global Delete Conversation"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:ATLMConversationDetailViewControllerTitle];
    [tester waitForViewWithAccessibilityLabel:ATLMConversationListTableViewAccessibilityLabel];
}

- (void)testToVerifyMetadataFunctionality
{
    ATLMConversationDetailViewController *controller = [ATLMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    id delegateMock = OCMProtocolMock(@protocol(ATLMConversationDetailViewControllerDataSource));
    controller.detailDataSource = delegateMock;
    controller.detailDataSource = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    
    NSString *conversationName = @"New Name";
    [tester tapViewWithAccessibilityLabel:ATLMConversationNamePlaceholderText];
    [tester enterText:conversationName intoViewWithAccessibilityLabel:ATLMConversationNamePlaceholderText];
    [tester tapViewWithAccessibilityLabel:@"done"];
    
    [tester waitForViewWithAccessibilityLabel:conversationName];
    expect([self.conversation.metadata valueForKey:ATLMConversationMetadataNameKey]).to.equal(conversationName);

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

- (void)conversationDetailViewController:(ATLMConversationDetailViewController *)conversationDetailViewController didChangeConversation:(LYRConversation *)conversation
{
    expect(conversationDetailViewController).toNot.beNil;
    expect(conversation).toNot.beNil;
}

- (void)conversationDetailViewController:(ATLMConversationDetailViewController *)conversationDetailViewController didShareLocation:(CLLocation *)location
{
    expect(conversationDetailViewController).toNot.beNil;
    expect(location).toNot.beNil;
}

- (id<ATLParticipant>)conversationDetailViewController:(ATLMConversationDetailViewController *)conversationDetailViewController participantForIdentifier:(NSString *)participantIdentifier
{
    expect(conversationDetailViewController).toNot.beNil;
    expect(participantIdentifier).toNot.beNil;
    return [self.testInterface userForIdentifier:participantIdentifier];
}

- (void)navigateToConversationDetailViewController
{
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.participantIdentifiers]];
    [tester tapViewWithAccessibilityLabel:ATLMDetailsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLMConversationDetailViewControllerTitle];
}

@end
