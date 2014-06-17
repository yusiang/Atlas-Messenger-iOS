//
//  LSLoginTests.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/11/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSLoginTests.h"
#import "KIFUITestActor+LSAdditions.h"
#import "LSRegistrationTableViewController.h"
#import "LSLoginTableViewController.h"
#import "LSConversationListViewController.h"
#import "LSConversationViewController.h"
#import "LSHomeViewController.h"
#import "LSUserManager.h"

NSString *const LSTestUser0FullName = @"Layer Tester0";
NSString *const LSTestUser0Email = @"tester0@layer.com";
NSString *const LSTestUser0Password = @"password0";
NSString *const LSTestUser0Confirmation = @"password0";

NSString *const LSTestUser1FullName = @"Layer Tester1";
NSString *const LSTestUser1Email = @"tester1@layer.com";
NSString *const LSTestUser1Password = @"password1";
NSString *const LSTestUser1Confirmation = @"password1";

NSString *const LSTestUser2FullName = @"Layer Tester2";
NSString *const LSTestUser2Email = @"tester2@layer.com";
NSString *const LSTestUser2Password = @"password2";
NSString *const LSTestUser2Confirmation = @"password2";

NSString *const LSTestUser3FullName = @"Layer Tester3";
NSString *const LSTestUser3Email = @"tester3@layer.com";
NSString *const LSTestUser3Password = @"password3";
NSString *const LSTestUser3Confirmation = @"password3";



@implementation LSLoginTests

- (void)beforeEach
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [defaults removePersistentDomainForName:appDomain];
    [defaults synchronize];
    
    [LSUserManager registerWithFullName:LSTestUser0FullName email:LSTestUser0Email password:LSTestUser0Password andConfirmation:LSTestUser0Confirmation];
}

- (void)afterEach
{
    //[tester returnToLoggedOutHomeScreen];
}

