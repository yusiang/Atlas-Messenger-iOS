//
//  LSLoginTests.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/11/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "KIFTestCase.h"
#import <KIF/KIF.h>
#import "KIFSystemTestActor+ViewControllerActions.h"
#import "KIFUITestActor+LSAdditions.h"
#import "LSRegistrationViewController.h"
#import "LSLoginViewController.h"
#import "LSConversationListViewController.h"
#import "LSConversationViewController.h"
#import "LSAuthenticationViewController.h"
#import "LSUser.h"
#import "LYRCountdownLatch.h"
#import "LSPersistenceManager.h"
#import "LSConversationCellPresenter.h"
#import "LSApplicationController.h"
#import "LSAuthenticationViewController.h"
#import "LSAppDelegate.h"
#import "LYRUITestUser.h"


@interface LSUITest : KIFTestCase

@property (nonatomic) LSApplicationController *controller;
@property (nonatomic) LSPersistenceManager *persistenceManager;
@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) LSAPIManager *APIManager;

@end

@implementation LSUITest

- (void)beforeEach
{
    self.controller =  [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    
    self.layerClient = self.controller.layerClient;
    self.persistenceManager = self.controller.persistenceManager;
    self.APIManager = self.controller.APIManager;
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:5.0];
    [self.APIManager deleteAllContactsWithCompletion:^(BOOL completion, NSError *error) {
        [latch decrementCount];
    }];
    [tester waitForTimeInterval:0];
    
    NSError *error;
    [self.persistenceManager deleteAllObjects:&error];
}

- (void)afterEach
{
    [self deauthenticate];
}

//1. Log in with incorrect credentials and verify that an error prompt pops up.
- (void)testToVerifyIncorrectLoginCredentialsAlert
{
    [tester tapViewWithAccessibilityLabel:@"Login Button"];
    [tester enterText:@"fakeEmail@layer.com" intoViewWithAccessibilityLabel:@"Email"];
    [tester enterText:@"fakePassword" intoViewWithAccessibilityLabel:@"Password"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester waitForViewWithAccessibilityLabel:@"Login Failed"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    [tester tapViewWithAccessibilityLabel:@"Home Screen"];
}

//2. Tap register, enter valid info, and verify success.
- (void)testToVerifyRegistrationFunctionality
{
    [self registerTestUser:[self testUserWithNumber:0]];
}

//3. Successfully log in with good credentials.
- (void)testToVerifySuccesfulLogin
{
    [self systemRegisterUser:[self testUserWithNumber:0]];
    [self deauthenticate];
    [self loginAsTestUser:[self testUserWithNumber:0]];
}

//4. Tap register, enter nothing, and verify that a prompt came up requesting valid info. Add a first name. Tap register and verify that a prompt requested more info. Continue adding data until success.
- (void)testToVerifyIncompleteInfoRegistrationFunctionality
{
    LSUser *testUser = [self testUserWithNumber:0];
    [tester tapViewWithAccessibilityLabel:@"Register Button"];
    
    [tester enterText:testUser.firstName intoViewWithAccessibilityLabel:@"First Name"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester waitForViewWithAccessibilityLabel:@"Registration Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    [tester enterText:testUser.lastName intoViewWithAccessibilityLabel:@"Last Name"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester waitForViewWithAccessibilityLabel:@"Registration Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    [tester enterText:testUser.email intoViewWithAccessibilityLabel:@"Email"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester waitForViewWithAccessibilityLabel:@"Registration Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:@"Password"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester waitForViewWithAccessibilityLabel:@"Registration Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    [tester enterText:testUser.passwordConfirmation intoViewWithAccessibilityLabel:@"Confirmation"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    
}

//5. Log in. Verify the address book is empty. Log out and register as a new user. Verify that the first user is in the address book.
- (void)testToVerifyAddressBookFunctionalityForFirstTwoUsers
{
    [self systemRegisterUser:[self testUserWithNumber:0]];
    [tester tapViewWithAccessibilityLabel:@"New"];
    [tester waitForViewWithAccessibilityLabel:@"Empty Contacts"];
    
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [tester tapViewWithAccessibilityLabel:@"New"];
    [tester waitForViewWithAccessibilityLabel:[self testUserWithNumber:0].fullName];
}

//6. Register two users. Log in. Tap the contact and verify that its checkbox checks. Tap it again and verify that the checkbox unchecks.
-(void)testToVerifyAddressBookSelectionIndicatorFunctionality
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
    
    [tester tapViewWithAccessibilityLabel:@"New"];
    [tester waitForViewWithAccessibilityLabel:[self testUserWithNumber:2].fullName];
    [tester tapViewWithAccessibilityLabel:[self testUserWithNumber:2].fullName];
    
    [tester waitForViewWithAccessibilityLabel:@"Selected Checkmark"];
    [tester tapViewWithAccessibilityLabel:[self testUserWithNumber:2].fullName];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Selected Checkmark"];
}

//7. Register two users. Log in. Tap the contact to check its checkbox. Tap the "+" to start a conversation and verify that the proper Conversation view is shown.
-(void)testToVerifyStartingAConversationWithTwoContacts
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];

    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];
}

