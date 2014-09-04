//
//  LYRUIConversationListTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "KIFTestCase.h"
#import <KIF/KIF.h>
#import <OCMock/OCMock.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <LayerKit/LayerKit.h>
#import "KIFSystemTestActor+ViewControllerActions.h"
#import "KIFUITestActor+LSAdditions.h"
#import "LYRCountdownLatch.h"
#import "LSApplicationController.h"
#import "LSAppDelegate.h"
#import "LYRUIConversationListViewController.h"
#import "LYRUITestUser.h"
#import "LYRCountDownLatch.h"
#import "LYRUITestInterface.h"
#import "LYRUILayerContentFactory.h"


#define EXP_SHORTHAND

@interface LYRUIConversationListTest : XCTestCase

@property (nonatomic, strong) LYRUITestInterface *testInterface;
@property (nonatomic, strong) LYRUILayerContentFactory *layerContentFactory;

@end

@implementation LYRUIConversationListTest

- (void)setUp
{
    [super setUp];
    
    LSApplicationController *applicationController =  [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    
    self.testInterface = [LYRUITestInterface testInterfaceWithApplicationController:applicationController];
    self.layerContentFactory = [LYRUILayerContentFactory layerContentFactoryWithLayerClient:applicationController.layerClient];

    NSString *userID0 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:0]];
    NSString *userID1 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    NSString *userID2 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:2]];
   
    
    NSSet *participantIdentifiers = [NSSet setWithObjects:userID0, userID1, userID2, nil];
    
    LSUser *user = [LYRUITestUser testUserWithNumber:3];
    [self.testInterface registerUser:user];
    [self.testInterface authenticateWithEmail:user.email password:user.password];
    [self.testInterface loadContacts];
    [tester waitForTimeInterval:1];
    
    //[self.layerContentFactory conversationsWithParticipants:participantIdentifiers number:10];

}

- (void)tearDown
{
    [self.testInterface deleteContacts];
    [self.testInterface logout];
    
    self.testInterface = nil;
    
    [super tearDown];
}

//Load the list and verify that all conversations returned by conversationForIdentifiers: is presented in the list.
- (void)testToVerifyConversationListDisplaysAllConversationsInLayer
{
    NSSet *conversations = [self.testInterface.applicationController.layerClient conversationsForIdentifiers:nil];
    for (LYRConversation *conversation in conversations) {
        [tester waitForViewWithAccessibilityLabel:[self conversationLabelForParticipants:conversation.participants]];
    }
}

//Search for text that exists in a known message and verify that it appears.
- (void)testToVerfiyMessageSearchFunctionalityForKnownMessageText
{
    NSError *error;
    NSSet *users = [self.testInterface.applicationController.persistenceManager persistedUsersWithError:&error];
    expect(users).toNot.beNil;
    expect(error).to.beNil;
    
    LSUser *user = [[users allObjects] objectAtIndex:0];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user.userID] number:1];
    
    [self conversationLabelForParticipants:[NSSet setWithObject:user.userID]];
  
    [tester swipeViewWithAccessibilityLabel:@"Conversation List" inDirection:KIFSwipeDirectionDown];
    [tester tapViewWithAccessibilityLabel:@"Search Bar"];
    [tester enterText:user.fullName intoViewWithAccessibilityLabel:@"Search Bar"];
    [tester waitForViewWithAccessibilityLabel:user.fullName];
}