////1. Log in with incorrect credentials and verify that an error prompt pops up.
//- (void)testToVerifyIncorrectLoginCredentialsAlert
//{
//    [tester tapViewWithAccessibilityLabel:@"Login Button"];
//    [tester enterText:@"fakeEmail@layer.com" intoViewWithAccessibilityLabel:@"Username"];
//    [tester enterText:@"fakePassword" intoViewWithAccessibilityLabel:@"Password"];
//    [tester tapViewWithAccessibilityLabel:@"Login Button"];
//    [tester waitForViewWithAccessibilityLabel:@"Invalid Credentials"];
//    [tester tapViewWithAccessibilityLabel:@"OK"];
//    [tester tapViewWithAccessibilityLabel:@"Home"];
//}
//
////2. Tap register, enter valid info, and verify success.
//- (void)testToVerifyRegistrationFunctionality
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//}
//
////3. Successfully log in with good credentials.
//- (void)testToVerifySuccesfulLogin
//{
//    [self loginAsTestUser:0];
//    [self logoutFromConversationListViewController];
//}
//
////4. Tap register, enter nothing, and verify that a prompt came up requesting valid info. Add a first name. Tap register and verify that a prompt requested more info. Continue adding data until success.
//- (void)testToVerifyIncompleteInfoRegistrationFunctionality
//{
//    [tester tapViewWithAccessibilityLabel:@"Register Button"];
//    [tester enterText:LSTestUser1FullName intoViewWithAccessibilityLabel:@"Fullname"];
//    [tester tapViewWithAccessibilityLabel:@"Register Button"];
//    [tester waitForViewWithAccessibilityLabel:@"No Email"];
//    [tester tapViewWithAccessibilityLabel:@"OK"];
//    [tester enterText:LSTestUser1Email intoViewWithAccessibilityLabel:@"Username"];
//    [tester tapViewWithAccessibilityLabel:@"Register Button"];
//    [tester waitForViewWithAccessibilityLabel:@"Password Error"];
//    [tester tapViewWithAccessibilityLabel:@"OK"];
//    [tester enterText:LSTestUser1Password intoViewWithAccessibilityLabel:@"Password"];
//    [tester tapViewWithAccessibilityLabel:@"Register Button"];
//    [tester waitForViewWithAccessibilityLabel:@"Password Error"];
//    [tester tapViewWithAccessibilityLabel:@"OK"];
//    [tester enterText:LSTestUser1Confirmation intoViewWithAccessibilityLabel:@"Confirm"];
//    [tester tapViewWithAccessibilityLabel:@"Register Button"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [self logoutFromConversationListViewController];
////}
//
////5. Log in. Verify the address book is empty. Log out and register as a new user. Verify that the first user is in the address book.
//- (void)testToVerifyAddressBookFunctionalityForFirstTwoUsers
//{
//    [self loginAsTestUser:0];
//    [tester tapViewWithAccessibilityLabel:@"new"];
//    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"contactCell"];
//    [self logoutFromContactViewController];
//    [self registerTestUser:1];
//    [tester tapViewWithAccessibilityLabel:@"new"];
//    [tester waitForViewWithAccessibilityLabel:[self contactCellLabelForUser:0]];
//    [self logoutFromContactViewController];
//}
//
////6. Register two users. Log in. Tap the contact and verify that its checkbox checks. Tap it again and verify that the checkbox unchecks.
//-(void)testToVerifyAddressBookSelectionIndicatorFunctionality
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//    [self registerTestUser:2];
//    [self logoutFromConversationListViewController];
//    
//    [self loginAsTestUser:1];
//    [tester tapViewWithAccessibilityLabel:@"new"];
//    [tester waitForViewWithAccessibilityLabel:[self contactCellLabelForUser:2]];
//    [tester tapViewWithAccessibilityLabel:[self contactCellLabelForUser:2]];
//    
//    [tester waitForViewWithAccessibilityLabel:@"selectionIndicator"];
//    [tester tapViewWithAccessibilityLabel:[self contactCellLabelForUser:2]];
//    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"selectionIndicator"];
//    [self logoutFromContactViewController];
//}
//
////7. Register two users. Log in. Tap the contact to check its checkbox. Tap the "+" to start a conversation and verify that the proper Conversation view is shown.
//-(void)testToVerifyStartingAConversationWithTwoContacts
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//  
//    [self registerTestUser:2];
//    [self logoutFromConversationListViewController];
//    
//    [self loginAsTestUser:1];
//
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:2]]];
//
//    [self logoutFromConversationViewController];
//}
//
////8. Register two users. Log in and start a conversation. Tap the back button and verify that the ConversationList Returns
//- (void)testToVerifyNavigationBetweenContactsandConversations
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//    
//    [self registerTestUser:2];
//    [self logoutFromConversationListViewController];
//    
//    [self loginAsTestUser:1];
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:2]]];
//    
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    
//    [self logoutFromConversationListViewController];
//}
//
////9. Register two users. Log in as one and start a conversation. Verify that the focus is automatically set on the message entry box. Type "hello!" and verify that "hello!" appears in the entry box. Tap "send" and verify that a message with "hello!" is added to the conversation history. Send "Do you hear me?" and verify that the new message is added below the first.
//-(void)testToVerifyUIAnimimationsForSendingAMessage
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//    
//    [self registerTestUser:2];
//    [self logoutFromConversationListViewController];
//    
//    [self loginAsTestUser:1];
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:2]]];
//    
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    
//    [self logoutFromConversationViewController];
//}
//
//10. Register two users. Log in and start a conversation. Log out and back in. Verify that the old conversation is still there.
-(void)testToVerifyConversationPersistenceFunctionality
{
    [self registerTestUser:1];
    [self logoutFromConversationListViewController];

    [self registerTestUser:2];
    [self logoutFromConversationListViewController];
    
    [self loginAsTestUser:1];
    [self startConversationWithUserId:@[[NSNumber numberWithInt:2]]];
    [tester tapViewWithAccessibilityLabel:@"conversationList"];

    [self logoutFromConversationListViewController];
    
    [self loginAsTestUser:1];
    
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 2]]]];
    [self logoutFromConversationListViewController];
}
//
////Send three messages to a user. Log out. Log back in with the same account. Verify that the old messages are still there in proper order.
//- (void)testToVerifySentMessagePersistence
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//    
//    [self registerTestUser:2];
//    [self logoutFromConversationListViewController];
//    
//    [self loginAsTestUser:1];
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:2]]];
//
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    [self sendMessageWithText:@"This is another test message"];
//
//    [tester waitForTimeInterval:5];
//    
//    [self logoutFromConversationViewController];
//    
//    [self loginAsTestUser:1];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 2]]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 2]]]];
//    
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:1]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test message" andUser:1]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is another test message" andUser:1]];
//
//    [self logoutFromConversationViewController];
//}
//
////Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Verify that all three conversations show up on the Conversations list with proper names displayed.
//- (void)testToVerifyThreeNewConversationsAreDisplayedInconversationList
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//
//    [self registerTestUser:2];
//    [self logoutFromConversationListViewController];
//
//    [self registerTestUser:3];
//    [self logoutFromConversationListViewController];
//
//    [self loginAsTestUser:1];
//
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:2]]];
//    [tester tapViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 2]]]];
//    
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:3]]];
//    [tester tapViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 3]]]];
//    
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:2], [NSNumber numberWithInt:3]]];
//    [tester tapViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 2], [NSString stringWithFormat:@"%d", 3]]]];
//    [self logoutFromConversationListViewController];
//}
//
////Send three messages to a user. Log out. Log back in as the recipient user. Verify that the messages are there, marked as sent by the sender, in proper order.
//- (void)testToVerifySuccesfullRecipetOfThreeMessages
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//
//    [self registerTestUser:2];
//    [self logoutFromConversationListViewController];
//
//    [self loginAsTestUser:1];
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:2]]];
//
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    [self sendMessageWithText:@"This is another test message"];
//    
//    [tester waitForTimeInterval:5];
//    
//    [self logoutFromConversationViewController];
//
//    [self loginAsTestUser:2];
//
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 1]]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 1]]]];
//
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:1]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test message" andUser:1]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is another test message" andUser:1]];
//    [self logoutFromConversationViewController];
//}
//
////Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Open one of the individual conversations and send three messages. Open the group chat and send one message. Log out and back in as the recipient of the three messages. Verify that two conversations are listed – one with three messages and another group chat with one message, all with the proper participants.
//- (void)testToVerifyMultipleMessagesSentToMultipleRecipeientsAreReciecvedAndDisplayedForTheRecipients
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//    
//    [self registerTestUser:2];
//    [self logoutFromConversationListViewController];
//    
//    [self registerTestUser:3];
//    [self logoutFromConversationListViewController];
//    
//    [self loginAsTestUser:1];
//    
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:2]]];
//    [tester tapViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 2]]]];
//    
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:3]]];
//    [tester tapViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 3]]]];
//    
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:2], [NSNumber numberWithInt:3]]];
//    [tester tapViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 2], [NSString stringWithFormat:@"%d", 3]]]];
//    
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 2]]]];
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    [self sendMessageWithText:@"This is another test message"];
//    
//    [tester tapViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//    
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 2], [NSString stringWithFormat:@"%d", 3]]]];
//    [self sendMessageWithText:@"Hello"];
//    
//    [tester waitForTimeInterval:5];
//    
//    [self logoutFromConversationViewController];
//    
//    [self loginAsTestUser:2];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 1]]]];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 1], [NSString stringWithFormat:@"%d", 3]]]];
//    [self logoutFromConversationListViewController];
//}
//
////Create three users. Log in as one of them. Send a message to one contact. Log out and in as that contact. Reply to the original message. Log out and in as the first user, and verify that the reply shows up below the originally sent message.
//- (void)testToVerifySendingRecievingAndReplyingToAMessage
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//    
//    [self registerTestUser:2];
//    [self logoutFromConversationListViewController];
//    
//    [self registerTestUser:3];
//    [self logoutFromConversationListViewController];
//    
//    [self loginAsTestUser:1];
//    
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:2]]];
//    [self sendMessageWithText:@"Hello"];
//    
//    [tester waitForTimeInterval:5];
//    [self logoutFromConversationViewController];
//    
//    [self loginAsTestUser:2];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 1]]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 1]]]];
//    [self sendMessageWithText:@"This is a test reply message"];
//    
//    [tester waitForTimeInterval:5];
//    [self logoutFromConversationViewController];
//    
//    [self loginAsTestUser:1];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 2]]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 2]]]];
//    
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:1]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test reply message" andUser:2]];
//    [self logoutFromConversationViewController];
//}
//
////Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Open one of the individual conversations and send three messages. Tap back and verify that the latest message is displayed in the proper conversation's list item.
//- (void)testToVerifyTheLatestMessageInANewConversationIsDisplayedInConversationList
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//    
//    [self registerTestUser:2];
//    [self logoutFromConversationListViewController];
//    
//    [self registerTestUser:3];
//    [self logoutFromConversationListViewController];
//    
//    [self loginAsTestUser:1];
//    
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:2]]];
//    [tester tapViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 2]]]];
//    
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:3]]];
//    [tester tapViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 3]]]];
//    
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:2], [NSNumber numberWithInt:3]]];
//    [tester tapViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 2], [NSString stringWithFormat:@"%d", 3]]]];
//    
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 3]]]];
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    [self sendMessageWithText:@"This is another test message"];
//    
//    [tester tapViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//    [self logoutFromConversationListViewController];
//    //[tester waitForViewWithAccessibilityLabel:@"This is another test message"];
//}
//
////Push an image to a know location on the device. Create two users. Log in as one, create a conversation with the other. Tap the camera button. Verify that a photo prompt pops up with options for taking a picture or attaching an image from the filesystem. Select the filesystem option. Select the pushed photo. Verify that a photo is added to the conversation view.
//- (void)testToVerifySelectingAnImageFromTheCameraRollAndSending
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//    
//    [self registerTestUser:2];
//    [self logoutFromConversationListViewController];
//    
//    [self loginAsTestUser:1];
//    
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:2]]];
//    
//    [self selectPhotoFromCameraRoll];
//
//    [self logoutFromContactViewController];
//}
//
////Push an image to a know location on the device. Create two users. Log in as one and send a photo to the other. Log in as the recipient and verify that the photo was received.
//- (void)testToVerifyASentPhotoIsRecievedByTheRecipient
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//    
//    [self registerTestUser:2];
//    [self logoutFromConversationListViewController];
//    
//    [self loginAsTestUser:1];
//    
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:2]]];
//    
//    [self selectPhotoFromCameraRoll];
//    [self sendPhoto];
//    
//    [self logoutFromConversationViewController];
//    
//    [self loginAsTestUser:2];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 1]]]];
//    
//    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForUserID:1]];
//}
//
////Push three images to known locations. Create three users. Log in as one and create a group chat with the other two. Send two text messages and one of the photos. Log in as the second user. Send another photo and two additional text messages. Log in as the third user. Verify that the prior messages are all there in the proper order from the proper senders.
//- (void)testToVerifyThatPhotosAndMessagesAreAccuratelySentAndRecievedByMultipleParticipantsInAGroupChat
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//    
//    [self registerTestUser:2];
//    [self logoutFromConversationListViewController];
//    
//    [self registerTestUser:3];
//    [self logoutFromConversationListViewController];
//    
//    [self loginAsTestUser:1];
//    
//    [self startConversationWithUserId:@[[NSNumber numberWithInt:2], [NSNumber numberWithInt:3]]];
//    [tester tapViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 2], [NSString stringWithFormat:@"%d", 3]]]];
//    
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[NSString stringWithFormat:@"%d", 2], [NSString stringWithFormat:@"%d", 3]]]];
//    
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    
//    [self selectPhotoFromCameraRoll];
//    [self sendPhoto];
//    
//    [tester waitForTimeInterval:5];
//    
//    [self logoutFromConversationViewController];
//    [self loginAsTestUser:2];
//    
//    [self selectPhotoFromCameraRoll];
//    [self sendPhoto];
//    
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    
//    [tester waitForTimeInterval:5];
//    
//    [self logoutFromConversationViewController];
//    [self loginAsTestUser:3];
//    
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:1]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test message" andUser:1]];
//    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForUserID:1]];
//    
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:2]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test message" andUser:2]];
//    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForUserID:2]];
//}

