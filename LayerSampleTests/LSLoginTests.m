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
#import "LYRSampleConversation.h"
#import "LYRSampleMessage.h"
#import "LSNavigationController.h"
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
    
    [LSUserManager registerWithFullName:LSTestUser0FullName email:LSTestUser0Email password:LSTestUser0Password andConfirmation:LSTestUser0Confirmation];
}

- (void)afterEach
{
    //[tester returnToLoggedOutHomeScreen];
}



#pragma mark
-(void)registerTestUser:(int)userID
{
    switch (userID) {
        case 1:
            [tester tapViewWithAccessibilityLabel:@"Register"];
            [tester enterText:LSTestUser1FullName intoViewWithAccessibilityLabel:@"Fullname"];
            [tester enterText:LSTestUser1Email intoViewWithAccessibilityLabel:@"Username"];
            [tester enterText:LSTestUser1Password intoViewWithAccessibilityLabel:@"Password"];
            [tester enterText:LSTestUser1Confirmation intoViewWithAccessibilityLabel:@"Confirm"];
            [tester tapViewWithAccessibilityLabel:@"RegisterButton"];
            [tester waitForViewWithAccessibilityLabel:@"conversationList"];
            break;
        case 2:
            [tester tapViewWithAccessibilityLabel:@"Register"];
            [tester enterText:LSTestUser2FullName intoViewWithAccessibilityLabel:@"Fullname"];
            [tester enterText:LSTestUser2Email intoViewWithAccessibilityLabel:@"Username"];
            [tester enterText:LSTestUser2Password intoViewWithAccessibilityLabel:@"Password"];
            [tester enterText:LSTestUser2Confirmation intoViewWithAccessibilityLabel:@"Confirm"];
            [tester tapViewWithAccessibilityLabel:@"RegisterButton"];
            [tester waitForViewWithAccessibilityLabel:@"conversationList"];
            break;
        case 3:
            [tester tapViewWithAccessibilityLabel:@"Register"];
            [tester enterText:LSTestUser3FullName intoViewWithAccessibilityLabel:@"Fullname"];
            [tester enterText:LSTestUser3Email intoViewWithAccessibilityLabel:@"Username"];
            [tester enterText:LSTestUser3Password intoViewWithAccessibilityLabel:@"Password"];
            [tester enterText:LSTestUser3Confirmation intoViewWithAccessibilityLabel:@"Confirm"];
            [tester tapViewWithAccessibilityLabel:@"RegisterButton"];
            [tester waitForViewWithAccessibilityLabel:@"conversationList"];
            break;
        default:
            break;
    }
}

