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
#import "LSUser.h"
#import "LYRCountdownLatch.h"
#import "LSPersistenceManager.h"
#import "LSApplicationController.h"
#import "LSAppDelegate.h"
#import "LYRUITestUser.h"
#import "LYRUITestInterface.h"
#import "LYRUILayerContentFactory.h"
#import "LYRTestUtilities.h"
#import "LYRTestingContext.h"
#import "LSUIConversationViewController.h"

@interface LYRClient ()

@property (nonatomic) LYRSession *session;

- (void)synchronizeWithCompletion:(void(^)())completion;

@end

@interface LSSampleAppUITest : KIFTestCase

@property (nonatomic) LSApplicationController *controller;
@property (nonatomic) LSPersistenceManager *persistenceManager;
@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) LSAPIManager *APIManager;
@property (nonatomic) LYRUITestInterface *testInterface;
@property (nonatomic) LYRUILayerContentFactory *layerContentFactory;

@end

@implementation LSSampleAppUITest

static NSString *const LSLoginText = @"Login To Layer";
static NSString *const LSRegisterText = @"Create Account";

- (void)beforeEach
{
    LSApplicationController *applicationController =  [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [LYRUITestInterface testInterfaceWithApplicationController:applicationController];
    self.layerContentFactory = [LYRUILayerContentFactory layerContentFactoryWithLayerClient:applicationController.layerClient];
    [self.testInterface deleteContacts];
}

- (void)afterEach
{
    [self.testInterface logout];
}

//1. Log in with incorrect credentials and verify that an error prompt pops up.
- (void)testToVerifyIncorrectLoginCredentialsAlert
{
    [tester enterText:@"fakeEmail@layer.com" intoViewWithAccessibilityLabel:@"Email"];
    [tester enterText:@"fakePassword" intoViewWithAccessibilityLabel:@"Password"];
    [tester tapViewWithAccessibilityLabel:LSLoginText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
}

//2. Tap register, enter valid info, and verify success.
- (void)testToVerifyRegistrationFunctionality
{
    [self registerTestUser:[self testUserWithNumber:0]];
}


//3. Successfully log in with good credentials.
- (void)testToVerifySuccesfulLogin
{
    [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    [self loginAsTestUser:[self testUserWithNumber:1]];
}

//4. Tap register, enter nothing, and verify that a prompt came up requesting valid info. Add a first name. Tap register and verify that a prompt requested more info. Continue adding data until success.
- (void)testToVerifyIncompleteInfoRegistrationFunctionality
{
    LSUser *testUser = [self testUserWithNumber:3];
    [tester tapViewWithAccessibilityLabel:LSRegisterText];
    
    [tester enterText:testUser.firstName intoViewWithAccessibilityLabel:@"First Name"];
    [tester tapViewWithAccessibilityLabel:LSRegisterText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    [tester enterText:testUser.lastName intoViewWithAccessibilityLabel:@"Last Name"];
    [tester tapViewWithAccessibilityLabel:LSRegisterText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    [tester enterText:testUser.email intoViewWithAccessibilityLabel:@"Email"];
    [tester tapViewWithAccessibilityLabel:LSRegisterText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:@"Password"];
    [tester tapViewWithAccessibilityLabel:LSRegisterText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    [tester enterText:testUser.passwordConfirmation intoViewWithAccessibilityLabel:@"Confirmation"];
    [tester tapViewWithAccessibilityLabel:LSRegisterText];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    
}

//5. Register a user. Register and login as a second user. Verify that the first user is in the address book.
- (void)testToVerifyAddressBookFunctionalityForFirstTwoUsers
{
    [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:2]];
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:1]];
    [tester tapViewWithAccessibilityLabel:@"New"];
    [tester waitForViewWithAccessibilityLabel:[LYRUITestUser testUserWithNumber:2].fullName];
}

////6. Register two users. Log in. Tap the contact and verify that its checkbox checks. Tap it again and verify that the checkbox unchecks.
//-(void)testToVerifyAddressBookSelectionIndicatorFunctionality
//{
//    [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
//    [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:2]];
//    
//    LSUser *user1 = [LYRUITestUser testUserWithNumber:1];
//    [self.testInterface authenticateWithEmail:user1.email password:user1.password];
//    [self.testInterface loadContacts];
//    
//    [tester tapViewWithAccessibilityLabel:@"New"];
//    [tester waitForViewWithAccessibilityLabel:[LYRUITestUser testUserWithNumber:2].fullName];
//    [tester tapViewWithAccessibilityLabel:[LYRUITestUser testUserWithNumber:2].fullName];
//    
//    [tester waitForViewWithAccessibilityLabel:[self.testInterface selectionIndicatorAccessibilityLabelForUser:[LYRUITestUser testUserWithNumber:2]]];
//    [tester tapViewWithAccessibilityLabel:[LYRUITestUser testUserWithNumber:2].fullName];
//    [tester waitForAbsenceOfViewWithAccessibilityLabel:[self.testInterface selectionIndicatorAccessibilityLabelForUser:[LYRUITestUser testUserWithNumber:2]]];
//}

//7. Register two users. Log in. Tap the contact to check its checkbox. Tap the "+" to start a conversation and verify that the proper Conversation view is shown.
-(void)testToVerifyStartingAConversationWithTwoContacts
{
    [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:2]];
    [self startConversationWithUsers:@[[LYRUITestUser testUserWithNumber:1]]];
}

//8. Register two users. Log in and start a conversation. Tap the back button and verify that the ConversationList Returns
- (void)testToVerifyNavigationBetweenContactsandConversations
{
    [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:2]];
    [self startConversationWithUsers:@[[LYRUITestUser testUserWithNumber:1]]];
    
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
}

//9. Register two users. Log in as one and start a conversation. Verify that the focus is automatically set on the message entry box. Type "hello!" and verify that "hello!" appears in the entry box. Tap "send" and verify that a message with "hello!" is added to the conversation history. Send "Do you hear me?" and verify that the new message is added below the first.
-(void)testToVerifyUIAnimimationsForSendingAMessage
{
    [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:2]];
    [self startConversationWithUsers:@[[LYRUITestUser testUserWithNumber:1]]];
    [self sendMessageWithText:@"Hello"];
    [self sendMessageWithText:@"This is a test message"];
}
//
//10. Register two users. Log in and start a conversation. Log out and back in. Verify that the old conversation is still there.
-(void)testToVerifyConversationPersistenceFunctionality
{
    [self.testInterface registerUser:[LYRUITestUser testUserWithNumber:1]];
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:2]];
    LSUser *randomUser = [self.testInterface randomUser];
    [self startConversationWithUsers:@[randomUser]];
   
    [self.testInterface logout];
    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:2]];
    
    NSSet *participantSet = [NSSet setWithObject:randomUser.userID];
    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:participantSet]];
}

