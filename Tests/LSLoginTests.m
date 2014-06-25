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
#import "LYRLog.h"

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
<<<<<<< HEAD
    LYRSetLogLevel(LYR_LOG_COLOR_VERBOSE);
=======
    /**
     If you are going to use user defaults as a data store, you'd be better off by putting a `reset` method on the `LSUserManager` interface that only deletes specific
     keys used for user management. Otherwise this approach could blow out keys stored by another part of the system and it requires refactoring your tests if you change
     data store implementations in the future.
     */
>>>>>>> blake-MSG-187-code-review-feedback
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [defaults removePersistentDomainForName:appDomain];
    [defaults synchronize];
    
    /**
     SBW: you never want to use `andWhatever` in an Objective-C method signature unless the method actually take two actions. For example, if you had an object
     that acted as indexed collection, you might have methods like `addObject:` and `reindex`. You may then want to add a new method that adds the objects from
     another collection and reindexes: `addObjectsFromArrayAndReindex:foo`. But if you wanted to parameterize it, you'd go with `addObjectsFromArray:array reindex:NO`.
     This is a very uncommon signature idiom. Try searching the Cocoa headers for the word `And` in method signatures. It rarely appears and typically only in very old
     API's such as `NSBundle`.
     */
    
    LSUser *user = [[LSUser alloc] init];
    [user setFullName:LSTestUser0FullName];
    [user setEmail:LSTestUser0Email];
    [user setPassword:LSTestUser0Password];
    [user setConfirmation:LSTestUser0Confirmation];
    [user setIdentifier:[[NSUUID UUID] UUIDString]];
    
    [[LSUserManager new] registerUser:user completion:^(BOOL success, NSError *error) {
        //
    }];
}

- (void)afterEach
{
    ///[tester returnToLoggedOutHomeScreen];
}