- (void)loginAsTestUser:(int)userID
{
    [tester tapViewWithAccessibilityLabel:@"Login"];
    switch (userID) {
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
    [tester tapViewWithAccessibilityLabel:@"LoginButton"];
    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
}

-(void)logout
{
    [tester tapViewWithAccessibilityLabel:@"logout"];
}

#pragma mark
#pragma mark Start Conversation
-(void)starConversationWithUserId:(NSArray *)userIDs
{
    for (NSNumber *userID in userIDs) {
        NSString *string = [NSString stringWithFormat:@"%@", userID];
        NSString *labelString = [NSString stringWithFormat:@"contactCell+%@", string];
        [tester waitForViewWithAccessibilityLabel:labelString];
        [tester tapViewWithAccessibilityLabel:labelString];
    }
    [tester tapViewWithAccessibilityLabel:@"start"];
}

#pragma mark
#pragma mark Send Message

- (void)sendMessageWithNumber:(int)number
{
    [tester tapViewWithAccessibilityLabel:@"composeTextView"];
    [tester waitForViewWithAccessibilityLabel:@"space"]; //Space represents that the keyboard is show, hence the focus is on the text entry box
    
    switch (number) {
        case 1:
            [tester enterText:@"Hello!" intoViewWithAccessibilityLabel:@"composeTextView"];
            break;
        case 2:
            [tester enterText:@"Can you hear me?!" intoViewWithAccessibilityLabel:@"composeTextView"];
            break;
        case 3:
            [tester enterText:@"What are you doing tonight?" intoViewWithAccessibilityLabel:@"composeTextView"];
            break;
        case 4:
            [tester enterText:@"I'm just hanging out" intoViewWithAccessibilityLabel:@"composeTextView"];
            break;
        case 5:
            [tester enterText:@"Thought you might want to join" intoViewWithAccessibilityLabel:@"composeTextView"];
            break;
        default:
            break;
    }
    [tester tapViewWithAccessibilityLabel:@"sendButton"];
    //TODO need to verify message was sent
}

#pragma mark
#pragma mark Logout Methods

- (void)logoutFromConversationListViewController
{
    
}

-(void)logoutFromContactViewController
{
    
}

-(void)logoutFromConversationViewController
{
    [tester tapViewWithAccessibilityLabel:@"Contacts"];
    [tester tapViewWithAccessibilityLabel:@"cancel"];
    [tester tapViewWithAccessibilityLabel:@"logout"];
}
//-(void)LoginAsDefaultTester
//{
//    [tester tapViewWithAccessibilityLabel:@"Login"];
//    [tester enterText:LSTestUser0Email intoViewWithAccessibilityLabel:@"Username"];
//    [tester enterText:LSTestUser0Password intoViewWithAccessibilityLabel:@"Password"];
//    [tester tapViewWithAccessibilityLabel:@"LoginButton"];
//}
//
////Log in with incorrect credentials and verify that an error prompt pops up.
//- (void)testToVerifyIncorrectLoginCredentialsAlert
//{
//    [tester tapViewWithAccessibilityLabel:@"Login"];
//    [tester enterText:@"fakeEmail@gmail.com" intoViewWithAccessibilityLabel:@"Username"];
//    [tester enterText:@"fakePassword" intoViewWithAccessibilityLabel:@"Password"];
//    [tester tapViewWithAccessibilityLabel:@"Login"];
//    [tester waitForViewWithAccessibilityLabel:@"Invalid Credentials"];
//}
//
////Successfully log in with good credentials.
//-(void)testToVerifySuccesfulLogin
//{
//    [self LoginAsDefaultTester];
//    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Invalid Credentials"];
//}
//
////Tap register, enter nothing, and verify that a prompt came up requesting valid info. Add a first name. Tap register and verify that a prompt requested more info. Continue adding data until success.
//-(void)testToVerifyIncompleteInfoRegistrationFunctionality
//{
//    [tester tapViewWithAccessibilityLabel:@"Register"];
//    [tester enterText:LSTestUser1FullName intoViewWithAccessibilityLabel:@"Fullname"];
//    [tester tapViewWithAccessibilityLabel:@"RegisterButton"];
//    [tester waitForViewWithAccessibilityLabel:@"No Email"];
//    [tester tapViewWithAccessibilityLabel:@"OK"];
//    [tester enterText:LSTestUser1Email intoViewWithAccessibilityLabel:@"Username"];
//    [tester tapViewWithAccessibilityLabel:@"RegisterButton"];
//    [tester waitForViewWithAccessibilityLabel:@"Password Error"];
//    [tester tapViewWithAccessibilityLabel:@"OK"];
//    [tester enterText:LSTestUser1Password intoViewWithAccessibilityLabel:@"Password"];
//    [tester tapViewWithAccessibilityLabel:@"RegisterButton"];
//    [tester waitForViewWithAccessibilityLabel:@"Password Error"];
//    [tester tapViewWithAccessibilityLabel:@"OK"];
//    [tester enterText:LSTestUser1Confirmation intoViewWithAccessibilityLabel:@"Confirm"];
//    [tester tapViewWithAccessibilityLabel:@"RegisterButton"];
//    //[tester waitForViewWithAccessibilityLabel:@"Conversation"];
//    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Email Already Exists"];
//}
//
////Tap register, enter valid info, and verify success.
//- (void)testToVerifyRegistrationFunctionality
//{
//    [self registerTestUser:1];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//}
//
////Log in. Verify the address book is empty. Log out and register as a new user. Verify that the first user is in the address book.
//- (void)testToVerifyAddressBookFunctionalityForFirstTwoUsers
//{
//    [self LoginAsDefaultTester];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//    [tester tapViewWithAccessibilityLabel:@"new"];
//    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"contactCell"];
//    [tester tapViewWithAccessibilityLabel:@"cancel"];
//    [tester tapViewWithAccessibilityLabel:@"logout"];
//    [tester waitForViewWithAccessibilityLabel:@"Register"];
//    [self registerTestUser:1];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//    [tester tapViewWithAccessibilityLabel:@"new"];
//    [tester waitForViewWithAccessibilityLabel:@"contactCell"];
//}
//
////Register two users. Log in. Tap the contact and verify that its checkbox checks. Tap it again and verify that the checkbox unchecks.
//-(void)testToVerifyAddressBookSelectionIndicatorFunctionality
//{
//    [self registerTestUser:1];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//    [tester tapViewWithAccessibilityLabel:@"logout"];
//    [self registerTestUser:1];
//    [tester waitForViewWithAccessibilityLabel:@"conversationList"];
//    [tester tapViewWithAccessibilityLabel:@"new"];
//    [tester waitForViewWithAccessibilityLabel:@"contactCell"];
//    [tester tapViewWithAccessibilityLabel:@"contactCell"];
//    [tester waitForViewWithAccessibilityLabel:@"selectionIndicator"];
//    [tester tapViewWithAccessibilityLabel:@"contactCell"];
//    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"selectionIndicator"];
//}
//
////Register two users. Log in. Tap the contact to check its checkbox. Tap the "+" to start a conversation and verify that the proper Conversation view is shown.
//-(void)testToVerifyStartingAConversationWithTwoContacts
//{
//    [self registerTestUser:1];
//    [self logout];
//  
//    [self registerTestUser:1];
//    [self logout];
//    
//    [self loginAsTestUser:1];
//    
//    [tester tapViewWithAccessibilityLabel:@"new"];
//    [tester waitForViewWithAccessibilityLabel:@"contactCell"];
//    [tester tapViewWithAccessibilityLabel:@"contactCell"];
//    [tester tapViewWithAccessibilityLabel:@"start"];
//    [tester waitForViewWithAccessibilityLabel:@"composeView"];
//}
//
////Register two users. Log in and start a conversation. Log out and back in. Verify that the old conversation is still there.
//-(void)testToVerifyConversationPersistenceFunctionality
//{
//    [self registerTestUser:1];
//    [self logout];
//    
//    [self registerTestUser:2];
//    [self logout];
//    
//    [self loginAsTestUser:1];
//}
//
////Register two users. Log in and start a conversation. Tap the back button and verify that the Contacts view returns.
//-(void)testToVerifyNavigationBetweenContactsandConversations
//{
//    [self registerTestUser:1];
//    [self logout];
//    
//    [self registerTestUser:2];
//    [self logout];
//    
//    [self loginAsTestUser:1];
//    
//    [tester tapViewWithAccessibilityLabel:@"new"];
//    [tester waitForViewWithAccessibilityLabel:@"contactCell"];
//    [tester tapViewWithAccessibilityLabel:@"back"];
//}

//Register two users. Log in as one and start a conversation. Verify that the focus is automatically set on the message entry box. Type "hello!" and verify that "hello!" appears in the entry box. Tap "send" and verify that a message with "hello!" is added to the conversation history. Send "Do you hear me?" and verify that the new message is added below the first.
//-(void)testToVerifyUIAnimimationsForSendingAMessage
//{
//    [self registerTestUser:1];
//    [self logout];
//    
//    [self registerTestUser:2];
//    [self logout];
//    
//    [self loginAsTestUser:1];
//    [tester tapViewWithAccessibilityLabel:@"new"];
//    [self starConversationWithUserId:@[[NSNumber numberWithInt:2]]];
//
//    [self sendMessageWithNumber:1];
//    [self sendMessageWithNumber:2];
//    
//    [self logoutFromConversationViewController];
//}
//
////Send three messages to a user. Log out. Log back in with the same account. Verify that the old messages are still there in proper order.
//-(void)testToVerifySentMessagePersistence
//{
//    [self registerTestUser:1];
//    [self logout];
//    
//    [self registerTestUser:2];
//    [self logout];
//    
//    [self loginAsTestUser:1];
//
//    [tester tapViewWithAccessibilityLabel:@"new"];
//    [self starConversationWithUserId:@[[NSNumber numberWithInt:2]]];
//
//    [self sendMessageWithNumber:1];
//    [self sendMessageWithNumber:2];
//    [self sendMessageWithNumber:3];
//    
//    [self logoutFromConversationViewController];
//    
//    [self loginAsTestUser:1];
//}
//
////Send three messages to a user. Log out. Log back in as the recipient user. Verify that the messages are there, marked as sent by the sender, in proper order.
//-(void)testToVerifySuccesfullRecipetOfThreeMessages
//{
//    [self registerTestUser:1];
//    [self logout];
//    
//    [self registerTestUser:2];
//    [self logout];
//    
//    [self loginAsTestUser:1];

//    [tester tapViewWithAccessibilityLabel:@"new"];
//    [self starConversationWithUserId:@[[NSNumber numberWithInt:2]]];
//    
//    [self sendMessageWithNumber:1];
//    [self sendMessageWithNumber:2];
//    [self sendMessageWithNumber:3];
//    
//    [self logoutFromConversationViewController];
//    
//    [self loginAsTestUser:2];
//    //Verify that you have 3 messages
//}

//Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Verify that all three conversations show up on the Conversations list with proper names displayed.
-(void)testToVerifyThreeNewConversationsAreDisplayedInconversationList
{
    [self registerTestUser:1];
    [self logout];
    
    [self registerTestUser:2];
    [self logout];
    
    [self registerTestUser:3];
    [self logout];
    
    [self loginAsTestUser:1];
   
    [tester tapViewWithAccessibilityLabel:@"new"];
    
    [self starConversationWithUserId:@[[NSNumber numberWithInt:2]]];
    [tester tapViewWithAccessibilityLabel:@"Contacts"];
    
    [self starConversationWithUserId:@[[NSNumber numberWithInt:3]]];
    [tester tapViewWithAccessibilityLabel:@"Contacts"];
    
    [self starConversationWithUserId:@[[NSNumber numberWithInt:2], [NSNumber numberWithInt:3]]];
    [tester tapViewWithAccessibilityLabel:@"Contacts"];
}

//Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Open one of the individual conversations and send three messages. Tap back and verify that the latest message is displayed in the proper conversation's list item.
-(void)testToVerifyTheLatestMessageInANewConversationIsDisplayedInConversationList
{
    [self registerTestUser:1];
    [self logout];
    
    [self registerTestUser:2];
    [self logout];
    
    [self registerTestUser:3];
    [self logout];
    
    [self loginAsTestUser:1];
    
    [self starConversationWithUserId:@[[NSNumber numberWithInt:2]]];
    [tester tapViewWithAccessibilityLabel:@"Contacts"];
    
    [self starConversationWithUserId:@[[NSNumber numberWithInt:3]]];
    [tester tapViewWithAccessibilityLabel:@"Contacts"];
    
    [self starConversationWithUserId:@[[NSNumber numberWithInt:2], [NSNumber numberWithInt:3]]];
    [tester tapViewWithAccessibilityLabel:@"Contacts"];
    
    
}

//Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Open one of the individual conversations and send three messages. Open the group chat and send one message. Log out and back in as the recipient of the three messages. Verify that two conversations are listed – one with three messages and another group chat with one message, all with the proper participants.
-(void)testToVerifyMultipleMessagesSentToMultipleRecipeientsAreReciecvedAndDisplayedForTheRecipients
{
    [self registerTestUser:1];
    [self logout];
    
    [self registerTestUser:2];
    [self logout];
    
    [self registerTestUser:3];
    [self logout];
    
    [self loginAsTestUser:1];
    
    [self starConversationWithUserId:@[[NSNumber numberWithInt:2]]];
    [tester tapViewWithAccessibilityLabel:@"Contacts"];
    
    [self starConversationWithUserId:@[[NSNumber numberWithInt:3]]];
    [tester tapViewWithAccessibilityLabel:@"Contacts"];
    
    [self starConversationWithUserId:@[[NSNumber numberWithInt:2], [NSNumber numberWithInt:3]]];
    [tester tapViewWithAccessibilityLabel:@"Contacts"];
    
}
//Create three users. Log in as one of them. Send a message to one contact. Log out and in as that contact. Reply to the original message. Log out and in as the first user, and verify that the reply shows up below the originally sent message.
-(void)testToVerifySendingRecievingAndReplyingToAMessage
{
    [self registerTestUser:1];
    [self logout];
    
    [self registerTestUser:2];
    [self logout];
    
    [self registerTestUser:3];
    [self logout];
    
    [self loginAsTestUser:1];
    
    [self starConversationWithUserId:@[[NSNumber numberWithInt:2]]];
    [tester tapViewWithAccessibilityLabel:@"Contacts"];
    
    [self logoutFromContactViewController];
    
    [self loginAsTestUser:2];
}

//Push an image to a know location on the device. Create two users. Log in as one, create a conversation with the other. Tap the camera button. Verify that a photo prompt pops up with options for taking a picture or attaching an image from the filesystem. Select the filesystem option. Select the pushed photo. Verify that a photo is added to the conversation view.
-(void)testToVerifySelectingAnImageFromTheCameraRollAndSending
{
    
}

//Push an image to a know location on the device. Create two users. Log in as one and send a photo to the other. Log in as the recipient and verify that the photo was received.
-(void)testToVerifyASentPhotoIsRecievedByTheRecipient
{
    
}

//Push three images to known locations. Create three users. Log in as one and create a group chat with the other two. Send two text messages and one of the photos. Log in as the second user. Send another photo and two additional text messages. Log in as the third user. Verify that the prior messages are all there in the proper order from the proper senders.
-(void)testToVerifyThatPhotosAndMessagesAreAccuratelySentAndRecievedByMultipleParticipantsInAGroupChat
{
    
}


//======== OLD TESTS =========//

//- (void)testToVerifySendButtonFunctionality
//{
//    [system presentViewControllerWithClass:[LSConversationViewController class] withinNavigationControllerWithNavigationBarClass:nil toolbarClass:nil configurationBlock:^(id viewController) {
//
//    }];
//    [tester tapViewWithAccessibilityLabel:@"Compose TextView"];
//    [tester waitForViewWithAccessibilityLabel:@"E"];
//    [tester enterText:@"This is a test!" intoViewWithAccessibilityLabel:@"Compose TextView"];
//    [tester tapViewWithAccessibilityLabel:@"Button"];
//}
//
//- (void)testToVerifyTappingOnConversationCellFunctionality
//{
//    [system presentViewControllerWithClass:[LSConversationListViewController class] withinNavigationControllerWithNavigationBarClass:nil toolbarClass:nil configurationBlock:^(id viewController) {
//
//    }];
//    [tester tapViewWithAccessibilityLabel:@"Conversation Cell"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversation List"];
//}
//
//- (void) testNonMatchingPasswordRegistrationError
//{
//    [system presentViewControllerWithClass:[LSRegistrationTableViewController class] withinNavigationControllerWithNavigationBarClass:nil toolbarClass:nil configurationBlock:^(id viewController) {
//
//    }];
//    [tester enterText:@"tester@layer.com" intoViewWithAccessibilityLabel:@"Username"];
//    [tester enterText:@"password" intoViewWithAccessibilityLabel:@"Password"];
//    [tester enterText:@"password1" intoViewWithAccessibilityLabel:@"Confirm"];
//    [tester tapViewWithAccessibilityLabel:@"Register"];
//}
//
//- (void) testRegistrationFunctionality
//{
//    [system presentViewControllerWithClass:[LSRegistrationTableViewController class] withinNavigationControllerWithNavigationBarClass:nil toolbarClass:nil configurationBlock:^(id viewController) {
//
//    }];
//    [tester enterText:@"tester@layer.com" intoViewWithAccessibilityLabel:@"Username"];
//    [tester enterText:@"password" intoViewWithAccessibilityLabel:@"Password"];
//    [tester enterText:@"password" intoViewWithAccessibilityLabel:@"Confirm"];
//    [tester tapViewWithAccessibilityLabel:@"Register"];
//
//    [tester waitForViewWithAccessibilityLabel:@"Sender Label"];
//}
//
//- (void) testLoginFunctionality
//{
//    [system presentViewControllerWithClass:[LSLoginTableViewController class] withinNavigationControllerWithNavigationBarClass:nil toolbarClass:nil configurationBlock:^(id viewController) {
//
//    }];
//    [tester enterText:@"tester@layer.com" intoViewWithAccessibilityLabel:@"Username"];
//    [tester enterText:@"Password" intoViewWithAccessibilityLabel:@"Password"];
//    [tester tapViewWithAccessibilityLabel:@"Login"];
//    [tester waitForViewWithAccessibilityLabel:@"Sender Label"];
//}
//
//- (void)testRegisterButton
//{
//    [system presentViewControllerWithClass:[LSHomeViewController class] withinNavigationControllerWithNavigationBarClass:nil toolbarClass:nil configurationBlock:^(id viewController) {
//
//    }];
//    [tester tapViewWithAccessibilityLabel:@"Register"];
//    [tester waitForTappableViewWithAccessibilityLabel:@"Username"];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//}
//
//- (void)testLoginButton
//{
//    [system presentViewControllerWithClass:[LSHomeViewController class] withinNavigationControllerWithNavigationBarClass:nil toolbarClass:nil configurationBlock:^(id viewController) {
//
//    }];
//    [tester tapViewWithAccessibilityLabel:@"Login"];
//    [tester waitForTappableViewWithAccessibilityLabel:@"Username"];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//}

@end