//11. Send three messages to a user. Log out. Log back in with the same account. Verify that the old messages are still there in proper order.
- (void)testToVerifySentMessagePersistence
{
    NSString *message1 = @"Hello";
    NSString *message2 = @"This is a test message";
    NSString *message3 = @"This is another test message";
    
    LSUser *testUser1 = [LYRUITestUser testUserWithNumber:1];
    [self.testInterface registerAndAuthenticateUser:testUser1];
    
    LSUser *randomUser = [self.testInterface randomUser];
    [self startConversationWithUsers:@[randomUser]];
    [self sendMessageWithText:message1];
    [self sendMessageWithText:message2];
    [self sendMessageWithText:message3];
    [self.testInterface logout];
    
    [self.testInterface authenticateWithEmail:testUser1.email password:testUser1.password];
    NSSet *participantSet = [NSSet setWithObject:randomUser.userID];
    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:participantSet]];
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:participantSet]];
    
    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Message: %@", message1]];
    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Message: %@", message2]];
    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Message: %@", message3]];
}
//
////12. Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Verify that all three conversations show up on the Conversations list with proper names displayed.
//- (void)testToVerifyThreeNewConversationsAreDisplayedInconversationList
//{
//    LSUser *testUser1 = [LYRUITestUser testUserWithNumber:1];
//    [self.testInterface registerAndAuthenticateUser:testUser1];
//
//    LSUser *randomUser1 = [self.testInterface randomUser];
//    LSUser *randomUser2 = [self.testInterface randomUser];
//    
//    [self startConversationWithUsers:@[randomUser1]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    NSSet *participantSet1 = [NSSet setWithObject:randomUser1.userID];
//    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:participantSet1]];
//    
//    [self startConversationWithUsers:@[randomUser2]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//     NSSet *participantSet2 = [NSSet setWithObject:randomUser2.userID];
//    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:participantSet2]];
//    
//    [self startConversationWithUsers:@[randomUser1, randomUser2]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    NSSet *participantSet3 = [NSSet setWithObjects:randomUser1.userID, randomUser2.userID, nil];
//    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:participantSet3]];
//}
//
////13. Send three messages to a user. Log out. Log back in as the recipient user. Verify that the messages are there, marked as sent by the sender, in proper order.
//- (void)testToVerifySuccesfullRecipetOfThreeMessages
//{
//    [self systemRegisterUser:[self testUserWithNumber:1]];
//    [self deauthenticate];
//    
//    [self systemRegisterUser:[self testUserWithNumber:2]];
//    [self deauthenticate];
//
//    [self systemLoginUser:[self testUserWithNumber:1]];
//    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];
//
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    [self sendMessageWithText:@"This is another test message"];
//    
//    [self deauthenticate];
//
//    [self systemLoginUser:[self testUserWithNumber:2]];
//
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].email]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].email]]];
//
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:[self testUserWithNumber:1].email]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test message" andUser:[self testUserWithNumber:1].email]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is another test message" andUser:[self testUserWithNumber:1].email]];
//}
//
////14. Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Open one of the individual conversations and send three messages. Open the group chat and send one message. Log out and back in as the recipient of the three messages. Verify that two conversations are listed – one with three messages and another group chat with one message, all with the proper participants.
//- (void)testToVerifyMultipleMessagesSentToMultipleRecipeientsAreReciecvedAndDisplayedForTheRecipients
//{
//    [self systemRegisterUser:[self testUserWithNumber:1]];
//    [self deauthenticate];
//    
//    [self systemRegisterUser:[self testUserWithNumber:2]];
//    [self deauthenticate];
//    
//    [self systemRegisterUser:[self testUserWithNumber:3]];
//    [self deauthenticate];
//    
//    [self systemLoginUser:[self testUserWithNumber:1]];
//    
//    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email]]];
//    
//    [self startConversationWithUsers:@[[self testUserWithNumber:3]]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:3].email]]];
//    
//    [self startConversationWithUsers:@[[self testUserWithNumber:2], [self testUserWithNumber:3]]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email, [self testUserWithNumber:3].email]]];
//    
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email]]];
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    [self sendMessageWithText:@"This is another test message"];
//    
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email, [self testUserWithNumber:3].email]]];
//    [self sendMessageWithText:@"Hello"];
//    
//    [self deauthenticate];
//    
//    [self systemLoginUser:[self testUserWithNumber:2]];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].fullName]]];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].fullName, [self testUserWithNumber:3].fullName]]];
//}
//
////15. Create three users. Log in as one of them. Send a message to one contact. Log out and in as that contact. Reply to the original message. Log out and in as the first user, and verify that the reply shows up below the originally sent message.
//- (void)testToVerifySendingRecievingAndReplyingToAMessage
//{
//    [self systemRegisterUser:[self testUserWithNumber:1]];
//    [self deauthenticate];
//    
//    [self systemRegisterUser:[self testUserWithNumber:2]];
//    [self deauthenticate];
//    
//    [self systemRegisterUser:[self testUserWithNumber:3]];
//    [self deauthenticate];
//    
//    [self systemLoginUser:[self testUserWithNumber:1]];
//    
//    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];
//    [self sendMessageWithText:@"Hello"];
//    
//    [self deauthenticate];
//    
//    [self systemLoginUser:[self testUserWithNumber:2]];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].email]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].email]]];
//    [self sendMessageWithText:@"This is a test reply message"];
//    
//    [self deauthenticate];
//    
//    [self systemLoginUser:[self testUserWithNumber:1]];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email]]];
//    
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:[self testUserWithNumber:1].fullName]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test reply message" andUser:[self testUserWithNumber:2].fullName]];
//}
//
////16. Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Open one of the individual conversations and send three messages. Tap back and verify that the latest message is displayed in the proper conversation's list item.
//- (void)testToVerifyTheLatestMessageInANewConversationIsDisplayedInConversationList
//{
//    [self systemRegisterUser:[self testUserWithNumber:1]];
//    [self deauthenticate];
//    
//    [self systemRegisterUser:[self testUserWithNumber:2]];
//    [self deauthenticate];
//    
//    [self systemRegisterUser:[self testUserWithNumber:3]];
//    [self deauthenticate];
//    
//    [self systemLoginUser:[self testUserWithNumber:1]];
//    
//    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email]]];
//    
//    [self startConversationWithUsers:@[[self testUserWithNumber:3]]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:3].email]]];
//    
//    [self startConversationWithUsers:@[[self testUserWithNumber:2], [self testUserWithNumber:3]]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].email, [self testUserWithNumber:3].email]]];
//    
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:3].email]]];
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    [self sendMessageWithText:@"This is another test message"];
//    
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    //[tester waitForViewWithAccessibilityLabel:@"This is another test message"];
//}
//
////17. Push an image to a know location on the device. Create two users. Log in as one, create a conversation with the other. Tap the camera button. Verify that a photo prompt pops up with options for taking a picture or attaching an image from the filesystem. Select the filesystem option. Select the pushed photo. Verify that a photo is added to the conversation view.
//- (void)testToVerifySelectingAnImageFromTheCameraRollAndSending
//{
//    [self systemRegisterUser:[self testUserWithNumber:1]];
//    [self deauthenticate];
//    
//    [self systemRegisterUser:[self testUserWithNumber:2]];
//    [self deauthenticate];
//    
//    [self systemLoginUser:[self testUserWithNumber:1]];
//    
//    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];
//    
//    [self selectPhotoFromCameraRoll];
//}
//
////18. Push an image to a know location on the device. Create two users. Log in as one and send a photo to the other. Log in as the recipient and verify that the photo was received.
//- (void)testToVerifyASentPhotoIsRecievedByTheRecipient
//{
//    [self systemRegisterUser:[self testUserWithNumber:1]];
//    [self deauthenticate];
//    
//    [self systemRegisterUser:[self testUserWithNumber:2]];
//    [self deauthenticate];
//    
//    [self systemLoginUser:[self testUserWithNumber:1]];
//    
//    [self startConversationWithUsers:@[[self testUserWithNumber:2]]];
//    
//    [self selectPhotoFromCameraRoll];
//    [self sendPhoto];
//    
//    [self deauthenticate];
//    
//    [self systemLoginUser:[self testUserWithNumber:2]];
//    
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].fullName]]];
//    
//    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForemail:[self testUserWithNumber:1].fullName]];
//}
//
////19. Push three images to known locations. Create three users. Log in as one and create a group chat with the other two. Send two text messages and one of the photos. Log in as the second user. Send another photo and two additional text messages. Log in as the third user. Verify that the prior messages are all there in the proper order from the proper senders.
//- (void)testToVerifyThatPhotosAndMessagesAreAccuratelySentAndRecievedByMultipleParticipantsInAGroupChat
//{
//    [self systemRegisterUser:[self testUserWithNumber:1]];
//    [self deauthenticate];
//    
//    [self systemRegisterUser:[self testUserWithNumber:2]];
//    [self deauthenticate];
//    
//    [self systemRegisterUser:[self testUserWithNumber:3]];
//    [self deauthenticate];
//    
//    [self systemLoginUser:[self testUserWithNumber:1]];
//    
//    [self startConversationWithUsers:@[[self testUserWithNumber:2], [self testUserWithNumber:3]]];
//    
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].fullName, [self testUserWithNumber:3].fullName]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:2].fullName, [self testUserWithNumber:3].fullName]]];
//    
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    
//    [self selectPhotoFromCameraRoll];
//    [self sendPhoto];
//    
//    [self deauthenticate];
//    
//    [self systemLoginUser:[self testUserWithNumber:2]];
//    
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].fullName, [self testUserWithNumber:3].fullName]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].fullName, [self testUserWithNumber:3].fullName]]];
//    
//    [self selectPhotoFromCameraRoll];
//    [self sendPhoto];
//
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is another test message"];
//    
//    [self deauthenticate];
//    
//    [self systemLoginUser:[self testUserWithNumber:3]];
//    
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].fullName, [self testUserWithNumber:2].fullName]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].fullName, [self testUserWithNumber:2].fullName]]];
//    
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:[self testUserWithNumber:2].fullName]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is another test message" andUser:[self testUserWithNumber:2].fullName]];
//    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForemail:[self testUserWithNumber:2].fullName]];
//    
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:[self testUserWithNumber:1].fullName]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test message" andUser:[self testUserWithNumber:1].fullName]];
//    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForemail:[self testUserWithNumber:1].fullName]];
//}
//
//- (void)testStarting5ConversationsAndSending5MessagesThenLoggingInOnRecipientsDevice
//{
//    [self systemRegisterUser:[self testUserWithNumber:1]];
//    [self deauthenticate];
//    
//    [self systemRegisterUser:[self testUserWithNumber:2]];
//    [self deauthenticate];
//    
//    [self systemRegisterUser:[self testUserWithNumber:3]];
//    [self deauthenticate];
//    
//    [self systemLoginUser:[self testUserWithNumber:1]];
//    
//    for (int i = 0; i < 5; i++) {
//        [self startConversationWithUsers:@[[self testUserWithNumber:2], [self testUserWithNumber:3]]];
//        for (int i = 0; i < 5; i++) {
//           [self sendMessageWithText:[NSString stringWithFormat:@"Hello %d", i]];
//        }
//        [tester tapViewWithAccessibilityLabel:@"Back"];
//        [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    }
//    [self deauthenticate];
//    
//    [self systemLoginUser:[self testUserWithNumber:2]];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[[self testUserWithNumber:1].fullName, [self testUserWithNumber:3].fullName]]];
//    [tester waitForTimeInterval:5];
//}
//
//- (void)testCreating2Users10ConversationsBetweenThemAndSending10MessagesEach
//{
//    [self systemRegisterUser:[self testUserWithNumber:1]];
//    [self deauthenticate];
//    
//    [self systemRegisterUser:[self testUserWithNumber:2]];
//    [self deauthenticate];
//    
//    [self systemLoginUser:[self testUserWithNumber:1]];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//}
//
//- (void)testToVerifyPushNotificationsAreWorking
//{
//    [self systemRegisterUser:[self testUserWithNumber:1]];
//    
//    [self deauthenticate];
//    
//    [self systemRegisterUser:[self testUserWithNumber:2]];
//    
//    [self createConversations:10 withParticipants:nil andMessages:10];
//    
//    [tester waitForTimeInterval:10];
//    
//    [self deauthenticate];
//    
//    [tester waitForTimeInterval:10];
//    
//    [self systemLoginUser:[self testUserWithNumber:1]];
//}
//
//======== Factory Methods =========//