//1. Log in with incorrect credentials and verify that an error prompt pops up.
- (void)testToVerifyIncorrectLoginCredentialsAlert
{
    [tester tapViewWithAccessibilityLabel:@"Login Button"];
    [tester enterText:@"fakeEmail@layer.com" intoViewWithAccessibilityLabel:@"Username"];
    [tester enterText:@"fakePassword" intoViewWithAccessibilityLabel:@"Password"];
    [tester tapViewWithAccessibilityLabel:@"Login Button"];
    [tester waitForViewWithAccessibilityLabel:@"Invalid Credentials"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    [tester tapViewWithAccessibilityLabel:@"Home"];
}

//2. Tap register, enter valid info, and verify success.
- (void)testToVerifyRegistrationFunctionality
{
    [self registerTestUser:1];
    [self logoutFromConversationListViewController];
}

//3. Successfully log in with good credentials.
- (void)testToVerifySuccesfulLogin
{
    [self loginAsTestUser:0];
    [self logoutFromConversationListViewController];
}

//4. Tap register, enter nothing, and verify that a prompt came up requesting valid info. Add a first name. Tap register and verify that a prompt requested more info. Continue adding data until success.
- (void)testToVerifyIncompleteInfoRegistrationFunctionality
{
    [tester tapViewWithAccessibilityLabel:@"Register Button"];
    [tester enterText:LSTestUser1FullName intoViewWithAccessibilityLabel:@"Fullname"];
    [tester tapViewWithAccessibilityLabel:@"Register Button"];
    [tester waitForViewWithAccessibilityLabel:@"No Email"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    [tester enterText:LSTestUser1Email intoViewWithAccessibilityLabel:@"Username"];
    [tester tapViewWithAccessibilityLabel:@"Register Button"];
    [tester waitForViewWithAccessibilityLabel:@"Password Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    [tester enterText:LSTestUser1Password intoViewWithAccessibilityLabel:@"Password"];
    [tester tapViewWithAccessibilityLabel:@"Register Button"];
    [tester waitForViewWithAccessibilityLabel:@"Password Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    [tester enterText:LSTestUser1Confirmation intoViewWithAccessibilityLabel:@"Confirm"];
    [tester tapViewWithAccessibilityLabel:@"Register Button"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [self logoutFromConversationListViewController];
}

//5. Log in. Verify the address book is empty. Log out and register as a new user. Verify that the first user is in the address book.
- (void)testToVerifyAddressBookFunctionalityForFirstTwoUsers
{
    [self loginAsTestUser:0];
    [tester tapViewWithAccessibilityLabel:@"new"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"contactCell"];
    [self logoutFromContactViewController];
    [self registerTestUser:1];
    [tester tapViewWithAccessibilityLabel:@"new"];
    [tester waitForViewWithAccessibilityLabel:LSTestUser0FullName];
    [self logoutFromContactViewController];
}

//6. Register two users. Log in. Tap the contact and verify that its checkbox checks. Tap it again and verify that the checkbox unchecks.
-(void)testToVerifyAddressBookSelectionIndicatorFunctionality
{
    [self registerTestUser:1];
    [self logoutFromConversationListViewController];
    [self registerTestUser:2];
    [self logoutFromConversationListViewController];
    
    [self loginAsTestUser:1];
    [tester tapViewWithAccessibilityLabel:@"new"];
    [tester waitForViewWithAccessibilityLabel:LSTestUser2FullName];
    [tester tapViewWithAccessibilityLabel:LSTestUser2FullName];
    
    [tester waitForViewWithAccessibilityLabel:@"selectionIndicator"];
    [tester tapViewWithAccessibilityLabel:LSTestUser2FullName];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"selectionIndicator"];
    [self logoutFromContactViewController];
}

//7. Register two users. Log in. Tap the contact to check its checkbox. Tap the "+" to start a conversation and verify that the proper Conversation view is shown.
-(void)testToVerifyStartingAConversationWithTwoContacts
{
    [self registerTestUser:1];
    [self logoutFromConversationListViewController];
  
    [self registerTestUser:2];
    [self logoutFromConversationListViewController];
    
    [self loginAsTestUser:1];

    [self startConversationWithUsers:@[LSTestUser2FullName]];

    [self logoutFromConversationViewController];
}

//8. Register two users. Log in and start a conversation. Tap the back button and verify that the ConversationList Returns
- (void)testToVerifyNavigationBetweenContactsandConversations
{
    [self registerTestUser:1];
    [self logoutFromConversationListViewController];
    
    [self registerTestUser:2];
    [self logoutFromConversationListViewController];
    
    [self loginAsTestUser:1];
    [self startConversationWithUsers:@[LSTestUser2FullName]];
    
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    
    [self logoutFromConversationListViewController];
}

//9. Register two users. Log in as one and start a conversation. Verify that the focus is automatically set on the message entry box. Type "hello!" and verify that "hello!" appears in the entry box. Tap "send" and verify that a message with "hello!" is added to the conversation history. Send "Do you hear me?" and verify that the new message is added below the first.
-(void)testToVerifyUIAnimimationsForSendingAMessage
{
    [self registerTestUser:1];
    [self logoutFromConversationListViewController];
    
    [self registerTestUser:2];
    [self logoutFromConversationListViewController];
    
    [self loginAsTestUser:1];
    [self startConversationWithUsers:@[LSTestUser2FullName]];
    
    [self sendMessageWithText:@"Hello"];
    [self sendMessageWithText:@"This is a test message"];
    
    [self logoutFromConversationViewController];
}
//
//10. Register two users. Log in and start a conversation. Log out and back in. Verify that the old conversation is still there.
-(void)testToVerifyConversationPersistenceFunctionality
{
    [self registerTestUser:1];
    [self logoutFromConversationListViewController];

    [self registerTestUser:2];
    [self logoutFromConversationListViewController];
    
    [self loginAsTestUser:1];
    [self startConversationWithUsers:@[LSTestUser2FullName]];
    [self logoutFromConversationViewController];
    
    [self loginAsTestUser:1];
    
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
    [self logoutFromConversationListViewController];
}

//11. Send three messages to a user. Log out. Log back in with the same account. Verify that the old messages are still there in proper order.
- (void)testToVerifySentMessagePersistence
{
    [self registerTestUser:1];
    [self logoutFromConversationListViewController];
    
    [self registerTestUser:2];
    [self logoutFromConversationListViewController];
    
    [self loginAsTestUser:1];
    [self startConversationWithUsers:@[LSTestUser2FullName]];

    [self sendMessageWithText:@"Hello"];
    [self sendMessageWithText:@"This is a test message"];
    [self sendMessageWithText:@"This is another test message"];
    
    [self logoutFromConversationViewController];
    
    [self loginAsTestUser:1];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
    
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:LSTestUser1FullName]];
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test message" andUser:LSTestUser1FullName]];
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is another test message" andUser:LSTestUser1FullName]];

    [self logoutFromConversationViewController];
}

//12. Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Verify that all three conversations show up on the Conversations list with proper names displayed.
- (void)testToVerifyThreeNewConversationsAreDisplayedInconversationList
{
    [self registerTestUser:1];
    [self logoutFromConversationListViewController];

    [self registerTestUser:2];
    [self logoutFromConversationListViewController];

    [self registerTestUser:3];
    [self logoutFromConversationListViewController];

    [self loginAsTestUser:1];

    [self startConversationWithUsers:@[LSTestUser2FullName]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
    
    [self startConversationWithUsers:@[LSTestUser3FullName]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser3FullName]]];
    
    [self startConversationWithUsers:@[LSTestUser2FullName, LSTestUser3FullName]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName, LSTestUser3FullName]]];
    [self logoutFromConversationListViewController];
}