//8. Register two users. Log in and start a conversation. Tap the back button and verify that the ConversationList Returns
- (void)testToVerifyNavigationBetweenContactsandConversations
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
    
    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];
    
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
}

//9. Register two users. Log in as one and start a conversation. Verify that the focus is automatically set on the message entry box. Type "hello!" and verify that "hello!" appears in the entry box. Tap "send" and verify that a message with "hello!" is added to the conversation history. Send "Do you hear me?" and verify that the new message is added below the first.
-(void)testToVerifyUIAnimimationsForSendingAMessage
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];

    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];
    
    [self sendMessageWithText:@"Hello"];
    [self sendMessageWithText:@"This is a test message"];
}
//
//10. Register two users. Log in and start a conversation. Log out and back in. Verify that the old conversation is still there.
-(void)testToVerifyConversationPersistenceFunctionality
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
    
    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];
    [self sendMessageWithText:@"Hello"];
    [tester waitForTimeInterval:1];
   
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
    
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email]]];
}

//11. Send three messages to a user. Log out. Log back in with the same account. Verify that the old messages are still there in proper order.
- (void)testToVerifySentMessagePersistence
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
    
    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];

    [self sendMessageWithText:@"Hello"];
    [self sendMessageWithText:@"This is a test message"];
    [self sendMessageWithText:@"This is another test message"];
    
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email]]];
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email]]];
    
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:[self testUserWithNumber:1].fullName]];
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test message" andUser:[self testUserWithNumber:1].fullName]];
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is another test message" andUser:[self testUserWithNumber:1].fullName]];
}

//12. Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Verify that all three conversations show up on the Conversations list with proper names displayed.
- (void)testToVerifyThreeNewConversationsAreDisplayedInconversationList
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:3]];
    [self deauthenticate];

    [self systemLoginUser:[self testUserWithNumber:1]];

    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email]]];
    
    [self startConversationWithUsers:@[[self testUserWithNumber:3]]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:3].email]]];
    
    [self startConversationWithUsers:@[[self testUserWithNumber:2], [self testUserWithNumber:3]]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email, [self testUserWithNumber:3].email]]];
}

//13. Send three messages to a user. Log out. Log back in as the recipient user. Verify that the messages are there, marked as sent by the sender, in proper order.
- (void)testToVerifySuccesfullRecipetOfThreeMessages
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    [self deauthenticate];

    [self systemLoginUser:[self testUserWithNumber:1]];
    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];

    [self sendMessageWithText:@"Hello"];
    [self sendMessageWithText:@"This is a test message"];
    [self sendMessageWithText:@"This is another test message"];
    
    [self deauthenticate];

    [self systemLoginUser:[self testUserWithNumber:2]];

    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].email]]];
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].email]]];

    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:[self testUserWithNumber:1].email]];
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test message" andUser:[self testUserWithNumber:1].email]];
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is another test message" andUser:[self testUserWithNumber:1].email]];
}