- (void)testThatSendingNewMessageFromSecondClientCausesConversationListToUpdate
{
    LYRClient *client2 = [LYRClient clientWithAppID:self.layerClient.appID];
    LYRClient *client3 = [LYRClient clientWithAppID:self.layerClient.appID];
    NSArray *clients = @[self.layerClient, client2, client3];
    LYRTestConnectAndAuthenticateClients(clients);
    
    // Load the view up
    LSUIConversationListViewController *controller = [LSUIConversationListViewController conversationListViewControllerWithLayerClient:self.layerClient];
    UIViewController *baseController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [baseController presentViewController:navigationController animated:YES completion:nil];
    
    NSSet *participants = [NSSet setWithObjects:client2.authenticatedUserID, client3.authenticatedUserID, nil];
    LYRConversation *conversation = [self.layerClient newConversationWithParticipants:participants options:nil error:nil];
    expect(conversation).notTo.beNil();
    [tester waitForViewWithAccessibilityLabel:@"Messages"];
    
    // TODO: Seed with 50 messages
    for (int i = 0; i < 3; i++) {
        int clientIndex = arc4random_uniform((int)clients.count);
        LYRClient *client = [clients objectAtIndex:clientIndex];
        [self sendMessageFromClient:client toConversation:conversation];
        LYRTestWaitForSyncNotificationFromClientWithBlock(self.layerClient, ^{
            
        });
    }
    [tester waitForViewWithAccessibilityLabel:@"No Matching Participants"];
    [tester tapViewWithAccessibilityLabel:@"No Matching Participants"];
    
    
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_queue_t dispatchQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    NSMutableArray *clientQueues = [NSMutableArray arrayWithCapacity:clients.count];
    for (NSUInteger i=0; i<10; i++) {
        dispatch_queue_t clientQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
        [clientQueues addObject:clientQueue];
    }
    
    dispatch_source_t dispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    uint64_t interval = (uint64_t)(1.0 * NSEC_PER_SEC);
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, interval);
    dispatch_source_set_timer(dispatchSource, startTime, interval, 1.0);
    dispatch_source_set_event_handler(dispatchSource, ^{
        //[self leaveAndReturnToConversation:conversation];
    });
    
    for (NSUInteger i=0; i<1000; i++) {
        dispatch_async(dispatchQueue, ^{
            // Select random client
            int clientIndex = arc4random_uniform((int)clients.count);
            LYRClient *client = clients[clientIndex];
            
            dispatch_queue_t clientQueue = clientQueues[clientIndex];
            // synchronize, send message, mark message as read, delete message
            dispatch_group_enter(dispatchGroup);
            dispatch_async(clientQueue, ^{
                int operation = arc4random_uniform(2);
                switch (operation) {
                    case 0: // Send message
                        NSLog(@"CLIENT ID IS %@", client.authenticatedUserID);
                        //NSLog(@"Executing Insert operation number %lu for client %d", (unsigned long)i, clientIndex);
                        [self sendMessageFromClient:client2 toConversation:[self conversationWithIdentifier:conversation.identifier forClient:client2]];
                        break;
                        
                    case 1:  {// Query for unread message and mark as read
                        //NSLog(@"Executing Update operation number %lu", (unsigned long)i);
                        LYRMessage *message = [self fetchUnreadMessageFromConversation:[self conversationWithIdentifier:conversation.identifier forClient:client]];
                        NSError *error;
                        BOOL success = [message markAsRead:&error];
                        expect(success).to.beTruthy;
                        expect(error).to.beNil;
                    }
                        break;
                        
                    case 2:  {// Query for a message and delete it
                        //NSLog(@"Executing Delete operation number %lu", (unsigned long)i);
                        LYRMessage *message = [self fetchUnreadMessageFromConversation:[self conversationWithIdentifier:conversation.identifier forClient:client]];
                        NSError *error;
                        BOOL success = [message delete:LYRDeletionModeAllParticipants error:&error];
                        expect(success).to.beTruthy;
                        expect(error).to.beNil;
                    }
                        break;
                        
                    default:
                        break;
                }
                
                [client synchronizeWithCompletion:^{
                    dispatch_group_leave(dispatchGroup);
                }];
            });
        });
    }
    dispatch_resume(dispatchSource);
    
    __block BOOL isWaiting = YES;
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
        isWaiting = NO;
    });
    
    [tester runBlock:^KIFTestStepResult(NSError *__autoreleasing *error) {
        return isWaiting ? KIFTestStepResultWait : KIFTestStepResultSuccess;
    } timeout:800];
    [tester waitForAnimationsToFinish];
}

