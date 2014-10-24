//
//  LYRUIConversationListTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "KIFTestCase.h"
#import <KIF/KIF.h>
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
#import "LSUIConversationListViewController.h"
#import "LYRUIConversationTableViewCell.h"
#import "LYRUITestConversationCell.h"
#include <stdlib.h>

#define EXP_SHORTHAND

@interface LYRUIConversationListTest : XCTestCase

@property (nonatomic) LYRUITestInterface *testInterface;
@property (nonatomic) LYRUILayerContentFactory *layerContentFactory;

@end

@implementation LYRUIConversationListTest

- (void)setUp
{
    [super setUp];
    
    LSApplicationController *applicationController =  [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [LYRUITestInterface testInterfaceWithApplicationController:applicationController];
    self.layerContentFactory = [LYRUILayerContentFactory layerContentFactoryWithLayerClient:applicationController.layerClient];
    [self.testInterface deleteContacts];
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
    LSUser *user1 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    LSUser *user2 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:2]];
    LSUser *user3 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:3]];
    LSUser *user4 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:4]];
    
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:0]];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user1.userID] number:1];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user2.userID] number:2];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user3.userID] number:3];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user4.userID] number:4];
    [tester waitForTimeInterval:5];
    
    NSSet *conversations = [self.testInterface.applicationController.layerClient conversationsForIdentifiers:nil];
    for (LYRConversation *conversation in conversations) {
        [tester waitForViewWithAccessibilityLabel:[self conversationLabelForParticipants:conversation.participants]];
    }
}

//Test swipe to delete for deleting a conversation. Verify the conversation is deleted from the table and from the Layer client.
- (void)testToVerifyGlobalDeletionButtonFunctionality
{
    LSAppDelegate *appDelegate = (LSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setAllowsEditing:YES];
    
    LSUser *user1 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:0]];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user1.userID] number:1];
    
    NSString *conversationLabel = [self conversationLabelForParticipants:[NSSet setWithObject:user1.userID]];
    
    [tester waitForViewWithAccessibilityLabel:conversationLabel];
    [tester swipeViewWithAccessibilityLabel:conversationLabel inDirection:KIFSwipeDirectionLeft];
    [self deleteConversationWithUserIDs:[NSSet setWithObject:user1.userID] deletionMode:LYRDeletionModeAllParticipants];
}

//Test swipe to delete for deleting a conversation. Verify the conversation is deleted from the table and from the Layer client.
- (void)testToVerifyLocalDeletionButtonFunctionality
{
    LSAppDelegate *appDelegate = (LSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setAllowsEditing:YES];
    
    LSUser *user1 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:0]];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user1.userID] number:1];
    
    NSString *conversationLabel = [self conversationLabelForParticipants:[NSSet setWithObject:user1.userID]];
    
    [tester waitForViewWithAccessibilityLabel:conversationLabel];
    [tester swipeViewWithAccessibilityLabel:conversationLabel inDirection:KIFSwipeDirectionLeft];
    [self deleteConversationWithUserIDs:[NSSet setWithObject:user1.userID] deletionMode:LYRDeletionModeLocal];
}

//Test swipe to delete for deleting a conversation. Verify the conversation is deleted from the table and from the Layer client.
- (void)testToVerifyConversationDoesNotPersistAcrossSessionsAfterGlobalDelete
{
    LSAppDelegate *appDelegate = (LSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setAllowsEditing:YES];
    
    LSUser *user1 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:0]];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user1.userID] number:1];
    
    NSString *conversationLabel = [self conversationLabelForParticipants:[NSSet setWithObject:user1.userID]];
    
    [tester waitForViewWithAccessibilityLabel:conversationLabel];
    [tester swipeViewWithAccessibilityLabel:conversationLabel inDirection:KIFSwipeDirectionLeft];
    [self deleteConversationWithUserIDs:[NSSet setWithObject:user1.userID] deletionMode:LYRDeletionModeAllParticipants];
    
    [self.testInterface logout];
    
    [self.testInterface authenticateWithEmail:[LYRUITestUser testUserWithNumber:0].email password:[LYRUITestUser testUserWithNumber:0].password];
    [tester waitForTimeInterval:5];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:conversationLabel];
}