//======== Factory Methods =========//

#pragma mark
#pragma mark Test User Registration and Login Methods
- (void)registerTestUser:(NSUInteger)userID
{
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Conversations"];
    switch (userID) {
        case 0:
            [tester tapViewWithAccessibilityLabel:@"Register Button"];
            [tester enterText:LSTestUser0FullName intoViewWithAccessibilityLabel:@"Fullname"];
            [tester enterText:LSTestUser0Email intoViewWithAccessibilityLabel:@"Username"];
            [tester enterText:LSTestUser0Password intoViewWithAccessibilityLabel:@"Password"];
            [tester enterText:LSTestUser0Confirmation intoViewWithAccessibilityLabel:@"Confirm"];
            [tester tapViewWithAccessibilityLabel:@"Register Button"];
            [tester waitForViewWithAccessibilityLabel:@"Conversations"];
            break;
        case 1:
            [tester tapViewWithAccessibilityLabel:@"Register Button"];
            [tester enterText:LSTestUser1FullName intoViewWithAccessibilityLabel:@"Fullname"];
            [tester enterText:LSTestUser1Email intoViewWithAccessibilityLabel:@"Username"];
            [tester enterText:LSTestUser1Password intoViewWithAccessibilityLabel:@"Password"];
            [tester enterText:LSTestUser1Confirmation intoViewWithAccessibilityLabel:@"Confirm"];
            [tester tapViewWithAccessibilityLabel:@"Register Button"];
            [tester waitForViewWithAccessibilityLabel:@"Conversations"];
            break;
        case 2:
            [tester tapViewWithAccessibilityLabel:@"Register Button"];
            [tester enterText:LSTestUser2FullName intoViewWithAccessibilityLabel:@"Fullname"];
            [tester enterText:LSTestUser2Email intoViewWithAccessibilityLabel:@"Username"];
            [tester enterText:LSTestUser2Password intoViewWithAccessibilityLabel:@"Password"];
            [tester enterText:LSTestUser2Confirmation intoViewWithAccessibilityLabel:@"Confirm"];
            [tester tapViewWithAccessibilityLabel:@"Register Button"];
            [tester waitForViewWithAccessibilityLabel:@"Conversations"];
            break;
        case 3:
            [tester tapViewWithAccessibilityLabel:@"Register Button"];
            [tester enterText:LSTestUser3FullName intoViewWithAccessibilityLabel:@"Fullname"];
            [tester enterText:LSTestUser3Email intoViewWithAccessibilityLabel:@"Username"];
            [tester enterText:LSTestUser3Password intoViewWithAccessibilityLabel:@"Password"];
            [tester enterText:LSTestUser3Confirmation intoViewWithAccessibilityLabel:@"Confirm"];
            [tester tapViewWithAccessibilityLabel:@"Register Button"];
            [tester waitForViewWithAccessibilityLabel:@"Conversations"];
            break;
        default:
            break;
    }
}

