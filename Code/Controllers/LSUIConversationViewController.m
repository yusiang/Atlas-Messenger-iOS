//
//  LSUIConversationViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSUIConversationViewController.h"
#import "LYRUIMessagingUtilities.h"
#import "LSUIParticipantPickerDataSource.h"
#import "LYRUIParticipantPickerController.h"
#import "LSMessageDetailTableViewController.h"
#import "LSConversationDetailViewController.h"

@import QuickLook;

static NSURL *LSTestGenerateTempFileFromInputStream(NSInputStream *inputStream)
{
    NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Layer-Sample-App-Temp-Image.jpeg"];
    NSOutputStream *datafileOutputStream = [NSOutputStream outputStreamToFileAtPath:tempFilePath append:NO];
    
    // Open streams
    [inputStream open];
    [datafileOutputStream open];
    
    // Create a temp buffer
    const NSUInteger bufferSize = 1024 * 512;
    uint8_t *buffer = malloc(bufferSize);
    
    // Read and write random data in 1024 byte chunks
    NSUInteger totalBytesWritten = 0;
    BOOL endOfStream = NO;
    while (!endOfStream) {
        NSInteger bytesRead = [inputStream read:buffer maxLength:bufferSize];
        if (bytesRead == 0) {
            endOfStream = YES;
        } else if (bytesRead < 0) {
            break;
        }
        NSInteger bytesWritten = [datafileOutputStream write:buffer maxLength:bytesRead];
        if (bytesWritten <= 0) break;
        totalBytesWritten += bytesWritten;
    }
    
    // Close streams
    [inputStream close];
    [datafileOutputStream close];
    
    // Free memory
    free(buffer);
    
    if (!endOfStream) return nil;
    return [NSURL fileURLWithPath:tempFilePath];
}

static NSDateFormatter *LSShortTimeFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    return dateFormatter;
}

static NSDateFormatter *LSDayOfWeekDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EEEE"; // Tuesday
    }
    return dateFormatter;
}

static NSDateFormatter *LSRelativeDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.doesRelativeDateFormatting = YES;
    }
    return dateFormatter;
}

static NSDateFormatter *LSThisYearDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"E, MMM dd,"; // Sat, Nov 29,
    }
    return dateFormatter;
}

static NSDateFormatter *LSDefaultDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMM dd, YYYY,"; // Nov 29, 2013,
    }
    return dateFormatter;
}

static BOOL LSIsDateInToday(NSDate *date)
{
    NSCalendarUnit dateUnits = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:dateUnits fromDate:date];
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:dateUnits fromDate:[NSDate date]];
    return ([dateComponents day] == [todayComponents day] &&
            [dateComponents month] == [todayComponents month] &&
            [dateComponents year] == [todayComponents year] &&
            [dateComponents era] == [todayComponents era]);
}

static BOOL LSIsDateInYesterday(NSDate *date)
{
    NSCalendarUnit dateUnits = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:dateUnits fromDate:date];
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:dateUnits fromDate:[NSDate date]];
    return ([dateComponents day] == ([todayComponents day] - 1) &&
            [dateComponents month] == [todayComponents month] &&
            [dateComponents year] == [todayComponents year] &&
            [dateComponents era] == [todayComponents era]);
}

static BOOL LSIsDateInWeek(NSDate *date)
{
    NSCalendarUnit dateUnits = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfMonthCalendarUnit;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:dateUnits fromDate:date];
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:dateUnits fromDate:[NSDate date]];
    return ([dateComponents weekOfMonth] == [todayComponents weekOfMonth] &&
            [dateComponents month] == [todayComponents month] &&
            [dateComponents year] == [todayComponents year] &&
            [dateComponents era] == [todayComponents era]);
}

static BOOL LSIsDateInYear(NSDate *date)
{
    NSCalendarUnit dateUnits = NSEraCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:dateUnits fromDate:date];
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:dateUnits fromDate:[NSDate date]];
    return ([dateComponents year] == [todayComponents year] &&
            [dateComponents era] == [todayComponents era]);
}

