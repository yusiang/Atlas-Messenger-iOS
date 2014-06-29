//
//  LSLoginTests.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/11/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSLoginTests.h"
#import "KIFUITestActor+LSAdditions.h"
#import "LSRegistrationViewController.h"
#import "LSLoginViewController.h"
#import "LSConversationListViewController.h"
#import "LSConversationViewController.h"
#import "LSAuthenticationViewController.h"
#import "LSUser.h"
#import "LYRLog.h"
#import "LYRCountdownLatch.h"
#import "LSPersistenceManager.h"

static NSString *const LSTestUser0FirstName = @"Layer";
static NSString *const LSTestUser0LastName = @"Tester0";
static NSString *const LSTestUser0Email = @"tester0@layer.com";
static NSString *const LSTestUser0Password = @"password0";
static NSString *const LSTestUser0Confirmation = @"password0";

static NSString *const LSTestUser1FirstName = @"Layer";
static NSString *const LSTestUser1LastName = @"Tester1";
static NSString *const LSTestUser1Email = @"tester1@layer.com";
static NSString *const LSTestUser1Password = @"password1";
static NSString *const LSTestUser1Confirmation = @"password1";

static NSString *const LSTestUser2FirstName = @"Layer";
static NSString *const LSTestUser2LastName = @"Tester2";
static NSString *const LSTestUser2Email = @"tester2@layer.com";
static NSString *const LSTestUser2Password = @"password2";
static NSString *const LSTestUser2Confirmation = @"password2";

static NSString *const LSTestUser3FirstName = @"Layer";
static NSString *const LSTestUser3LastName = @"Tester3";
static NSString *const LSTestUser3Email = @"tester3@layer.com";
static NSString *const LSTestUser3Password = @"password3";
static NSString *const LSTestUser3Confirmation = @"password3";

@interface LYRClient ()

- (id)initWithBaseURL:(NSURL *)baseURL appID:(NSUUID *)appID;

@end

@interface LSLoginTests ()

@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) LSAPIManager *APIManager;

@end

@implementation LSLoginTests

/**
 If you are going to use user defaults as a data store, you'd be better off by putting a `reset` method on the `LSUserManager` interface that only deletes specific
 keys used for user management. Otherwise this approach could blow out keys stored by another part of the system and it requires refactoring your tests if you change
 data store implementations in the future.
 */


/**
 SBW: you never want to use `andWhatever` in an Objective-C method signature unless the method actually take two actions. For example, if you had an object
 that acted as indexed collection, you might have methods like `addObject:` and `reindex`. You may then want to add a new method that adds the objects from
 another collection and reindexes: `addObjectsFromArrayAndReindex:foo`. But if you wanted to parameterize it, you'd go with `addObjectsFromArray:array reindex:NO`.
 This is a very uncommon signature idiom. Try searching the Cocoa headers for the word `And` in method signatures. It rarely appears and typically only in very old
 API's such as `NSBundle`.
 */
- (LSUser *)testUserWithNumber:(NSUInteger)number
{
    LSUser *user = [[LSUser alloc] init];
    switch (number) {
        case 0:
            [user setFirstName:LSTestUser0FirstName];
            [user setLastName:LSTestUser0LastName];
            [user setEmail:LSTestUser0Email];
            [user setPassword:LSTestUser0Password];
            [user setPasswordConfirmation:LSTestUser0Confirmation];
            break;
        case 1:
            [user setFirstName:LSTestUser1FirstName];
            [user setLastName:LSTestUser1LastName];
            [user setEmail:LSTestUser1Email];
            [user setPassword:LSTestUser1Password];
            [user setPasswordConfirmation:LSTestUser1Confirmation];
            break;
        case 2:
            [user setFirstName:LSTestUser2FirstName];
            [user setLastName:LSTestUser2LastName];
            [user setEmail:LSTestUser2Email];
            [user setPassword:LSTestUser2Password];;
            [user setPasswordConfirmation:LSTestUser2Confirmation];
            break;
        case 3:
            [user setFirstName:LSTestUser3FirstName];
            [user setLastName:LSTestUser3LastName];
            [user setEmail:LSTestUser3Email];
            [user setPassword:LSTestUser3Password];
            [user setPasswordConfirmation:LSTestUser3Confirmation];
            break;
        default:
            break;
    }
    return user;
}