- (void)leaveAndReturnToConversation:(LYRConversation *)conversation
{
    UINavigationController *controller = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController].presentedViewController;
    [controller popToRootViewControllerAnimated:TRUE];
    LSUIConversationViewController *conversationViewController = [LSUIConversationViewController conversationViewControllerWithConversation:conversation layerClient:self.layerClient];
    conversationViewController.applicationContoller = self.testInterface.applicationController;
    conversationViewController.showsAddressBar = YES;
    if ([controller.viewControllers[0] isKindOfClass:[LSUIConversationListViewController class]]) {
        [controller pushViewController:conversationViewController animated:YES];
    }
}

- (void)sendMessageFromClient:(LYRClient *)client toConversation:(LYRConversation *)conversation
{
    NSError *error = nil;
    LYRMessagePart *part = [LYRMessagePart messagePartWithText:@"test message"];
    LYRMessage *message1 = [client newMessageWithParts:@[part] options:nil error:&error];
    BOOL success = [conversation sendMessage:message1 error:&error];
    NSLog(@"MEssage Sent by userID %@", message1.sentByUserID);
    expect(success).to.beTruthy();
}

- (LYRConversation *)conversationWithIdentifier:(NSURL *)identifier forClient:(LYRClient *)layerClient
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:identifier];
    NSError *error;
    NSOrderedSet *conversations = [layerClient executeQuery:query error:&error];
    expect(error).to.beNil;
    expect(conversations.count).to.beTruthy;
    return conversations[0];
}

