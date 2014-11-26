//
//  LSUIConversationViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSUIConversationViewController.h"
#import "LSConversationDetailViewController.h"
#import "LYRUIMessagingUtilities.h"
#import "LSUIParticipantPickerDataSource.h"
#import "LYRUIParticipantPickerController.h"
#import "LSMessageDetailTableViewController.h"

static NSDateFormatter *LYRUIConversationDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMM dd, hh:mma";
    }
    return dateFormatter;
}

@interface LSUIConversationViewController () <LSConversationDetailViewControllerDelegate, LSConversationDetailViewControllerDataSource, LYRUIAddressBarControllerDataSource, LYRUIParticipantPickerControllerDelegate>

@property (nonatomic) LSUIParticipantPickerDataSource *participantPickerDataSource;

@end

@implementation LSUIConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    
    self.participantPickerDataSource = [LSUIParticipantPickerDataSource participantPickerDataSourceWithPersistenceManager:self.applicationContoller.persistenceManager];
    self.participantPickerDataSource.excludedIdentifiers = self.conversation.participants;
    
    if (self.conversation) {
        [self addDetailsButton];
    }
    [self markAllMessagesAsRead];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.addressBarController.dataSource = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Conversation View Controller Data Source

/**
 
 LAYER UI KIT - Returns an object conforming to the `LYRUIParticipant` protocol.
 
 */
- (id<LYRUIParticipant>)conversationViewController:(LYRUIConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier
{
    if (participantIdentifier) {
        NSSet *set = [self.applicationContoller.persistenceManager participantsForIdentifiers:[NSSet setWithObject:participantIdentifier]];
        return [[set allObjects] firstObject];
    }
    return nil;
}

/**
 
 LAYER UI KIT - Returns an `NSAttributedString` object for given date. The format of this string can be configured to
 whatever format your application wishes to display.
 
 */
- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date
{
    NSString *dateString;
    if (date) {
        dateString = [LYRUIConversationDateFormatter() stringFromDate:date];
    } else {
        dateString = [LYRUIConversationDateFormatter() stringFromDate:[NSDate date]];
    }
    
    NSMutableAttributedString *dateAttributedString = [[NSMutableAttributedString alloc] initWithString:dateString];
    NSRange range = [dateString rangeOfString:@","];
    NSRange boldedRange = NSMakeRange(0, range.location);
    [dateAttributedString beginEditing];
    
    [dateAttributedString addAttribute:NSFontAttributeName
                       value:[UIFont boldSystemFontOfSize:12]
                       range:boldedRange];
    
    [dateAttributedString endEditing];
    return dateAttributedString;
}

/**
 
 LAYER UI KIT - Returns an `NSAttributedString` object for given recipient state. The state string will only be displayed
 below the latest message that was sent by the currently authenticated user.
 
 */
- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus
{
    NSMutableArray *recipients = [[recipientStatus allKeys] mutableCopy];
    [recipients removeObject:self.applicationContoller.layerClient.authenticatedUserID];
    
    NSAttributedString *attributedString;
    NSInteger status = [[recipientStatus valueForKey:[recipients lastObject]] integerValue];
    switch (status) {
        case LYRRecipientStatusInvalid:
            attributedString = [[NSAttributedString alloc] initWithString:@"Not Sent"];
            break;
            
        case LYRRecipientStatusSent:
            attributedString = [[NSAttributedString alloc] initWithString:@"Sent"];
            break;
            
        case LYRRecipientStatusDelivered:
            attributedString = [[NSAttributedString alloc] initWithString:@"Delivered"];
            break;
            
        case LYRRecipientStatusRead:
            attributedString = [[NSAttributedString alloc] initWithString:@"Read"];
            break;
            
        default:
            break;
    }
    return attributedString;
}

/**
 
 LAYER UI KIT - Returns an `NSString` object that will be displayed as the push notification test for the given message.
 If no string is returned, Layer will not deliver a text based push notification.
 
 */
- (NSString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController pushNotificationTextForMessage:(LYRMessage *)message
{
    if (!self.applicationContoller.shouldSendPushText) return nil;
    LYRMessagePart *messagePart = [message.parts objectAtIndex:0];
    NSString *pushText = [NSString new];
    if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeTextPlain]) {
        pushText = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG] || [messagePart.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG]) {
        pushText = @"Has sent a new image";
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeLocation]) {
        pushText = @"Has sent a new location";
    }
    return pushText;
}

/**
 
 LAYER UI KIT - If your application would like to mark messages as read, return YES.
 
 */
- (BOOL)conversationViewController:(LYRUIConversationViewController *)conversationViewController shouldUpdateRecipientStatusForMessage:(LYRMessage *)message
{
    return YES;
}

#pragma mark - Conversation View Controller Delegate