- (void)beforeEach
{
    LSPersistenceManager *manager = [LSPersistenceManager persistenceManagerWithInMemoryStore];
    [manager deleteAllObjects];
    
    NSURL *baseURL = [NSURL URLWithString:@"https://10.66.0.35:7072"];
    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-1000-8000-000000000000"];
    self.layerClient = [[LYRClient alloc] initWithBaseURL:baseURL appID:appID];
    
    [self.layerClient startWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"Started with success: %d, %@", success, error);
    }];
    
    [tester waitForTimeInterval:2];
    
    self.APIManager = [LSAPIManager managerWithBaseURL:[NSURL URLWithString:@"http://10.66.0.35:8080/"] layerClient:self.layerClient];
    
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:5.0];
    [self.APIManager registerUser:[self testUserWithNumber:0] completion:^(LSUser *user, NSError *error) {
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (void)afterEach
{
    
}
//
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
//    [self registerTestUser:[self testUserWithNumber:0]];
//    [self logoutFromConversationListViewController];
//}
//
////3. Successfully log in with good credentials.
//- (void)testToVerifySuccesfulLogin
//{
//    [self loginAsTestUser:[self testUserWithNumber:0]];
//    [self logoutFromConversationListViewController];
//}
//
////4. Tap register, enter nothing, and verify that a prompt came up requesting valid info. Add a first name. Tap register and verify that a prompt requested more info. Continue adding data until success.
//- (void)testToVerifyIncompleteInfoRegistrationFunctionality
//{
//    LSUser *testUser = [self testUserWithNumber:0];
//    [tester tapViewWithAccessibilityLabel:@"Register Button"];
//    
//    [tester enterText:testUser.firstName intoViewWithAccessibilityLabel:@"First Name"];
//    [tester tapViewWithAccessibilityLabel:@"Register Button"];
//    [tester waitForViewWithAccessibilityLabel:@"No Email"];
//    [tester tapViewWithAccessibilityLabel:@"OK"];
//    
//    [tester enterText:testUser.lastName intoViewWithAccessibilityLabel:@"Last Name"];
//    [tester tapViewWithAccessibilityLabel:@"Register Button"];
//    [tester waitForViewWithAccessibilityLabel:@"No Email"];
//    [tester tapViewWithAccessibilityLabel:@"OK"];
//    
//    [tester enterText:testUser.email intoViewWithAccessibilityLabel:@"Email"];
//    [tester tapViewWithAccessibilityLabel:@"Register Button"];
//    [tester waitForViewWithAccessibilityLabel:@"Password Error"];
//    [tester tapViewWithAccessibilityLabel:@"OK"];
//    
//    [tester enterText:testUser.password intoViewWithAccessibilityLabel:@"Password"];
//    [tester tapViewWithAccessibilityLabel:@"Register Button"];
//    [tester waitForViewWithAccessibilityLabel:@"Password Error"];
//    [tester tapViewWithAccessibilityLabel:@"OK"];
//    
//    [tester enterText:testUser.passwordConfirmation intoViewWithAccessibilityLabel:@"Confirmation"];
//    [tester tapViewWithAccessibilityLabel:@"Register Button"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [self logoutFromConversationListViewController];
//}

//5. Log in. Verify the address book is empty. Log out and register as a new user. Verify that the first user is in the address book.
- (void)testToVerifyAddressBookFunctionalityForFirstTwoUsers
{
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:3 timeoutInterval:5.0];
    
    [self systemLoginUser:[self testUserWithNumber:0]];
    [tester tapViewWithAccessibilityLabel:@"New"];
    //TODO change to wait for view with out this label
    [tester waitForViewWithAccessibilityLabel:@"Contact List"];
    
    [self.APIManager deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        [latch decrementCount];
    }];
    [latch waitTilCount:2];
    
    [self systemLoginUser:[self testUserWithNumber:1]];
    [tester tapViewWithAccessibilityLabel:@"new"];
    [tester waitForViewWithAccessibilityLabel:[self testUserWithNumber:0].fullName];

    [self.APIManager deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

////6. Register two users. Log in. Tap the contact and verify that its checkbox checks. Tap it again and verify that the checkbox unchecks.
//-(void)testToVerifyAddressBookSelectionIndicatorFunctionality
//{
//    [self registerTestUser:[self testUserWithNumber:1]];
//    [self logoutFromConversationListViewController];
//    [self registerTestUser:[self testUserWithNumber:2]];
//    [self logoutFromConversationListViewController];
//    
//    [self loginAsTestUser:[self testUserWithNumber:1]];
//    [tester tapViewWithAccessibilityLabel:@"new"];
//    [tester waitForViewWithAccessibilityLabel:[self testUserWithNumber:2].fullName];
//    [tester tapViewWithAccessibilityLabel:[self testUserWithNumber:2].fullName];
//    
//    [tester waitForViewWithAccessibilityLabel:@"selectionIndicator"];
//    [tester tapViewWithAccessibilityLabel:[self testUserWithNumber:2].fullName];
//    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"selectionIndicator"];
//    [self logoutFromContactViewController];
//}
//
////7. Register two users. Log in. Tap the contact to check its checkbox. Tap the "+" to start a conversation and verify that the proper Conversation view is shown.
//-(void)testToVerifyStartingAConversationWithTwoContacts
//{
//    [self registerTestUser:[self testUserWithNumber:1]];
//    [self logoutFromConversationListViewController];
//  
//    [self registerTestUser:[self testUserWithNumber:1]];
//    [self logoutFromConversationListViewController];
//    
//    [self loginAsTestUser:1];
//
//    [self startConversationWithUsers:@[LSTestUser2FullName]];
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
//    [self startConversationWithUsers:@[LSTestUser2FullName]];
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
//    [self startConversationWithUsers:@[LSTestUser2FullName]];
//    
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    
//    [self logoutFromConversationViewController];
//}
////
////10. Register two users. Log in and start a conversation. Log out and back in. Verify that the old conversation is still there.
//-(void)testToVerifyConversationPersistenceFunctionality
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//
//    [self registerTestUser:2];
//    [self logoutFromConversationListViewController];
//    
//    [self loginAsTestUser:1];
//    [self startConversationWithUsers:@[LSTestUser2FullName]];
//    [self logoutFromConversationViewController];
//    
//    [self loginAsTestUser:1];
//    
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
//    [self logoutFromConversationListViewController];
//}
//
////11. Send three messages to a user. Log out. Log back in with the same account. Verify that the old messages are still there in proper order.
//- (void)testToVerifySentMessagePersistence
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//    
//    [self registerTestUser:2];
//    [self logoutFromConversationListViewController];
//    
//    [self loginAsTestUser:1];
//    [self startConversationWithUsers:@[LSTestUser2FullName]];
//
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    [self sendMessageWithText:@"This is another test message"];
//    
//    [self logoutFromConversationViewController];
//    
//    [self loginAsTestUser:1];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
//    
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:LSTestUser1FullName]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test message" andUser:LSTestUser1FullName]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is another test message" andUser:LSTestUser1FullName]];
//
//    [self logoutFromConversationViewController];
//}
//
////12. Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Verify that all three conversations show up on the Conversations list with proper names displayed.
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
//    [self startConversationWithUsers:@[LSTestUser2FullName]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
//    
//    [self startConversationWithUsers:@[LSTestUser3FullName]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser3FullName]]];
//    
//    [self startConversationWithUsers:@[LSTestUser2FullName, LSTestUser3FullName]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName, LSTestUser3FullName]]];
//    [self logoutFromConversationListViewController];
//}
//
////13. Send three messages to a user. Log out. Log back in as the recipient user. Verify that the messages are there, marked as sent by the sender, in proper order.
//- (void)testToVerifySuccesfullRecipetOfThreeMessages
//{
//    [self registerTestUser:1];
//    [self logoutFromConversationListViewController];
//
//    [self registerTestUser:2];
//    [self logoutFromConversationListViewController];
//
//    [self loginAsTestUser:1];
//    [self startConversationWithUsers:@[LSTestUser2FullName]];
//
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    [self sendMessageWithText:@"This is another test message"];
//    
//    [self logoutFromConversationViewController];
//
//    [self loginAsTestUser:2];
//
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName]]];
//
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:LSTestUser1FullName]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test message" andUser:LSTestUser1FullName]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is another test message" andUser:LSTestUser1FullName]];
//    [self logoutFromConversationViewController];
//}
//
////14. Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Open one of the individual conversations and send three messages. Open the group chat and send one message. Log out and back in as the recipient of the three messages. Verify that two conversations are listed – one with three messages and another group chat with one message, all with the proper participants.
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
//    [self startConversationWithUsers:@[LSTestUser2FullName]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
//    
//    [self startConversationWithUsers:@[LSTestUser3FullName]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser3FullName]]];
//    
//    [self startConversationWithUsers:@[LSTestUser2FullName, LSTestUser3FullName]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName, LSTestUser3FullName]]];
//    
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    [self sendMessageWithText:@"This is another test message"];
//    
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName, LSTestUser3FullName]]];
//    [self sendMessageWithText:@"Hello"];
//    
//    [self logoutFromConversationViewController];
//    
//    [self loginAsTestUser:2];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName]]];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName, LSTestUser3FullName]]];
//    [self logoutFromConversationListViewController];
//}
//
////15. Create three users. Log in as one of them. Send a message to one contact. Log out and in as that contact. Reply to the original message. Log out and in as the first user, and verify that the reply shows up below the originally sent message.
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
//    [self startConversationWithUsers:@[LSTestUser2FullName]];
//    [self sendMessageWithText:@"Hello"];
//    
//    [self logoutFromConversationViewController];
//    
//    [self loginAsTestUser:2];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName]]];
//    [self sendMessageWithText:@"This is a test reply message"];
//    
//    [self logoutFromConversationViewController];
//    
//    [self loginAsTestUser:1];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
//    
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:LSTestUser1FullName]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test reply message" andUser:LSTestUser2FullName]];
//    [self logoutFromConversationViewController];
//}
//
////16. Create three users. Log in as one of them. Start individual conversations with each contact and with both together. Open one of the individual conversations and send three messages. Tap back and verify that the latest message is displayed in the proper conversation's list item.
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
//    [self startConversationWithUsers:@[LSTestUser2FullName]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName]]];
//    
//    [self startConversationWithUsers:@[LSTestUser3FullName]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser3FullName]]];
//    
//    [self startConversationWithUsers:@[LSTestUser2FullName, LSTestUser3FullName]];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName, LSTestUser3FullName]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser3FullName]]];
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    [self sendMessageWithText:@"This is another test message"];
//    
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    //[tester waitForViewWithAccessibilityLabel:@"This is another test message"];
//    [self logoutFromConversationListViewController];
//    
//}
//
////17. Push an image to a know location on the device. Create two users. Log in as one, create a conversation with the other. Tap the camera button. Verify that a photo prompt pops up with options for taking a picture or attaching an image from the filesystem. Select the filesystem option. Select the pushed photo. Verify that a photo is added to the conversation view.
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
//    [self startConversationWithUsers:@[LSTestUser2FullName]];
//    
//    [self selectPhotoFromCameraRoll];
//
//    [self logoutFromContactViewController];
//}
//
////18. Push an image to a know location on the device. Create two users. Log in as one and send a photo to the other. Log in as the recipient and verify that the photo was received.
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
//    [self startConversationWithUsers:@[LSTestUser2FullName]];
//    
//    [self selectPhotoFromCameraRoll];
//    [self sendPhoto];
//    
//    [self logoutFromConversationViewController];
//    
//    [self loginAsTestUser:2];
//    
//    [tester waitForTimeInterval:10];
//    
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName]]];
//    
//    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForUserID:LSTestUser1FullName]];
//    [self logoutFromConversationViewController];
//}
//
////19. Push three images to known locations. Create three users. Log in as one and create a group chat with the other two. Send two text messages and one of the photos. Log in as the second user. Send another photo and two additional text messages. Log in as the third user. Verify that the prior messages are all there in the proper order from the proper senders.
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
//    [self startConversationWithUsers:@[LSTestUser2FullName, LSTestUser3FullName]];
//    
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
//    
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName, LSTestUser3FullName]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser2FullName, LSTestUser3FullName]]];
//    
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is a test message"];
//    
//    [self selectPhotoFromCameraRoll];
//    [self sendPhoto];
//    
//    [self logoutFromConversationViewController];
//    
//    [self loginAsTestUser:2];
//    
//    [tester waitForTimeInterval:10];
//    
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName, LSTestUser3FullName]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName, LSTestUser3FullName]]];
//    
//    [self selectPhotoFromCameraRoll];
//    [self sendPhoto];
//
//    [self sendMessageWithText:@"Hello"];
//    [self sendMessageWithText:@"This is another test message"];
//    
//    [self logoutFromConversationViewController];
//    
//    [self loginAsTestUser:3];
//    
//    [tester waitForTimeInterval:10];
//    
//    [tester waitForViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName, LSTestUser2FullName]]];
//    [tester tapViewWithAccessibilityLabel:[self conversationCellLabelForParticipants:@[LSTestUser1FullName, LSTestUser2FullName]]];
//    
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:LSTestUser2FullName]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is another test message" andUser:LSTestUser2FullName]];
//    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForUserID:LSTestUser2FullName]];
//    
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"Hello" andUser:LSTestUser1FullName]];
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:@"This is a test message" andUser:LSTestUser1FullName]];
//    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForUserID:LSTestUser1FullName]];
//    [self logoutFromConversationViewController];
//}