//13. Send three messages to a user. Log out. Log back in as the recipient user. Verify that the messages are there, marked as sent by the sender, in proper order.
- (void)testToVerifySuccesfullRecipetOfThreeMessages
{
    [self registerTestUser:1];
    [self logoutFromConversationListViewController];

    [self registerTestUser:2];
    [self logoutFromConversationListViewController];

    [self loginAsTestUser:1];
    [self startConversationWithUsers:@[LSTestUser2FullName]];

    [self sendMessageWithText:@"Hello"];
    [self sendMessageWithText:@"This is a test message"];
    [self sendMessageWithText:@"This is another test message"];
    
    [self logoutFromConversationViewController];

    [self loginAsTestUser:2];

    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName]]];
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName]]];

    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:LSTestUser1FullName]];
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test message" andUser:LSTestUser1FullName]];
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is another test message" andUser:LSTestUser1FullName]];
    [self logoutFromConversationViewController];
}

//14. Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Open one of the individual conversations and send three messages. Open the group chat and send one message. Log out and back in as the recipient of the three messages. Verify that two conversations are listed – one with three messages and another group chat with one message, all with the proper participants.
- (void)testToVerifyMultipleMessagesSentToMultipleRecipeientsAreReciecvedAndDisplayedForTheRecipients
{
    [self registerTestUser:1];
    [self logoutFromConversationListViewController];
    
    [self registerTestUser:2];
    [self logoutFromConversationListViewController];
    
    [self registerTestUser:3];
    [self logoutFromConversationListViewController];
    
    [self loginAsTestUser:1];
    
    [self startConversationWithUsers:@[LSTestUser2FullName]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
    
    [self startConversationWithUsers:@[LSTestUser3FullName]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser3FullName]]];
    
    [self startConversationWithUsers:@[LSTestUser2FullName, LSTestUser3FullName]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName, LSTestUser3FullName]]];
    
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
    [self sendMessageWithText:@"Hello"];
    [self sendMessageWithText:@"This is a test message"];
    [self sendMessageWithText:@"This is another test message"];
    
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];

    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName, LSTestUser3FullName]]];
    [self sendMessageWithText:@"Hello"];
    
    [self logoutFromConversationViewController];
    
    [self loginAsTestUser:2];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName]]];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName, LSTestUser3FullName]]];
    [self logoutFromConversationListViewController];
}

//15. Create three users. Log in as one of them. Send a message to one contact. Log out and in as that contact. Reply to the original message. Log out and in as the first user, and verify that the reply shows up below the originally sent message.
- (void)testToVerifySendingRecievingAndReplyingToAMessage
{
    [self registerTestUser:1];
    [self logoutFromConversationListViewController];
    
    [self registerTestUser:2];
    [self logoutFromConversationListViewController];
    
    [self registerTestUser:3];
    [self logoutFromConversationListViewController];
    
    [self loginAsTestUser:1];
    
    [self startConversationWithUsers:@[LSTestUser2FullName]];
    [self sendMessageWithText:@"Hello"];
    
    [self logoutFromConversationViewController];
    
    [self loginAsTestUser:2];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName]]];
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName]]];
    [self sendMessageWithText:@"This is a test reply message"];
    
    [self logoutFromConversationViewController];
    
    [self loginAsTestUser:1];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
    
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:LSTestUser1FullName]];
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test reply message" andUser:LSTestUser2FullName]];
    [self logoutFromConversationViewController];
}