@interface LSUIConversationViewController () <LSConversationDetailViewControllerDelegate, LSConversationDetailViewControllerDataSource, LYRUIAddressBarControllerDataSource, LYRUIParticipantPickerControllerDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate>

@property (nonatomic) LSUIParticipantPickerDataSource *participantPickerDataSource;
@property (nonatomic) NSURL *previewFileURL;

@end

@implementation LSUIConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    
    self.participantPickerDataSource = [LSUIParticipantPickerDataSource participantPickerDataSourceWithPersistenceManager:self.applicationController.persistenceManager];
    
    if (self.conversation) {
        [self addDetailsButton];
    }
    [self markAllMessagesAsRead];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.conversation.metadata valueForKey:LYRUIConversationNameTag]) {
        self.conversationTitle = [self.conversation.metadata valueForKey:LYRUIConversationNameTag];
    }
    
    self.addressBarController.dataSource = self;
}

#pragma mark - LYRUIConversationViewControllerDataSource

/**
 
 LAYER UI KIT - Returns an object conforming to the `LYRUIParticipant` protocol.
 
 */
- (id<LYRUIParticipant>)conversationViewController:(LYRUIConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier
{
    if (participantIdentifier) {
        NSSet *set = [self.applicationController.persistenceManager participantsForIdentifiers:[NSSet setWithObject:participantIdentifier]];
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
    NSString *dateString = nil;
    if (LSIsDateInToday(date) || LSIsDateInYesterday(date)) {
        dateString = [LSRelativeDateFormatter() stringFromDate:date];
    } else if (LSIsDateInWeek(date)) {
        dateString = [LSDayOfWeekDateFormatter() stringFromDate:date];
    } else if (LSIsDateInYear(date)) {
        dateString = [LSThisYearDateFormatter() stringFromDate:date];
    } else {
        dateString = [LSDefaultDateFormatter() stringFromDate:date];
    }
    NSString *timeString = [LSShortTimeFormatter() stringFromDate:date];
    
    NSMutableAttributedString *dateAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", dateString, timeString]];
    NSRange boldedRange = NSMakeRange(0, [dateString length]);
    [dateAttributedString addAttribute:NSFontAttributeName
                                 value:[UIFont boldSystemFontOfSize:12]
                                 range:boldedRange];
    return dateAttributedString;
}

/**
 
 LAYER UI KIT - Returns an `NSAttributedString` object for given recipient state. The state string will only be displayed
 below the latest message that was sent by the currently authenticated user.
 
 */
- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus
{
    __block BOOL allSent = YES;
    __block BOOL allDelivered = YES;
    __block BOOL allRead = YES;
    [recipientStatus enumerateKeysAndObjectsUsingBlock:^(NSString *userID, NSNumber *statusNumber, BOOL *stop) {
        if ([userID isEqualToString:self.applicationController.layerClient.authenticatedUserID]) return;
        LYRRecipientStatus status = statusNumber.integerValue;
        switch (status) {
            case LYRRecipientStatusInvalid:
                allSent = NO;
            case LYRRecipientStatusSent:
                allDelivered = NO;
            case LYRRecipientStatusDelivered:
                allRead = NO;
                break;
            case LYRRecipientStatusRead:
                break;
        }
    }];

    NSString *statusString;
    if (allRead) {
        statusString = @"Read";
    } else if (allDelivered) {
        statusString = @"Delivered";
    } else if (allSent) {
        statusString = @"Sent";
    } else {
        statusString = @"Not Sent";
    }

    return [[NSAttributedString alloc] initWithString:statusString];
}

/**
 
 LAYER UI KIT - Returns an `NSString` object that will be displayed as the push notification test for the given message.
 If no string is returned, Layer will not deliver a text based push notification.
 
 */
- (NSString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController pushNotificationTextForMessagePart:(LYRMessagePart *)messagePart
{
    if (!self.applicationController.shouldSendPushText) return nil;
    if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeTextPlain]) {
        return [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG] || [messagePart.MIMEType isEqualToString:LYRUIMIMETypeImagePNG]) {
        return @"Has sent a new image";
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeLocation]) {
        return @"Has sent a new location";
    }
    return nil;
}

