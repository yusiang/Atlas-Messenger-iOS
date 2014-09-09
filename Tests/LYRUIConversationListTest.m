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
#import "LSUIConversationListViewController.h"
#import "LYRUIConversationTableViewCell.h"
#import "LYRUITestConversationCell.h"
#include <stdlib.h>

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
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:3]];
    
    LSUser *testUser = [self.testInterface randomUser];
    
    NSSet *participantIdentifiers = [NSSet setWithObjects:testUser.userID, nil];
    [self.layerContentFactory conversationsWithParticipants:participantIdentifiers number:4];
    
    NSSet *conversations = [self.testInterface.applicationController.layerClient conversationsForIdentifiers:nil];
    for (LYRConversation *conversation in conversations) {
        [tester waitForViewWithAccessibilityLabel:[self conversationLabelForParticipants:conversation.participants]];
    }
}

//Search for text that exists in a known message and verify that it appears.
- (void)testToVerfiyMessageSearchFunctionalityForKnownMessageText
{
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:3]];
    
    LSUser *testUser = [self.testInterface randomUser];
    
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:testUser.userID] number:1];
    
    [self conversationLabelForParticipants:[NSSet setWithObject:testUser.userID]];
  
    [tester swipeViewWithAccessibilityLabel:@"Conversation List" inDirection:KIFSwipeDirectionDown];
    [tester tapViewWithAccessibilityLabel:@"Search Bar"];
    [tester enterText:testUser.fullName intoViewWithAccessibilityLabel:@"Search Bar"];
    [tester waitForViewWithAccessibilityLabel:testUser.fullName];
}

////Search for text that does not appear in any message and verify the list is empty.
//- (void)testToVerifyMessageSearchFunctionalityForUnknownMessageText
//{
//    [self registerAndAuthenticateUser];
//    
//    LSUser *testUser = [self randomUser];
//    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:testUser.userID] number:1];
//    
//    [tester swipeViewWithAccessibilityLabel:@"Conversation List" inDirection:KIFSwipeDirectionDown];
//    
//    NSString *searchText = @"This is fake text";
//    [tester tapViewWithAccessibilityLabel:@"Search Bar"];
//    [tester enterText:searchText intoViewWithAccessibilityLabel:@"Search Bar"];
//    //[tester waitForAbsenceOfViewWithAccessibilityLabel:[self conversationLabelForParticipants:[NSSet setWithObject:testUser.userID]]];
//}
//
////Test swipe to delete for deleting a conversation. Verify the conversation is deleted from the table and from the Layer client.
//- (void)testToVerifyDeletionOfConversationFunctionality
//{
//    [self registerAndAuthenticateUser];
//    
//    LSUser *testUser = [self randomUser];
//    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:testUser.userID] number:1];
//    
//    NSString *conversationLabel = [self conversationLabelForParticipants:[NSSet setWithObject:testUser.userID]];
//    [tester swipeViewWithAccessibilityLabel:conversationLabel inDirection:KIFSwipeDirectionLeft];
//    [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Delete %@ ", testUser.fullName]];
//    [tester waitForAbsenceOfViewWithAccessibilityLabel:conversationLabel];
//}
//
////Test engaging editing mode and deleting several conversations at once. Verify that all conversations selected are deleted from the table and from the Layer client.
//- (void)testToVerifyEditingModeAndMultipleConversationDeletionFunctionality
//{
//    [self registerAndAuthenticateUser];
//    
//    LSUser *testUser1 = [self randomUser];
//    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:testUser1.userID] number:1];
//    
//    LSUser *testUser2 = [self randomUser];
//    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:testUser2.userID] number:1];
//    
//    LSUser *testUser3 = [self randomUser];
//    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:testUser3.userID] number:1];
//    
//    [tester waitForTimeInterval:5];
//    [tester tapViewWithAccessibilityLabel:@"Edit"];
//    [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Delete %@", testUser1.fullName]];
//}

//Disable editing and verify that the controller does not permit the user to attempt to edit or engage swipe to delete.
- (void)testToVerifyDisablingEditModeDoesNotAllowUserToDeleteConversations
{
    LSAppDelegate *appDelegate = (LSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewController setAllowsEditing:FALSE];
    
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:3]];
    
    LSUser *testUser = [self.testInterface randomUser];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:testUser.userID] number:1];
    
    NSString *conversationLabel = [self conversationLabelForParticipants:[NSSet setWithObject:testUser.userID]];
    
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Edit"];
    
    [tester swipeViewWithAccessibilityLabel:conversationLabel inDirection:KIFSwipeDirectionLeft];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:[NSString stringWithFormat:@"Delete, %@", conversationLabel]];
}

//Customize the fonts and colors using UIAppearance and verify that the configuration is respected.
- (void)testToVerifyColorAndFontChangeFunctionality
{
    UIFont *testFont = [UIFont systemFontOfSize:20];
    UIColor *testColor = [UIColor redColor];
    
    [[LYRUIConversationTableViewCell appearance] setConversationLabelFont:testFont];
    [[LYRUIConversationTableViewCell appearance] setConversationLableColor:testColor];
    
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:3]];
    
    LSUser *testUser = [self.testInterface randomUser];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:testUser.userID] number:1];
    
    NSString *conversationLabel = [self conversationLabelForParticipants:[NSSet setWithObject:testUser.userID]];
    
    LYRUIConversationTableViewCell *cell = (LYRUIConversationTableViewCell *)[tester waitForViewWithAccessibilityLabel:conversationLabel];
    expect(cell.conversationLabelFont).to.equal(testFont);
    expect(cell.conversationLableColor).to.equal(testColor);
}