//16. Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Open one of the individual conversations and send three messages. Tap back and verify that the latest message is displayed in the proper conversation's list item.
- (void)testToVerifyTheLatestMessageInANewConversationIsDisplayedInConversationList
{
    [self registerTestUser:1];
    [self logoutFromConversationListViewController];
    
    [self registerTestUser:2];
    [self logoutFromConversationListViewController];
    
    [self registerTestUser:3];
    [self logoutFromConversationListViewController];
    
    [self loginAsTestUser:1];
    
    [self startConversationWithUsers:@[LSTestUser2FullName]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
    
    [self startConversationWithUsers:@[LSTestUser3FullName]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser3FullName]]];
    
    [self startConversationWithUsers:@[LSTestUser2FullName, LSTestUser3FullName]];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName, LSTestUser3FullName]]];
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser3FullName]]];
    [self sendMessageWithText:@"Hello"];
    [self sendMessageWithText:@"This is a test message"];
    [self sendMessageWithText:@"This is another test message"];
    
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    //[tester waitForViewWithAccessibilityLabel:@"This is another test message"];
    [self logoutFromConversationListViewController];
    
}

//17. Push an image to a know location on the device. Create two users. Log in as one, create a conversation with the other. Tap the camera button. Verify that a photo prompt pops up with options for taking a picture or attaching an image from the filesystem. Select the filesystem option. Select the pushed photo. Verify that a photo is added to the conversation view.
- (void)testToVerifySelectingAnImageFromTheCameraRollAndSending
{
    [self registerTestUser:1];
    [self logoutFromConversationListViewController];
    
    [self registerTestUser:2];
    [self logoutFromConversationListViewController];
    
    [self loginAsTestUser:1];
    
    [self startConversationWithUsers:@[LSTestUser2FullName]];
    
    [self selectPhotoFromCameraRoll];

    [self logoutFromContactViewController];
}

//18. Push an image to a know location on the device. Create two users. Log in as one and send a photo to the other. Log in as the recipient and verify that the photo was received.
- (void)testToVerifyASentPhotoIsRecievedByTheRecipient
{
    [self registerTestUser:1];
    [self logoutFromConversationListViewController];
    
    [self registerTestUser:2];
    [self logoutFromConversationListViewController];
    
    [self loginAsTestUser:1];
    
    [self startConversationWithUsers:@[LSTestUser2FullName]];
    
    [self selectPhotoFromCameraRoll];
    [self sendPhoto];
    
    [self logoutFromConversationViewController];
    
    [self loginAsTestUser:2];
    
    [tester waitForTimeInterval:10];
    
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName]]];
    
    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForUserID:LSTestUser1FullName]];
    [self logoutFromConversationViewController];
}

//19. Push three images to known locations. Create three users. Log in as one and create a group chat with the other two. Send two text messages and one of the photos. Log in as the second user. Send another photo and two additional text messages. Log in as the third user. Verify that the prior messages are all there in the proper order from the proper senders.
- (void)testToVerifyThatPhotosAndMessagesAreAccuratelySentAndRecievedByMultipleParticipantsInAGroupChat
{
    [self registerTestUser:1];
    [self logoutFromConversationListViewController];
    
    [self registerTestUser:2];
    [self logoutFromConversationListViewController];
    
    [self registerTestUser:3];
    [self logoutFromConversationListViewController];
    
    [self loginAsTestUser:1];
    
    [self startConversationWithUsers:@[LSTestUser2FullName, LSTestUser3FullName]];
    
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
    
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName, LSTestUser3FullName]]];
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName, LSTestUser3FullName]]];
    
    [self sendMessageWithText:@"Hello"];
    [self sendMessageWithText:@"This is a test message"];
    
    [self selectPhotoFromCameraRoll];
    [self sendPhoto];
    
    [self logoutFromConversationViewController];
    
    [self loginAsTestUser:2];
    
    [tester waitForTimeInterval:10];
    
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName, LSTestUser3FullName]]];
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName, LSTestUser3FullName]]];
    
    [self selectPhotoFromCameraRoll];
    [self sendPhoto];

    [self sendMessageWithText:@"Hello"];
    [self sendMessageWithText:@"This is another test message"];
    
    [self logoutFromConversationViewController];
    
    [self loginAsTestUser:3];
    
    [tester waitForTimeInterval:10];
    
    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName, LSTestUser2FullName]]];
    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName, LSTestUser2FullName]]];
    
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:LSTestUser2FullName]];
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is another test message" andUser:LSTestUser2FullName]];
    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForUserID:LSTestUser2FullName]];
    
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:LSTestUser1FullName]];
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test message" andUser:LSTestUser1FullName]];
    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForUserID:LSTestUser1FullName]];
    [self logoutFromConversationViewController];
}

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