//14. Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Open one of the individual conversations and send three messages. Open the group chat and send one message. Log out and back in as the recipient of the three messages. Verify that two conversations are listed – one with three messages and another group chat with one message, all with the proper participants.
- (void)testToVerifyMultipleMessagesSentToMultipleRecipeientsAreReciecvedAndDisplayedForTheRecipients
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:3]];
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
    
    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email]]];
    
    [self startConversationWithUsers:@[[self testUserWithNumber:3]]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:3].email]]];
    
    [self startConversationWithUsers:@[[self testUserWithNumber:2], [self testUserWithNumber:3]]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email, [self testUserWithNumber:3].email]]];
    
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email]]];
    [self sendMessageWithText:@"Hello"];
    [self sendMessageWithText:@"This is a test message"];
    [self sendMessageWithText:@"This is another test message"];
    
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];

    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email, [self testUserWithNumber:3].email]]];
    [self sendMessageWithText:@"Hello"];
    
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:2]];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].fullName]]];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].fullName, [self testUserWithNumber:3].fullName]]];
}

//15. Create three users. Log in as one of them. Send a message to one contact. Log out and in as that contact. Reply to the original message. Log out and in as the first user, and verify that the reply shows up below the originally sent message.
- (void)testToVerifySendingRecievingAndReplyingToAMessage
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:3]];
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
    
    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];
    [self sendMessageWithText:@"Hello"];
    
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:2]];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].email]]];
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].email]]];
    [self sendMessageWithText:@"This is a test reply message"];
    
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email]]];
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email]]];
    
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:[self testUserWithNumber:1].fullName]];
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test reply message" andUser:[self testUserWithNumber:2].fullName]];
}

//16. Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Open one of the individual conversations and send three messages. Tap back and verify that the latest message is displayed in the proper conversation's list item.
- (void)testToVerifyTheLatestMessageInANewConversationIsDisplayedInConversationList
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:3]];
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
    
    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email]]];
    
    [self startConversationWithUsers:@[[self testUserWithNumber:3]]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:3].email]]];
    
    [self startConversationWithUsers:@[[self testUserWithNumber:2], [self testUserWithNumber:3]]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email, [self testUserWithNumber:3].email]]];
    
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:3].email]]];
    [self sendMessageWithText:@"Hello"];
    [self sendMessageWithText:@"This is a test message"];
    [self sendMessageWithText:@"This is another test message"];
    
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    //[tester waitForViewWithAccessibilityLabel:@"This is another test message"];
}

//17. Push an image to a know location on the device. Create two users. Log in as one, create a conversation with the other. Tap the camera button. Verify that a photo prompt pops up with options for taking a picture or attaching an image from the filesystem. Select the filesystem option. Select the pushed photo. Verify that a photo is added to the conversation view.
- (void)testToVerifySelectingAnImageFromTheCameraRollAndSending
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
    
    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];
    
    [self selectPhotoFromCameraRoll];
}

//18. Push an image to a know location on the device. Create two users. Log in as one and send a photo to the other. Log in as the recipient and verify that the photo was received.
- (void)testToVerifyASentPhotoIsRecievedByTheRecipient
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
    
    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];
    
    [self selectPhotoFromCameraRoll];
    [self sendPhoto];
    
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:2]];
    
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].fullName]]];
    
    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForemail:[self testUserWithNumber:1].fullName]];
}

//19. Push three images to known locations. Create three users. Log in as one and create a group chat with the other two. Send two text messages and one of the photos. Log in as the second user. Send another photo and two additional text messages. Log in as the third user. Verify that the prior messages are all there in the proper order from the proper senders.
- (void)testToVerifyThatPhotosAndMessagesAreAccuratelySentAndRecievedByMultipleParticipantsInAGroupChat
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:3]];
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
    
    [self startConversationWithUsers:@[[self testUserWithNumber:2], [self testUserWithNumber:3]]];
    
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].fullName, [self testUserWithNumber:3].fullName]]];
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].fullName, [self testUserWithNumber:3].fullName]]];
    
    [self sendMessageWithText:@"Hello"];
    [self sendMessageWithText:@"This is a test message"];
    
    [self selectPhotoFromCameraRoll];
    [self sendPhoto];
    
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:2]];
    
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].fullName, [self testUserWithNumber:3].fullName]]];
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].fullName, [self testUserWithNumber:3].fullName]]];
    
    [self selectPhotoFromCameraRoll];
    [self sendPhoto];

    [self sendMessageWithText:@"Hello"];
    [self sendMessageWithText:@"This is another test message"];
    
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:3]];
    
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].fullName, [self testUserWithNumber:2].fullName]]];
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].fullName, [self testUserWithNumber:2].fullName]]];
    
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:[self testUserWithNumber:2].fullName]];
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is another test message" andUser:[self testUserWithNumber:2].fullName]];
    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForemail:[self testUserWithNumber:2].fullName]];
    
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:[self testUserWithNumber:1].fullName]];
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test message" andUser:[self testUserWithNumber:1].fullName]];
    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForemail:[self testUserWithNumber:1].fullName]];
}