//Search for text that does not appear in any message and verify the list is empty.
- (void)testToVerifyMessageSearchFunctionalityForUnknownMessageText
{
    [tester swipeViewWithAccessibilityLabel:@"Conversation List" inDirection:KIFSwipeDirectionDown];
    
    NSString *searchText = @"This is fake text";
    [tester tapViewWithAccessibilityLabel:@"Search Bar"];
    [tester enterText:searchText intoViewWithAccessibilityLabel:@"Search Bar"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Search Bar"];
}

//Test swipe to delete for deleting a conversation. Verify the conversation is deleted from the table and from the Layer client.
- (void)testToVerifyDeletionOfConversationFunctionality
{
    [(LYRUIConversationListViewController *)[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController.presentedViewController setAllowsEditing:TRUE];
                                            
    NSError *error;
    NSSet *users = [self.testInterface.applicationController.persistenceManager persistedUsersWithError:&error];
    expect(users).toNot.beNil;
    expect(error).to.beNil;
    
    LSUser *user = [[users allObjects] objectAtIndex:0];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user.userID] number:1];
    
    NSString *conversationLabel = [self conversationLabelForParticipants:[NSSet setWithObject:user.userID]];
    [tester swipeViewWithAccessibilityLabel:conversationLabel inDirection:KIFSwipeDirectionLeft];
    [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Delete %@ ", user.fullName]];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:conversationLabel];
}

//Test engaging editing mode and deleting several conversations at once. Verify that all conversations selected are deleted from the table and from the Layer client.
- (void)testToVerifyEditingModeAndMultipleConversationDeletionFunctionality
{
    [(LYRUIConversationListViewController *)[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController.presentedViewController setAllowsEditing:TRUE];
    
    NSError *error;
    NSSet *users = [self.testInterface.applicationController.persistenceManager persistedUsersWithError:&error];
    expect(users).toNot.beNil;
    expect(error).to.beNil;
    
    LSUser *user0 = [[users allObjects] objectAtIndex:0];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user0.userID] number:1];
  
    LSUser *user1 = [[users allObjects] objectAtIndex:1];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user1.userID] number:1];
    
    LSUser *user2 = [[users allObjects] objectAtIndex:2];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user2.userID] number:1];
    
    LSUser *user3 = [[users allObjects] objectAtIndex:3];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user3.userID] number:1];
    
    [tester tapViewWithAccessibilityLabel:@"Edit"];
    NSString *conversationLabel = [self conversationLabelForParticipants:[NSSet setWithObject:user0.userID]];
    [tester swipeViewWithAccessibilityLabel:conversationLabel inDirection:KIFSwipeDirectionLeft];
    [tester waitForTimeInterval:10];
}

//Disable editing and verify that the controller does not permit the user to attempt to edit or engage swipe to delete.
- (void)testToVerifyDisablingEditModeDoesNotAllowUserToDeleteConversations
{
    
}

//Customize the fonts and colors using UIAppearance and verify that the configuration is respected.
- (void)testToVerifyColorAndFontChangeFunctionality
{
    
}

//Customize the row height and ensure that it is respected.
- (void)testToVerifyCustomRowHeightFunctionality
{
    
}

//Customize the cell class and ensure that the correct cell is used to render the table.
-(void)testToVerifyCustomCellClassFunctionality
{
    
}

//Verify that attempting to provide a cell class that does not conform to LYRUIConversationPresenting results in a runtime exception.
- (void)testToVerifyCustomCellClassNotConformingToProtocolRaisesException
{
    
}

//Verify that attempting to change the cell class after the table is loaded results in a runtime error.
- (void)testToVerifyChangingCellClassAfterViewLoadRaiseException
{
    
}

//Synchronize a new conversation and verify that it live updates into the conversation list.
- (void)testToVerifyCreatingANewConversationLiveUpdatesConversationList
{
    NSString *userID = self.testInterface.applicationController.layerClient.authenticatedUserID;
    [self.testInterface logout];
    
    LSUser *user2 = [LYRUITestUser testUserWithNumber:2];
    [self.testInterface registerUser:user2];
    [self.testInterface authenticateWithEmail:user2.email password:user2.password];
    [self.testInterface loadContacts];
    [tester waitForTimeInterval:1];

    LYRConversation *conversation = [LYRConversation conversationWithParticipants:[NSSet setWithObject:userID]];
    LYRMessagePart *messagePart = [LYRMessagePart messagePartWithText:@"This is a test message"];
    LYRMessage *message = [LYRMessage messageWithConversation:conversation parts:@[messagePart]];
    
    NSError *error;
    BOOL success = [self.testInterface.applicationController.layerClient sendMessage:message error:&error];
    expect(success).to.beTruthy;
    expect(error).to.beNil;
    
    [tester waitForViewWithAccessibilityLabel:[self conversationLabelForParticipants:conversation.participants]];
}

- (NSString *)conversationLabelForParticipants:(NSSet *)participantIdentifiers
{
    NSMutableSet *participantIDs = [NSMutableSet setWithSet:participantIdentifiers];
    
    if ([participantIDs containsObject:self.testInterface.applicationController.layerClient.authenticatedUserID]) {
        [participantIDs removeObject:self.testInterface.applicationController.layerClient.authenticatedUserID];
    }
    
    NSSet *participants = [self.testInterface.applicationController.persistenceManager participantsForIdentifiers:participantIdentifiers];
    
    LSUser *firstUser = [[participants allObjects] objectAtIndex:0];
    NSString *conversationLabel = firstUser.fullName;
    for (int i = 1; i < [[participants allObjects] count]; i++) {
        LSUser *user = [[participants allObjects] objectAtIndex:i];
        conversationLabel = [NSString stringWithFormat:@"%@, %@", conversationLabel, user.fullName];
    }
    return conversationLabel;
    
}

@end