//Test swipe to delete for deleting a conversation. Verify the conversation is deleted from the table and from the Layer client.
- (void)testToVerifyConversationDoesPersistAcrossSecssionsAfterLocalDelete
{
    LSAppDelegate *appDelegate = (LSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setAllowsEditing:YES];
    
    LSUser *user1 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:0]];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user1.userID] number:1];
    
    NSString *conversationLabel = [self conversationLabelForParticipants:[NSSet setWithObject:user1.userID]];
    
    [tester waitForViewWithAccessibilityLabel:conversationLabel];
    [tester swipeViewWithAccessibilityLabel:conversationLabel inDirection:KIFSwipeDirectionLeft];
    [self deleteConversationWithUserIDs:[NSSet setWithObject:user1.userID] deletionMode:LYRDeletionModeLocal];
    
    [self.testInterface logout];
    
    [self.testInterface authenticateWithEmail:[LYRUITestUser testUserWithNumber:0].email password:[LYRUITestUser testUserWithNumber:0].password];
    [tester waitForViewWithAccessibilityLabel:conversationLabel];
}

//Test engaging editing mode and deleting several conversations at once. Verify that all conversations selected are deleted from the table and from the Layer client.
- (void)testToVerifyEditingModeAndMultipleConversationDeletionFunctionality
{
    LSAppDelegate *appDelegate = (LSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setAllowsEditing:YES];
    [appDelegate setDisplaysSettingsButton:NO];
    
    LSUser *user1 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    LSUser *user2 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:2]];
    LSUser *user3 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:3]];
    
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:0]];
    
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user1.userID] number:1];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user2.userID] number:1];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user3.userID] number:1];
    [tester waitForTimeInterval:5];
    
    [tester tapViewWithAccessibilityLabel:@"Edit"];
    
    [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Delete %@", user1.fullName]];
    [self deleteConversationWithUserIDs:[NSSet setWithObject:user1.userID] deletionMode:LYRDeletionModeLocal];
    
    [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Delete %@", user2.fullName]];
    [self deleteConversationWithUserIDs:[NSSet setWithObject:user2.userID] deletionMode:LYRDeletionModeLocal];
    
    [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Delete %@", user3.fullName]];
    [self deleteConversationWithUserIDs:[NSSet setWithObject:user3.userID] deletionMode:LYRDeletionModeLocal];
}

//Disable editing and verify that the controller does not permit the user to attempt to edit or engage swipe to delete.
- (void)testToVerifyDisablingEditModeDoesNotAllowUserToDeleteConversations
{
    LSAppDelegate *appDelegate = (LSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setAllowsEditing:NO];
    
    LSUser *user1 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:0]];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user1.userID] number:1];

    NSString *conversationLabel = [self conversationLabelForParticipants:[NSSet setWithObject:user1.userID]];
    
    [tester swipeViewWithAccessibilityLabel:conversationLabel inDirection:KIFSwipeDirectionLeft];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:[NSString stringWithFormat:@"Global"]];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:[NSString stringWithFormat:@"Local"]];
}

//Customize the fonts and colors using UIAppearance and verify that the configuration is respected.
- (void)testToVerifyColorAndFontChangeFunctionality
{
    LSUser *user1 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:0]];
    
    UIFont *testFont = [UIFont systemFontOfSize:20];
    UIColor *testColor = [UIColor redColor];
    
    [[LYRUIConversationTableViewCell appearance] setConversationLabelFont:testFont];
    [[LYRUIConversationTableViewCell appearance] setConversationLableColor:testColor];
    
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user1.userID] number:1];
    
    NSString *conversationLabel = [self conversationLabelForParticipants:[NSSet setWithObject:user1.userID]];
    
    LYRUIConversationTableViewCell *cell = (LYRUIConversationTableViewCell *)[tester waitForViewWithAccessibilityLabel:conversationLabel];
    expect(cell.conversationLabelFont).to.equal(testFont);
    expect(cell.conversationLableColor).to.equal(testColor);
}

//Customize the row height and ensure that it is respected.
- (void)testToVerifyCustomRowHeightFunctionality
{
    LSAppDelegate *appDelegate = (LSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setRowHeight:100];
    
    LSUser *user1 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:0]];
    
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user1.userID] number:1];
    
    NSString *conversationLabel = [self conversationLabelForParticipants:[NSSet setWithObject:user1.userID]];
    
    LYRUIConversationTableViewCell *cell = (LYRUIConversationTableViewCell *)[tester waitForViewWithAccessibilityLabel:conversationLabel];
    
    expect(cell.frame.size.height).to.equal(100);
    [appDelegate setRowHeight:72];
}

//Customize the cell class and ensure that the correct cell is used to render the table.
-(void)testToVerifyCustomCellClassFunctionality
{
    LSAppDelegate *appDelegate = (LSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setCellClass:[LYRUITestConversationCell class]];
    
    LSUser *user1 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:0]];
    
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user1.userID] number:1];
    
    NSString *conversationLabel = [self conversationLabelForParticipants:[NSSet setWithObject:user1.userID]];
    LYRUIConversationTableViewCell *cell = (LYRUIConversationTableViewCell *)[tester waitForViewWithAccessibilityLabel:conversationLabel];
    
    expect([cell class]).to.equal([LYRUITestConversationCell class]);
    expect([cell class]).toNot.equal([LYRUIConversationTableViewCell class]);
}