- (void)loginAsTestUser:(NSInteger)userID
{
    [tester tapViewWithAccessibilityLabel:@"Login Button"];
    switch (userID) {
        case 0:
            [tester enterText:LSTestUser0Email intoViewWithAccessibilityLabel:@"Username"];
            [tester enterText:LSTestUser0Password intoViewWithAccessibilityLabel:@"Password"];
            break;
        case 1:
            [tester enterText:LSTestUser1Email intoViewWithAccessibilityLabel:@"Username"];
            [tester enterText:LSTestUser1Password intoViewWithAccessibilityLabel:@"Password"];
            break;
        case 2:
            [tester enterText:LSTestUser2Email intoViewWithAccessibilityLabel:@"Username"];
            [tester enterText:LSTestUser2Password intoViewWithAccessibilityLabel:@"Password"];
            break;
        case 3:
            [tester enterText:LSTestUser3Email intoViewWithAccessibilityLabel:@"Username"];
            [tester enterText:LSTestUser3Password intoViewWithAccessibilityLabel:@"Password"];
            break;
        default:
            break;
    }
    [tester tapViewWithAccessibilityLabel:@"Login Button"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
}

- (void)logout
{
    [tester tapViewWithAccessibilityLabel:@"logout"];
}

#pragma mark
#pragma mark Start Conversation

- (void)startConversationWithUserId:(NSArray *)userIDs
{
    [tester tapViewWithAccessibilityLabel:@"new"];
    [tester waitForViewWithAccessibilityLabel:@"Contacts"];
    for (NSNumber *userID in userIDs) {
        [tester waitForViewWithAccessibilityLabel:[self contactCellLabelForUser:[userID integerValue]]];
        [tester tapViewWithAccessibilityLabel:[self contactCellLabelForUser:[userID integerValue]]];
    }
    [tester tapViewWithAccessibilityLabel:@"start"];
    [tester waitForViewWithAccessibilityLabel:@"composeView"];
}

- (NSString *)conversationCellLabelForParticipants:(NSArray *)participants
{
    NSString *senderLabel = @"";
    for (NSString *userID in participants) {
        if (![userID isEqualToString:[LSUserManager loggedInUserID]]) {
            NSString *participant = (NSString *)[[LSUserManager userInfoForUserID:userID] objectForKey:@"fullName"];
            senderLabel = [senderLabel stringByAppendingString:[NSString stringWithFormat:@"%@, ", participant]];
        }
    }
    return senderLabel;
}

- (NSString *)contactCellLabelForUser:(NSUInteger)userID
{
    switch (userID) {
        case 0:
            return [NSString stringWithFormat:@"%@", LSTestUser0FullName];
            break;
        case 1:
            return [NSString stringWithFormat:@"%@", LSTestUser1FullName];
            break;
        case 2:
            return [NSString stringWithFormat:@"%@", LSTestUser2FullName];
            break;
        case 3:
            return [NSString stringWithFormat:@"%@", LSTestUser3FullName];
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark
#pragma mark Send Message

- (void)sendMessageWithText:(NSString *)text
{
    [tester tapViewWithAccessibilityLabel:@"Compose TextView"];
    [tester waitForViewWithAccessibilityLabel:@"space"]; //Space represents that the keyboard is show, hence the focus is on the text entry box
    [tester clearTextFromAndThenEnterText:text intoViewWithAccessibilityLabel:@"Compose TextView"];
    [tester tapViewWithAccessibilityLabel:@"Send Button"];
    
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:text andUser:[[LSUserManager loggedInUserID] intValue]]];
}

- (NSString *)messageCellLabelForText:(NSString *)text andUser:(NSInteger)userID
{
    switch (userID) {
        case 0:
            return [NSString stringWithFormat:@"%@ sent by %@", text, LSTestUser0FullName];
            break;
        case 1:
            return [NSString stringWithFormat:@"%@ sent by %@", text, LSTestUser1FullName];
            break;
        case 2:
            return [NSString stringWithFormat:@"%@ sent by %@", text, LSTestUser2FullName];
            break;
        case 3:
            return [NSString stringWithFormat:@"%@ sent by %@", text, LSTestUser2FullName];
            break;
        default:
            break;
    }
    return nil;
}

- (void)selectPhotoFromCameraRoll
{
    [tester tapViewWithAccessibilityLabel:@"Cam Button"];
    [tester tapViewWithAccessibilityLabel:@"Choose Existing"];
    [tester tapViewWithAccessibilityLabel:@"Saved Photos"];
    [tester tapViewWithAccessibilityLabel:@"Photo, Landscape, 8:14 AM"];
    [tester waitForViewWithAccessibilityLabel:@"composeView"];
    [tester waitForViewWithAccessibilityLabel:@"selectedImage"];
}

-(void)sendPhoto
{
    [tester tapViewWithAccessibilityLabel:@"Send Button"];
    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForUserID:[[LSUserManager loggedInUserID] intValue]]];
}

- (NSString *)imageCelLabelForUserID:(NSInteger)userId
{
    switch (userId) {
        case 0:
            return [NSString stringWithFormat:@"Photo sent by %@", LSTestUser0FullName];
            break;
        case 1:
            return [NSString stringWithFormat:@"Photo sent by %@", LSTestUser1FullName];
            break;
        case 2:
            return [NSString stringWithFormat:@"Photo sent by %@", LSTestUser2FullName];
            break;
        case 3:
            return [NSString stringWithFormat:@"Photo sent by %@", LSTestUser3FullName];
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark
#pragma mark Logout Methods

- (void)logoutFromConversationListViewController
{
    [tester tapViewWithAccessibilityLabel:@"logout"];
    [tester waitForViewWithAccessibilityLabel:@"Home"];
}

- (void)logoutFromContactViewController
{
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester tapViewWithAccessibilityLabel:@"logout"];
    [tester waitForViewWithAccessibilityLabel:@"Home"];
}

- (void)logoutFromConversationViewController
{
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester tapViewWithAccessibilityLabel:@"logout"];
    [tester waitForViewWithAccessibilityLabel:@"Home"];
}

@end