- (LYRMessage *)fetchMessageFromConversation:(LYRConversation *)conversation
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"conversation" operator:LYRPredicateOperatorIsEqualTo value:conversation];
    
    NSError *error;
    NSOrderedSet *messages = [self.layerClient executeQuery:query error:&error];
    expect(error).to.beNil;
    if (messages.count) {
        return messages[0];
    } else {
        return nil;
    }
}

- (LYRMessage *)fetchUnreadMessageFromConversation:(LYRConversation *)conversation
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    LYRPredicate *unreadPredicate = [LYRPredicate predicateWithProperty:@"isUnread" operator:LYRPredicateOperatorIsEqualTo value:@(YES)];
    LYRPredicate *conversationPredicate = [LYRPredicate predicateWithProperty:@"conversation" operator:LYRPredicateOperatorIsEqualTo value:conversation];
    query.predicate = [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd subpredicates:@[unreadPredicate, conversationPredicate]];
    
    NSError *error;
    NSOrderedSet *messages = [self.layerClient executeQuery:query error:&error];
    expect(error).to.beNil;
    if (messages.count) {
        return messages[0];
    } else {
        return nil;
    }
}

#pragma mark
#pragma mark Test User Registration and Login Methods
- (void)registerTestUser:(LSUser *)testUser
{
    [tester tapViewWithAccessibilityLabel:LSRegisterText];
    [tester enterText:testUser.firstName intoViewWithAccessibilityLabel:@"First Name"];
    [tester enterText:testUser.lastName intoViewWithAccessibilityLabel:@"Last Name"];
    [tester enterText:testUser.email intoViewWithAccessibilityLabel:@"Email"];
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:@"Password"];
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:@"Confirmation"];
    [tester tapViewWithAccessibilityLabel:LSRegisterText];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
}