- (void)testStarting5ConversationsAndSending5MessagesThenLoggingInOnRecipientsDevice
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:3]];
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
    
    for (int i = 0; i < 5; i++) {
        [self startConversationWithUsers:@[[self testUserWithNumber:2], [self testUserWithNumber:3]]];
        for (int i = 0; i < 5; i++) {
           [self sendMessageWithText:[NSString stringWithFormat:@"Hello %d", i]];
        }
        [tester tapViewWithAccessibilityLabel:@"Back"];
        [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    }
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:2]];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].fullName, [self testUserWithNumber:3].fullName]]];
    [tester waitForTimeInterval:5];
}

- (void)testCreating2Users10ConversationsBetweenThemAndSending10MessagesEach
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    [self deauthenticate];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
}

- (void)testToVerifyPushNotificationsAreWorking
{
    [self systemRegisterUser:[self testUserWithNumber:1]];
    
    [self deauthenticate];
    
    [self systemRegisterUser:[self testUserWithNumber:2]];
    
    [self createConversations:10 withParticipants:nil andMessages:10];
    
    [tester waitForTimeInterval:10];
    
    [self deauthenticate];
    
    [tester waitForTimeInterval:10];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
}

//======== Factory Methods =========//

- (void)presentAuthenticationViewController
{
    [system presentViewControllerWithClass:[LSAuthenticationViewController class] withinNavigationControllerWithNavigationBarClass:[UINavigationBar class] toolbarClass:nil configurationBlock:^(id viewController) {

    }];
}
- (void)presentConversationsListViewController
{

}

#pragma mark
#pragma mark Test User Registration and Login Methods
- (void)registerTestUser:(LSUser *)testUser
{
    [tester tapViewWithAccessibilityLabel:@"Register Button"];
    [tester enterText:testUser.firstName intoViewWithAccessibilityLabel:@"First Name"];
    [tester enterText:testUser.lastName intoViewWithAccessibilityLabel:@"Last Name"];
    [tester enterText:testUser.email intoViewWithAccessibilityLabel:@"Email"];
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:@"Password"];
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:@"Confirmation"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
}

- (void)loginAsTestUser:(LSUser *)testUser
{
    [tester tapViewWithAccessibilityLabel:@"Login Button"];
    [tester enterText:testUser.email intoViewWithAccessibilityLabel:@"Email"];
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:@"Password"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
}