/**
 
 LAYER UI KIT - If your application would like to mark messages as read, return YES.
 
 */
- (BOOL)conversationViewController:(LYRUIConversationViewController *)conversationViewController shouldUpdateRecipientStatusForMessage:(LYRMessage *)message
{
    return YES;
}

#pragma mark - LYRUIConversationViewControllerDelegate

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
    if (self.applicationController.debugModeEnabled) {
        LSMessageDetailTableViewController *controller = [LSMessageDetailTableViewController initWithMessage:message applicationController:self.applicationController];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    } else {
        
        LYRMessagePart *part = message.parts[0];
        if ([part.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG] || [part.MIMEType isEqualToString:LYRUIMIMETypeImagePNG]) {
            self.previewFileURL =  LSTestGenerateTempFileFromInputStream(part.inputStream);
            if (!self.previewFileURL) return;
            QLPreviewController *previewController = [[QLPreviewController alloc] init];
            previewController.dataSource = self;
            previewController.currentPreviewItemIndex = 0;
            [[self navigationController] pushViewController:previewController animated:YES];
        }
    }
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return self.previewFileURL ? 1 : 0;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return self.previewFileURL;
}

#pragma mark - LYRUIAddressBarControllerDelegate

/**
 
 LAYER UI KIT - Allows your applicaiton to react to a tap on the `addContacts` button of the `LYRUIAddressBarViewController`. 
 In this case, we present an `LYRUIParticipantPickerController` component.
 
 */
- (void)addressBarViewController:(LYRUIAddressBarViewController *)addressBarViewController didTapAddContactsButton:(UIButton *)addContactsButton
{
    NSSet *selectedParticipantIdentifiers = [addressBarViewController.selectedParticipants valueForKey:@"participantIdentifier"];
    self.participantPickerDataSource.excludedIdentifiers = selectedParticipantIdentifiers;

    LYRUIParticipantPickerController *controller = [LYRUIParticipantPickerController participantPickerWithDataSource:self.participantPickerDataSource
                                                                                                            sortType:LYRUIParticipantPickerSortTypeFirstName];
    controller.participantPickerDelegate = self;
    controller.allowsMultipleSelection = NO;
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - LYRUIAddressBarControllerDataSource

/**
 
 LAYER UI KIT - Searches for a participant given and search string.
 
 */
- (void)addressBarViewController:(LYRUIAddressBarViewController *)addressBarViewController searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSArray *participants))completion
{
    [self.applicationController.persistenceManager performParticipantSearchWithString:searchText completion:^(NSArray *contacts, NSError *error) {
        completion(contacts ?: @[]);
    }];
}

#pragma mark - LYRUIParticipantPickerControllerDelegate

/**
 
 LAYER UI KIT - Handles a `Cancel` selection from the `LYRUIParticipantPickerController` component and dismisses the component.
 
 */
- (void)participantPickerControllerDidCancel:(LYRUIParticipantPickerController *)participantPickerController
{
    [participantPickerController dismissViewControllerAnimated:YES completion:nil];
}

/**
 
 LAYER UI KIT - Handles a participant selection in the `LYRUIParticipantController`. In response, the application informs the 
 `addressBarController` property of the selection and then dismissess the picker.
 
 */
- (void)participantPickerController:(LYRUIParticipantPickerController *)participantPickerController didSelectParticipant:(id<LYRUIParticipant>)participant
{
    [self.addressBarController selectParticipant:participant];
    [participantPickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LSConversationDetailViewControllerDataSource

- (id<LYRUIParticipant>)conversationDetailViewController:(LSConversationDetailViewController *)conversationDetailViewController participantForIdentifier:(NSString *)participantIdentifier
{
    return [self.dataSource conversationViewController:self participantForIdentifier:participantIdentifier];
}

#pragma mark - LSConversationDetailViewControllerDelegate

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
    detailViewController.applicationController = self.applicationController;
    [self.navigationController pushViewController:detailViewController animated:TRUE];
}

#pragma mark - Mark All Messages Read Method

- (void)markAllMessagesAsRead
{
    [self.conversation markAllMessagesAsRead:nil];
}

@end