/**
 
 LAYER UI KIT - Handle succesful message send if needed.
 
 */
- (void)conversationViewController:(LYRUIConversationViewController *)viewController didSendMessage:(LYRMessage *)message
{
    NSLog(@"Successful Message Send");
}

/**
 
 LAYER UI KIT - React to unsuccesful message send if needed.
 
 */
- (void)conversationViewController:(LYRUIConversationViewController *)viewController didFailSendingMessage:(LYRMessage *)message error:(NSError *)error;
{
    NSLog(@"Message Send Failed with Error: %@", error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Messaging Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

/**
 
 LAYER UI KIT - React to a tap on a message object.
 
 */
- (void)conversationViewController:(LYRUIConversationViewController *)viewController didSelectMessage:(LYRMessage *)message
{
    if (self.applicationContoller.debugModeEnabled) {
        LSMessageDetailTableViewController *controller = [LSMessageDetailTableViewController initWithMessage:message applicationController:self.applicationContoller];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    }
}

#pragma mark - Address Bar View Controller Delegate

/**
 
 LAYER UI KIT - Allows your applicaiton to react to a tap on the `addContacts` button of the `LYRUIAddressBarViewController`. 
 In this case, we present an `LYRUIParticipantPickerController` component.
 
 */
- (void)addressBarViewController:(LYRUIAddressBarViewController *)addressBarViewController didTapAddContactsButton:(UIButton *)addContactsButton
{
    LYRUIParticipantPickerController *controller = [LYRUIParticipantPickerController participantPickerWithDataSource:self.participantPickerDataSource
                                                                                                            sortType:LYRUIParticipantPickerControllerSortTypeFirst];
    controller.participantPickerDelegate = self;
    controller.allowsMultipleSelection = NO;
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Adress Bar View Controller Data Source

/**
 
 LAYER UI KIT - Searches for a participant given and search string.
 
 */
- (void)searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSSet *participants))completion
{
    [self.applicationContoller.persistenceManager performParticipantSearchWithString:searchText completion:^(NSSet *contacts, NSError *error) {
        if (!error) {
            completion(contacts);
        }
    }];
}

#pragma mark - Participant Picker Delegate Methods

/**
 
 LAYER UI KIT - Handles a `Cancel` selection from the `LYRUIParticipantPickerController` component and dismisses the component.
 
 */
- (void)participantSelectionViewControllerDidCancel:(LYRUIParticipantPickerController *)participantSelectionViewController
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/**
 
 LAYER UI KIT - Handles a participant selection in the `LYRUIParticipantController`. In response, the application informs the 
 `addressBarController` property of the selection and then dismissess the picker.
 
 */
- (void)participantSelectionViewController:(LYRUIParticipantPickerController *)participantSelectionViewController didSelectParticipant:(id<LYRUIParticipant>)participant
{
    if (participant) {
        [self.addressBarController selectParticipant:participant];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Converation Detail View Controler Data Source

- (id<LYRUIParticipant>)conversationDetailViewController:(LSConversationDetailViewController *)conversationDetailViewController participantForIdentifier:(NSString *)participantIdentifier
{
    return [self.dataSource conversationViewController:self participantForIdentifier:participantIdentifier];
}

#pragma mark - Converation Detail View Controler Delegate

- (void)conversationDetailViewController:(LSConversationDetailViewController *)conversationDetailViewController didShareLocation:(CLLocation *)location
{
    LYRMessage *message = [self.layerClient newMessageWithParts:@[LYRUIMessagePartWithLocation(location)] options:nil error:nil];
    NSError *error;
    BOOL success = [self.conversation sendMessage:message error:&error];
    if (success) {
        NSLog(@"Message sent!");
    } else {
        NSLog(@"Message send failed with error: %@", error);
    }
}

- (void)conversationDetailViewController:(LSConversationDetailViewController *)conversationDetailViewController didChangeConversation:(LYRConversation *)conversation
{
    self.conversation = conversation;
}

#pragma mark - Details Button Actions

- (void)addDetailsButton
{
    UIBarButtonItem *detailsButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Details"
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(detailsButtonTapped)];
    detailsButtonItem.accessibilityLabel = @"Contacts";
    self.navigationItem.rightBarButtonItem = detailsButtonItem;
}

- (void)detailsButtonTapped
{
    LSConversationDetailViewController *detailViewController = [LSConversationDetailViewController conversationDetailViewControllerLayerClient:self.layerClient conversation:self.conversation];
    detailViewController.detailDelegate = self;
    detailViewController.detailsDataSource = self;
    detailViewController.applicationController = self.applicationContoller;
    [self.navigationController pushViewController:detailViewController animated:TRUE];
}

#pragma mark - Mark All Messages Read Method

- (void)markAllMessagesAsRead
{
    [self.conversation markAllMessagesAsRead:nil];
}

@end