- (void)startConversationWithUsers:(NSArray *)users
{
    [tester tapViewWithAccessibilityLabel:@"new"];
    [tester waitForViewWithAccessibilityLabel:@"Contacts"];
    for (NSString *fullName in users) {
        [tester waitForViewWithAccessibilityLabel:fullName];
        [tester tapViewWithAccessibilityLabel:fullName];
    }
    [tester tapViewWithAccessibilityLabel:@"start"];
    [tester waitForViewWithAccessibilityLabel:@"composeView"];
    [tester waitForTimeInterval:5];
}

- (NSString *)conversationCellLabelForParticipants:(NSArray *)participantNames
{
    NSArray *sortedFullNames = [participantNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    NSString *senderLabel = @"";
<<<<<<< HEAD
    for (NSString *fullName in sortedFullNames) {
        senderLabel = [senderLabel stringByAppendingString:[NSString stringWithFormat:@"%@, ", fullName]];
=======

    LSUserManager *manager = [LSUserManager new];
    for (NSString *userID in participants) {
        if (![userID isEqualToString:[manager loggedInUser].identifier]) {
            NSString *participant = [manager userWithIdentifier:userID].fullName;
            senderLabel = [senderLabel stringByAppendingString:[NSString stringWithFormat:@"%@, ", participant]];
        }
>>>>>>> blake-MSG-187-code-review-feedback
    }
    return senderLabel;
}

#pragma mark
#pragma mark Send Message

- (void)sendMessageWithText:(NSString *)text
{
    [tester tapViewWithAccessibilityLabel:@"Compose TextView"];
    [tester waitForViewWithAccessibilityLabel:@"space"]; //Space represents that the keyboard is show, hence the focus is on the text entry box
    [tester clearTextFromAndThenEnterText:text intoViewWithAccessibilityLabel:@"Compose TextView"];
    [tester tapViewWithAccessibilityLabel:@"Send Button"];
    
<<<<<<< HEAD
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:text andUser:[[LSUserManager userInfoForUserID:[LSUserManager loggedInUserID]] objectForKey:@"fullName"]]];
=======
    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:text andUser:[[[LSUserManager new] loggedInUser].identifier intValue]]];
>>>>>>> blake-MSG-187-code-review-feedback
}

- (NSString *)messageCellLabelForText:(NSString *)text andUser:(NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ sent by %@", text, fullName];
}

- (void)selectPhotoFromCameraRoll
{
    [tester tapViewWithAccessibilityLabel:@"Cam Button"];
    [tester tapViewWithAccessibilityLabel:@"Choose Existing"];
    [tester tapViewWithAccessibilityLabel:@"Saved Photos"];
    [tester tapViewWithAccessibilityLabel:@"Photo, Portrait, 3:29 PM"];
    [tester waitForViewWithAccessibilityLabel:@"composeView"];
}

-(void)sendPhoto
{
    [tester tapViewWithAccessibilityLabel:@"Send Button"];
<<<<<<< HEAD
    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForUserID:[[LSUserManager userInfoForUserID:[LSUserManager loggedInUserID]] objectForKey:@"fullName"]]];
    [tester waitForTimeInterval:10];
=======
    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForUserID:[[[LSUserManager new] loggedInUser].identifier intValue]]];
>>>>>>> blake-MSG-187-code-review-feedback
}

- (NSString *)imageCelLabelForUserID:(NSString *)fullName
{
    return [NSString stringWithFormat:@"Photo sent by %@", fullName];
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
    [tester waitForTimeInterval:5];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester tapViewWithAccessibilityLabel:@"logout"];
    [tester waitForViewWithAccessibilityLabel:@"Home"];
}

- (void)logoutFromConversationViewController
{
    [tester waitForTimeInterval:5];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester tapViewWithAccessibilityLabel:@"logout"];
    [tester waitForViewWithAccessibilityLabel:@"Home"];
}

@end