//Verify that attempting to provide a cell class that does not conform to LYRUIConversationPresenting results in a runtime exception.
- (void)testToVerifyCustomCellClassNotConformingToProtocolRaisesException
{
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:0]];
    LSUIConversationListViewController *controller = [self conversationListViewController];
    expect(^{ [controller setCellClass:[UITableViewCell class]]; }).to.raise(NSInternalInconsistencyException);
}

//Verify that attempting to change the cell class after the table is loaded results in a runtime error.
- (void)testToVerifyChangingCellClassAfterViewLoadRaiseException
{
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:0]];
    LSUIConversationListViewController *controller = [self conversationListViewController];
    expect(^{ [controller setCellClass:[LYRUITestConversationCell class]]; }).to.raise(NSInternalInconsistencyException);
}

//Verify that attempting to change the cell class after the table is loaded results in a runtime error.
- (void)testToVerifyChangingCellHeighAfterViewLoadRaiseException
{
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:0]];
    LSUIConversationListViewController *controller = [self conversationListViewController];
    expect(^{ [controller setRowHeight:40]; }).to.raise(NSInternalInconsistencyException);
}

//Verify that attempting to change the cell class after the table is loaded results in a runtime error.
- (void)testToVerifyChangingEditingSettingAfterViewLoadRaiseException
{
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:0]];
    LSUIConversationListViewController *controller = [self conversationListViewController];
    expect(^{ [controller setAllowsEditing:YES]; }).to.raise(NSInternalInconsistencyException);
}

//Synchronize a new conversation and verify that it live updates into the conversation list.
- (void)testToVerifyCreatingANewConversationLiveUpdatesConversationList
{
    LSUser *user1 = [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:0]];

    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:user1.userID] number:1];
    NSString *conversationLabel = [self conversationLabelForParticipants:[NSSet setWithObject:user1.userID]];
    [tester waitForViewWithAccessibilityLabel:conversationLabel];
}

#pragma mark - Factory Methods

//- (void)registerTestUsers
//{
//    [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:0]];
//    [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
//    [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:2]];
//}

- (void)deleteConversationWithUserIDs:(NSSet *)userIDs deletionMode:(LYRDeletionMode)deletionMode
{
    switch (deletionMode) {
        case LYRDeletionModeAllParticipants:
            [tester waitForViewWithAccessibilityLabel:@"Global"];
            [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Global"]];
            [tester waitForAbsenceOfViewWithAccessibilityLabel:[self conversationLabelForParticipants:userIDs]];
            break;
        case LYRDeletionModeLocal:
            [tester waitForViewWithAccessibilityLabel:@"Local"];
            [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Local"]];
            [tester waitForAbsenceOfViewWithAccessibilityLabel:[self conversationLabelForParticipants:userIDs]];
            break;
        default:
            break;
    }
}

- (NSString *)conversationLabelForParticipants:(NSSet *)participantIDs
{
    NSMutableSet *participantIdentifiers = [NSMutableSet setWithSet:participantIDs];
    
    if ([participantIdentifiers containsObject:self.testInterface.applicationController.layerClient.authenticatedUserID]) {
        [participantIdentifiers removeObject:self.testInterface.applicationController.layerClient.authenticatedUserID];
    }
    
    if (!participantIdentifiers.count > 0) return @"Personal Conversation";
    
    NSSet *participants = [self.testInterface.applicationController.persistenceManager participantsForIdentifiers:participantIdentifiers];
    
    if (!participants.count > 0) return @"No Matching Participants";
    
    LSUser *firstUser = [[participants allObjects] objectAtIndex:0];
    NSString *conversationLabel = firstUser.fullName;
    for (int i = 1; i < [[participants allObjects] count]; i++) {
        LSUser *user = [[participants allObjects] objectAtIndex:i];
        conversationLabel = [NSString stringWithFormat:@"%@, %@", conversationLabel, user.fullName];
    }
    return conversationLabel;
}

- (LSUIConversationListViewController *)conversationListViewController
{
    UINavigationController *navigationController = (UINavigationController *)[[[UIApplication sharedApplication] delegate] window].rootViewController.presentedViewController;
    LSUIConversationListViewController *controller = (LSUIConversationListViewController *)navigationController.topViewController;
    return controller;
}




@end