- (void)systemRegisterUser:(LSUser *)user
{
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:5.0];
    [self.APIManager registerUser:user completion:^(LSUser *user, NSError *error) {
        
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
}

- (void)systemLoginUser:(LSUser *)user
{
//    [tester waitForTimeInterval:4];
//    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:5.0];
//    [self.APIManager authenticateWithEmail:user.email password:user.password completion:^(LSUser *user, NSError *error) {
//        
//        [latch decrementCount];
//    }];
//    [latch waitTilCount:0];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
}

- (void)logout
{
    [tester tapViewWithAccessibilityLabel:@"logout"];
}

#pragma mark
#pragma mark Start Conversation

- (void)startConversationWithUsers:(NSArray *)users
{
    [tester tapViewWithAccessibilityLabel:@"New"];
    [tester waitForViewWithAccessibilityLabel:@"Contacts"];
    for (LSUser *user in users) {
        [tester waitForViewWithAccessibilityLabel:user.fullName];
        [tester tapViewWithAccessibilityLabel:user.fullName];
    }
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [self sendMessageWithText:@"Hello"];
    [tester waitForViewWithAccessibilityLabel:@"Conversation"];
}

- (NSString *)conversationCellLabelForParticipants:(NSArray *)participantNames
{
    NSSet *set = [[NSSet alloc] initWithArray:participantNames];
    NSArray *sortedNames = [self sortedFullNamesForParticiapnts:set];
    LSConversationCellPresenter *presenter = [LSConversationCellPresenter new];
    //NSString *string = [presenter conversationLabelForParticipantNames:sortedNames];
    //return string;
    return @"";
}

- (NSArray *)sortedFullNamesForParticiapnts:(NSSet *)participants
{
    NSError *error;
    LSSession *session = [self.persistenceManager persistedSessionWithError:&error];
    LSUser *authenticatedUser = session.user;
    
    NSMutableArray *fullNames = [NSMutableArray new];
    NSSet *persistedUsers = [self.persistenceManager persistedUsersWithError:&error];
    for (NSString *email in participants) {
        for (LSUser *persistedUser in persistedUsers) {
            if ([email isEqualToString:persistedUser.email] && ![email isEqualToString:authenticatedUser.email]) {
                [fullNames addObject:persistedUser.fullName];
            }
        }
    }
    return [fullNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

#pragma mark
#pragma mark Send Message

- (void)sendMessageWithText:(NSString *)text
{
    [tester enterText:text intoViewWithAccessibilityLabel:@"Compose TextView"];
    [tester tapViewWithAccessibilityLabel:@"Send Button"];
    
    NSError *error;
    LSSession *session = [self.persistenceManager persistedSessionWithError:&error];
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:text andUser:session.user.fullName]];
}

- (void)createConversations:(NSUInteger)conversationCount withParticipants:(NSSet *)participants andMessages:(NSUInteger)messages
{
    NSSet *persistedUsers = [self.persistenceManager persistedUsersWithError:nil];
    
    for (int i = 0; i < conversationCount; i++) {
        NSSet *participantIDs = [persistedUsers valueForKey:@"userID"];
        LYRConversation *conversation = [LYRConversation conversationWithParticipants:participantIDs];
        for (int m = 0; m < messages; m++) {
            LYRMessagePart *part = [LYRMessagePart messagePartWithText:@"This is a test"];
            LYRMessage *message = [LYRMessage messageWithConversation:conversation parts:@[part]];
            [self.layerClient sendMessage:message error:nil];
        }
    }
}

- (NSString *)messageCellLabelForText:(NSString *)text andUser:(NSString *)fullName
{
    return text;
}

- (void)selectPhotoFromCameraRoll
{
    [tester tapViewWithAccessibilityLabel:@"Cam Button"];
    [tester tapViewWithAccessibilityLabel:@"Choose Existing"];
    [tester tapViewWithAccessibilityLabel:@"Saved Photos"];
    [tester tapViewWithAccessibilityLabel:@"Photo, Landscape, 10:35 AM"];
    [tester waitForViewWithAccessibilityLabel:@"composeView"];
}

-(void)sendPhoto
{
    [tester tapViewWithAccessibilityLabel:@"Send Button"];
    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForemail:[self testUserWithNumber:1].fullName]];
    [tester waitForTimeInterval:10];
}

- (NSString *)imageCelLabelForemail:(NSString *)fullName
{
    return @"image";
}

#pragma mark
#pragma mark Logout Methods

- (void)deauthenticate
{
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:5.0];
//    [self.APIManager deauthenticateWithCompletion:^(BOOL success, NSError *error) {
//        [latch decrementCount];
//    }];
    [latch waitTilCount:0];
}

- (LSUser *)testUserWithNumber:(NSUInteger)number
{
    return [LYRUITestUser testUserWithNumber:number];
}

- (LSUser *)testUserWithFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    LSUser *user = [[LSUser alloc] init];
    user.firstName = firstName;
    user.lastName = lastName;
    return user;
}

@end