//======== Factory Methods =========//

#pragma mark
#pragma mark Test User Registration and Login Methods
- (void)registerTestUser:(LSUser *)testUser
{
    [tester tapViewWithAccessibilityLabel:@"Register Button"];
    [tester enterText:testUser.firstName intoViewWithAccessibilityLabel:@"Fisrt Name"];
    [tester enterText:testUser.lastName intoViewWithAccessibilityLabel:@"Last Name"];
    [tester enterText:testUser.email intoViewWithAccessibilityLabel:@"Email"];
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:@"Password"];
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:@"Confirmation"];
    [tester tapViewWithAccessibilityLabel:@"Register Button"];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
}

- (void)loginAsTestUser:(LSUser *)testUser
{
    [tester tapViewWithAccessibilityLabel:@"Login Button"];
    [tester enterText:testUser.email intoViewWithAccessibilityLabel:@"Email"];
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:@"Password"];
    [tester tapViewWithAccessibilityLabel:@"Login Button"];
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
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:5.0];
    [self.APIManager authenticateWithEmail:[self testUserWithNumber:0].email password:[self testUserWithNumber:0].password completion:^(LSUser *user, NSError *error) {
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
    [tester waitForViewWithAccessibilityLabel:@"Conversations"];
}

//- (void)logout
//{
//    [tester tapViewWithAccessibilityLabel:@"logout"];
//}
//
//#pragma mark
//#pragma mark Start Conversation
//
//- (void)startConversationWithUsers:(NSArray *)users
//{
//    [tester tapViewWithAccessibilityLabel:@"new"];
//    [tester waitForViewWithAccessibilityLabel:@"Contacts"];
//    for (NSString *fullName in users) {
//        [tester waitForViewWithAccessibilityLabel:fullName];
//        [tester tapViewWithAccessibilityLabel:fullName];
//    }
//    [tester tapViewWithAccessibilityLabel:@"start"];
//    [tester waitForViewWithAccessibilityLabel:@"composeView"];
//    [tester waitForTimeInterval:5];
//}
//
//- (NSString *)conversationCellLabelForParticipants:(NSArray *)participantNames
//{
//    NSArray *sortedFullNames = [participantNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//
//    NSString *senderLabel = @"";
//<<<<<<< HEAD
//    for (NSString *fullName in sortedFullNames) {
//        senderLabel = [senderLabel stringByAppendingString:[NSString stringWithFormat:@"%@, ", fullName]];
//=======
//
//    LSUserManager *manager = [LSUserManager new];
//    for (NSString *userID in participants) {
//        if (![userID isEqualToString:[manager loggedInUser].identifier]) {
//            NSString *participant = [manager userWithIdentifier:userID].fullName;
//            senderLabel = [senderLabel stringByAppendingString:[NSString stringWithFormat:@"%@, ", participant]];
//        }
//>>>>>>> blake-MSG-187-code-review-feedback
//    }
//    return senderLabel;
//}
//
//#pragma mark
//#pragma mark Send Message
//
//- (void)sendMessageWithText:(NSString *)text
//{
//    [tester tapViewWithAccessibilityLabel:@"Compose TextView"];
//    [tester waitForViewWithAccessibilityLabel:@"space"]; //Space represents that the keyboard is show, hence the focus is on the text entry box
//    [tester clearTextFromAndThenEnterText:text intoViewWithAccessibilityLabel:@"Compose TextView"];
//    [tester tapViewWithAccessibilityLabel:@"Send Button"];
//    
//<<<<<<< HEAD
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:text andUser:[[LSUserManager userInfoForUserID:[LSUserManager loggedInUserID]] objectForKey:@"fullName"]]];
//=======
//    [tester waitForViewWithAccessibilityLabel:[self messageCellLabelForText:text andUser:[[[LSUserManager new] loggedInUser].identifier intValue]]];
//>>>>>>> blake-MSG-187-code-review-feedback
//}
//
//- (NSString *)messageCellLabelForText:(NSString *)text andUser:(NSString *)fullName
//{
//    return [NSString stringWithFormat:@"%@ sent by %@", text, fullName];
//}
//
//- (void)selectPhotoFromCameraRoll
//{
//    [tester tapViewWithAccessibilityLabel:@"Cam Button"];
//    [tester tapViewWithAccessibilityLabel:@"Choose Existing"];
//    [tester tapViewWithAccessibilityLabel:@"Saved Photos"];
//    [tester tapViewWithAccessibilityLabel:@"Photo, Portrait, 3:29 PM"];
//    [tester waitForViewWithAccessibilityLabel:@"composeView"];
//}
//
//-(void)sendPhoto
//{
//    [tester tapViewWithAccessibilityLabel:@"Send Button"];
//    [tester waitForViewWithAccessibilityLabel:[self imageCelLabelForUserID:[[[LSUserManager new] loggedInUser].identifier intValue]]];
//    [tester waitForTimeInterval:10];
//    
//}
//
//- (NSString *)imageCelLabelForUserID:(NSString *)fullName
//{
//    return [NSString stringWithFormat:@"Photo sent by %@", fullName];
//}
//
//#pragma mark
//#pragma mark Logout Methods
//
//- (void)logoutFromConversationListViewController
//{
//    [tester tapViewWithAccessibilityLabel:@"logout"];
//    [tester waitForViewWithAccessibilityLabel:@"Home"];
//}
//
//- (void)logoutFromContactViewController
//{
//    [tester waitForTimeInterval:5];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester tapViewWithAccessibilityLabel:@"logout"];
//    [tester waitForViewWithAccessibilityLabel:@"Home"];
//}
//
//- (void)logoutFromConversationViewController
//{
//    [tester waitForTimeInterval:5];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [tester tapViewWithAccessibilityLabel:@"logout"];
//    [tester waitForViewWithAccessibilityLabel:@"Home"];
//}

@end