- (void)loginAsTestUser:(LSUser *)testUser
{
    [tester tapViewWithAccessibilityLabel:LSLoginText];
    [tester enterText:testUser.email intoViewWithAccessibilityLabel:@"Email"];
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:@"Password"];
    [tester tapViewWithAccessibilityLabel:LSLoginText];
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
    [tester waitForViewWithAccessibilityLabel:@"Participants"];
    for (LSUser *user in users) {
        [tester waitForViewWithAccessibilityLabel:user.fullName];
        [tester tapViewWithAccessibilityLabel:user.fullName];
    }
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [self sendMessageWithText:@"Hello"];
    [tester waitForViewWithAccessibilityLabel:@"Conversation"];
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
    [tester enterText:text intoViewWithAccessibilityLabel:@"Text Input View"];
    [tester tapViewWithAccessibilityLabel:@"Send Button"];
    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Message: %@", text]];
}

- (void)createConversations:(NSUInteger)conversationCount withParticipants:(NSSet *)participants andMessages:(NSUInteger)messages
{
    NSSet *persistedUsers = [self.persistenceManager persistedUsersWithError:nil];
    
    for (int i = 0; i < conversationCount; i++) {
        NSSet *participantIDs = [persistedUsers valueForKey:@"userID"];
        LYRConversation *conversation = [self.layerClient newConversationWithParticipants:participantIDs options:nil error:nil];
        for (int m = 0; m < messages; m++) {
            LYRMessagePart *part = [LYRMessagePart messagePartWithText:@"This is a test"];
            LYRMessage *message = [self.layerClient newMessageWithParts:@[part] options:nil error:nil];
            [conversation sendMessage:message error:nil];
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