//Customize the row height and ensure that it is respected.
- (void)testToVerifyCustomRowHeightFunctionality
{
    CGFloat testHeight = 100;
    
    LSAppDelegate *appDelegate = (LSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewController setRowHeight:testHeight];
    
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:3]];
    
    LSUser *testUser = [self.testInterface randomUser];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:testUser.userID] number:1];
    
    NSString *conversationLabel = [self conversationLabelForParticipants:[NSSet setWithObject:testUser.userID]];
    
    LYRUIConversationTableViewCell *cell = (LYRUIConversationTableViewCell *)[tester waitForViewWithAccessibilityLabel:conversationLabel];
    
    expect(cell.frame.size.height).to.equal(testHeight);
}

//Customize the cell class and ensure that the correct cell is used to render the table.
-(void)testToVerifyCustomCellClassFunctionality
{
    LSAppDelegate *appDelegate = (LSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewController setCellClass:[LYRUITestConversationCell class]];
    
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:3]];
    
    LSUser *testUser = [self.testInterface randomUser];
    [self.layerContentFactory conversationsWithParticipants:[NSSet setWithObject:testUser.userID] number:1];
    
    NSString *conversationLabel = [self conversationLabelForParticipants:[NSSet setWithObject:testUser.userID]];
    
    id cell = [tester waitForViewWithAccessibilityLabel:conversationLabel];
    
    expect([cell class]).to.equal([LYRUITestConversationCell class]);
    expect([cell class]).toNot.equal([LYRUIConversationTableViewCell class]);
}

//Verify that attempting to provide a cell class that does not conform to LYRUIConversationPresenting results in a runtime exception.
- (void)testToVerifyCustomCellClassNotConformingToProtocolRaisesException
{
    LSAppDelegate *appDelegate = (LSAppDelegate *)[[UIApplication sharedApplication] delegate];
    expect(^{ [appDelegate.viewController setCellClass:[UITableViewCell class]]; }).to.raise(NSInternalInconsistencyException);
}

//Verify that attempting to change the cell class after the table is loaded results in a runtime error.
- (void)testToVerifyChangingCellClassAfterViewLoadRaiseException
{
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:3]];
    UINavigationController *navigationController = (UINavigationController *)[[[UIApplication sharedApplication] delegate] window].rootViewController.presentedViewController;
    LSUIConversationListViewController *controller = (LSUIConversationListViewController *)navigationController.topViewController;
    expect(^{ [controller setCellClass:[LYRUITestConversationCell class]]; }).to.raise(NSInternalInconsistencyException);
}

//Verify that attempting to change the cell class after the table is loaded results in a runtime error.
- (void)testToVerifyChangingCellHeighAfterViewLoadRaiseException
{
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:3]];
    UINavigationController *navigationController = (UINavigationController *)[[[UIApplication sharedApplication] delegate] window].rootViewController.presentedViewController;
    LSUIConversationListViewController *controller = (LSUIConversationListViewController *)navigationController.topViewController;
    expect(^{ [controller setRowHeight:40]; }).to.raise(NSInternalInconsistencyException);
}

//Verify that attempting to change the cell class after the table is loaded results in a runtime error.
- (void)testToVerifyChangingEditingSettingAfterViewLoadRaiseException
{
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:3]];
    UINavigationController *navigationController = (UINavigationController *)[[[UIApplication sharedApplication] delegate] window].rootViewController.presentedViewController;
    LSUIConversationListViewController *controller = (LSUIConversationListViewController *)navigationController.topViewController;
    expect(^{ [controller setAllowsEditing:TRUE]; }).to.raise(NSInternalInconsistencyException);
}

//Synchronize a new conversation and verify that it live updates into the conversation list.
- (void)testToVerifyCreatingANewConversationLiveUpdatesConversationList
{
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:3]];
    
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

#pragma mark - Factory Methods

- (void)registerTestUsers
{
    [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:0]];
    [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:2]];
}

- (NSString *)conversationLabelForParticipants:(NSSet *)participantIDs
{
    NSMutableSet *participantIdentifiers = [NSMutableSet setWithSet:participantIDs];
    
    if ([participantIdentifiers containsObject:self.testInterface.applicationController.layerClient.authenticatedUserID]) {
        [participantIdentifiers removeObject:self.testInterface.applicationController.layerClient.authenticatedUserID];
    }
    
    if (!participantIdentifiers.count > 0) return @"";
    
    NSSet *participants = [self.testInterface.applicationController.persistenceManager participantsForIdentifiers:participantIdentifiers];
    
    if (!participants.count > 0) return @"";
    
    LSUser *firstUser = [[participants allObjects] objectAtIndex:0];
    NSString *conversationLabel = firstUser.fullName;
    for (int i = 1; i < [[participants allObjects] count]; i++) {
        LSUser *user = [[participants allObjects] objectAtIndex:i];
        conversationLabel = [NSString stringWithFormat:@"%@, %@", conversationLabel, user.fullName];
    }
    return conversationLabel;
}


@end
