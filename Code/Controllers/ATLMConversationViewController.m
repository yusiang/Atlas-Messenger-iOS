//
//  ATLMConversationViewController.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 9/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ATLMConversationViewController.h"
#import "ATLMParticipantDataSource.h"
#import "ATLMMessageDetailViewController.h"
#import "ATLMConversationDetailViewController.h"
#import "ATLMImageViewController.h"
#import "ATLMUtilities.h"
#import "ATLMParticipantTableViewController.h"

static NSDateFormatter *ATLMShortTimeFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    return dateFormatter;
}

static NSDateFormatter *ATLMDayOfWeekDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EEEE"; // Tuesday
    }
    return dateFormatter;
}

static NSDateFormatter *ATLMRelativeDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.doesRelativeDateFormatting = YES;
    }
    return dateFormatter;
}

static NSDateFormatter *ATLMThisYearDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"E, MMM dd,"; // Sat, Nov 29,
    }
    return dateFormatter;
}

static NSDateFormatter *ATLMDefaultDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMM dd, yyyy,"; // Nov 29, 2013,
    }
    return dateFormatter;
}

typedef NS_ENUM(NSInteger, ATLMDateProximity) {
    ATLMDateProximityToday,
    ATLMDateProximityYesterday,
    ATLMDateProximityWeek,
    ATLMDateProximityYear,
    ATLMDateProximityOther,
};

static ATLMDateProximity ATLMProximityToDate(NSDate *date)
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSCalendarUnit calendarUnits = NSEraCalendarUnit | NSYearCalendarUnit | NSWeekOfMonthCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:calendarUnits fromDate:date];
    NSDateComponents *todayComponents = [calendar components:calendarUnits fromDate:now];
    if (dateComponents.day == todayComponents.day &&
        dateComponents.month == todayComponents.month &&
        dateComponents.year == todayComponents.year &&
        dateComponents.era == todayComponents.era) {
        return ATLMDateProximityToday;
    }

    NSDateComponents *componentsToYesterday = [NSDateComponents new];
    componentsToYesterday.day = -1;
    NSDate *yesterday = [calendar dateByAddingComponents:componentsToYesterday toDate:now options:0];
    NSDateComponents *yesterdayComponents = [calendar components:calendarUnits fromDate:yesterday];
    if (dateComponents.day == yesterdayComponents.day &&
        dateComponents.month == yesterdayComponents.month &&
        dateComponents.year == yesterdayComponents.year &&
        dateComponents.era == yesterdayComponents.era) {
        return ATLMDateProximityYesterday;
    }

    if (dateComponents.weekOfMonth == todayComponents.weekOfMonth &&
        dateComponents.month == todayComponents.month &&
        dateComponents.year == todayComponents.year &&
        dateComponents.era == todayComponents.era) {
        return ATLMDateProximityWeek;
    }

    if (dateComponents.year == todayComponents.year &&
        dateComponents.era == todayComponents.era) {
        return ATLMDateProximityYear;
    }

    return ATLMDateProximityOther;
}

@interface ATLMConversationViewController () <ATLMConversationDetailViewControllerDelegate, ATLMConversationDetailViewControllerDataSource, ATLAddressBarControllerDataSource, ATLParticipantTableViewControllerDelegate>

@property (nonatomic) ATLMParticipantDataSource *participantDataSource;

@end

@implementation ATLMConversationViewController

NSString *const ATLMConversationViewControllerAccessibilityLabel = @"Conversation View Controller";
NSString *const ATLMDetailsButtonAccessibilityLabel = @"Details Button";
NSString *const ATLMDetailsButtonLabel = @"Details";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.accessibilityLabel = ATLMConversationViewControllerAccessibilityLabel;
    self.dataSource = self;
    self.delegate = self;
    if (self.conversation) {
        [self addDetailsButton];
    }
    [self markAllMessagesAsRead];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidTapLink:)
                                                 name:ATLUserDidTapLinkNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(conversationMetadataDidChange:)
                                                 name:ATLMConversationMetadataDidChangeNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.conversation.metadata valueForKey:ATLMConversationMetadataNameKey]) {
        self.title = [self.conversation.metadata valueForKey:ATLMConversationMetadataNameKey];
    } else {
        self.title = [self defaultTitle];
    }
    self.addressBarController.dataSource = self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Accessors

- (void)setConversation:(LYRConversation *)conversation
{
    [super setConversation:conversation];
    [self configureTitle];
}

#pragma mark - ATLConversationViewControllerDataSource

/**
 
 LAYER UI KIT - Returns an object conforming to the `ATLParticipant` protocol.
 
 */
- (id<ATLParticipant>)conversationViewController:(ATLConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier
{
    if (participantIdentifier) {
        ATLMUser *user = [self.applicationController.persistenceManager userForIdentifier:participantIdentifier];
        if (user) return user;
        [[NSNotificationCenter defaultCenter] postNotificationName:ATLMAppEncounteredUnknownUser object:nil];
    }
    return nil;
}

/**
 
 LAYER UI KIT - Returns an `NSAttributedString` object for given date. The format of this string can be configured to
 whatever format your application wishes to display.
 
 */
- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter;
    ATLMDateProximity dateProximity = ATLMProximityToDate(date);
    switch (dateProximity) {
        case ATLMDateProximityToday:
        case ATLMDateProximityYesterday:
            dateFormatter = ATLMRelativeDateFormatter();
            break;
        case ATLMDateProximityWeek:
            dateFormatter = ATLMDayOfWeekDateFormatter();
            break;
        case ATLMDateProximityYear:
            dateFormatter = ATLMThisYearDateFormatter();
            break;
        case ATLMDateProximityOther:
            dateFormatter = ATLMDefaultDateFormatter();
            break;
    }

    NSString *dateString = [dateFormatter stringFromDate:date];
    NSString *timeString = [ATLMShortTimeFormatter() stringFromDate:date];
    
    NSMutableAttributedString *dateAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", dateString, timeString]];
    [dateAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, dateAttributedString.length)];
    [dateAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, dateAttributedString.length)];
    [dateAttributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:11] range:NSMakeRange(0, dateString.length)];
    return dateAttributedString;
}

/**
 
 LAYER UI KIT - Returns an `NSAttributedString` object for given recipient state. The state string will only be displayed
 below the latest message that was sent by the currently authenticated user.
 
 */
- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus
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
    return [[NSAttributedString alloc] initWithString:statusString attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:11]}];
}

/**
 
 LAYER UI KIT - Return an `NSOrderedSet` of `LYRMessage` objects. If nil is returned, controller will fall back to default
 message sending behavior. If an empty `NSOrderedSet` is returned, no messages will be sent.
 
 */
- (NSOrderedSet *)conversationViewController:(ATLConversationViewController *)conversationViewController messagesForMediaAttachments:(NSArray *)mediaAttachments
{
    return nil;
}

#pragma mark - ATLConversationViewControllerDelegate

/**
 
 LAYER UI KIT - Handle succesful message send if needed.
 
 */
- (void)conversationViewController:(ATLConversationViewController *)viewController didSendMessage:(LYRMessage *)message
{
    NSLog(@"Successful Message Send");
    [self addDetailsButton];
}

/**
 
 LAYER UI KIT - React to unsuccesful message send if needed.
 
 */
- (void)conversationViewController:(ATLConversationViewController *)viewController didFailSendingMessage:(LYRMessage *)message error:(NSError *)error;
{
    NSLog(@"Message Send Failed with Error: %@", error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Messaging Error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

/**
 
 LAYER UI KIT - React to a tap on a message object.
 
 */
- (void)conversationViewController:(ATLConversationViewController *)viewController didSelectMessage:(LYRMessage *)message
{
    if (self.applicationController.debugModeEnabled) {
        ATLMMessageDetailViewController *controller = [ATLMMessageDetailViewController messageDetailViewControllerWithMessage:message applicationController:self.applicationController];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    } else {
        LYRMessagePart *imageMessagePart = ATLMessagePartForMIMEType(message, ATLMIMETypeImageJPEG);
        if (!imageMessagePart) {
            imageMessagePart = ATLMessagePartForMIMEType(message, ATLMIMETypeImagePNG);
        }
        if (imageMessagePart) {
            ATLMImageViewController *imageViewController = [[ATLMImageViewController alloc] initWithMessage:message];
            UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:imageViewController];
            [self.navigationController presentViewController:controller animated:YES completion:nil];
        }
    }
}

#pragma mark - ATLAddressBarControllerDelegate

/**
 
 LAYER UI KIT - Allows your applicaiton to react to a tap on the `addContacts` button of the `ATLAddressBarViewController`. 
 In this case, we present an `ATLParticipantPickerController` component.
 
 */
- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController didTapAddContactsButton:(UIButton *)addContactsButton
{
    NSMutableSet *excludedIdentifiers = [[NSMutableSet alloc] initWithObjects:self.layerClient.authenticatedUserID, nil];
    [excludedIdentifiers addObjectsFromArray:[[addressBarViewController.selectedParticipants valueForKey:@"participantIdentifier"] allObjects]];

    self.participantDataSource = [ATLMParticipantDataSource participantPickerDataSourceWithPersistenceManager:self.applicationController.persistenceManager];
    self.participantDataSource.excludedIdentifiers = excludedIdentifiers;
    
    ATLMParticipantTableViewController  *controller = [ATLMParticipantTableViewController participantTableViewControllerWithParticipants:self.participantDataSource.participants sortType:ATLParticipantPickerSortTypeFirstName];
    controller.delegate = self;
    controller.allowsMultipleSelection = NO;
    
    UINavigationController *navigationController =[[UINavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - ATLAddressBarControllerDataSource

/**
 
 LAYER UI KIT - Searches for a participant given and search string.
 
 */
- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSArray *participants))completion
{
    [self.applicationController.persistenceManager performUserSearchWithString:searchText completion:^(NSArray *users, NSError *error) {
        completion(users ?: @[]);
    }];
}

#pragma mark - ATLParticipantTableViewControllerDelegate

- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<ATLParticipant>)participant
{
    [self.addressBarController selectParticipant:participant];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    [self.participantDataSource participantsMatchingSearchText:searchText completion:^(NSSet *participants) {
        completion(participants);
    }];
}

#pragma mark - LSConversationDetailViewControllerDataSource

- (id<ATLParticipant>)conversationDetailViewController:(ATLMConversationDetailViewController *)conversationDetailViewController participantForIdentifier:(NSString *)participantIdentifier
{
    return [self.dataSource conversationViewController:self participantForIdentifier:participantIdentifier];
}

#pragma mark - LSConversationDetailViewControllerDelegate

- (void)conversationDetailViewControllerDidSelectShareLocation:(ATLMConversationDetailViewController *)conversationDetailViewController
{
    // TODO - Figure out how to tell Atlas that it needs to share a location.
    [self.navigationController popToViewController:self animated:YES];
}

- (void)conversationDetailViewController:(ATLMConversationDetailViewController *)conversationDetailViewController didChangeConversation:(LYRConversation *)conversation
{
    self.conversation = conversation;
    [self configureTitle];
}

#pragma mark - Details Button Actions

- (void)addDetailsButton
{
    if (self.navigationItem.rightBarButtonItem) return;

    UIBarButtonItem *detailsButtonItem = [[UIBarButtonItem alloc] initWithTitle:ATLMDetailsButtonLabel
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(detailsButtonTapped)];
    detailsButtonItem.accessibilityLabel = ATLMDetailsButtonAccessibilityLabel;
    self.navigationItem.rightBarButtonItem = detailsButtonItem;
}

- (void)detailsButtonTapped
{
    ATLMConversationDetailViewController *detailViewController = [ATLMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    detailViewController.detailDelegate = self;
    detailViewController.detailDataSource = self;
    detailViewController.applicationController = self.applicationController;
    detailViewController.changingParticipantsMutatesConversation = self.applicationController.debugModeEnabled;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - Notification Handlers

- (void)conversationMetadataDidChange:(NSNotification *)notification
{
    if (!self.conversation) return;
    if (!notification.object) return;
    if (![notification.object isEqual:self.conversation]) return;

    [self configureTitle];
}

#pragma mark - Helpers

- (void)markAllMessagesAsRead
{
    [self.conversation markAllMessagesAsRead:nil];
}

- (void)configureTitle
{
    if ([self.conversation.metadata valueForKey:ATLMConversationMetadataNameKey]) {
        self.title = [self.conversation.metadata valueForKey:ATLMConversationMetadataNameKey];
    } else {
        self.title = [self defaultTitle];
    }
}

- (NSString *)defaultTitle
{
    if (!self.conversation) return @"New Message";
    NSMutableSet *otherParticipantIDs = [self.conversation.participants mutableCopy];
    if (self.layerClient.authenticatedUserID) [otherParticipantIDs removeObject:self.layerClient.authenticatedUserID];
    if (otherParticipantIDs.count == 0) return @"Personal";
    if (otherParticipantIDs.count == 1) {
        NSString *otherParticipantID = [otherParticipantIDs anyObject];
        id<ATLParticipant> participant = [self.dataSource conversationViewController:self participantForIdentifier:otherParticipantID];
        return participant ? participant.firstName : @"Unknown";
    }
    return @"Group";
}

#pragma mark - Link Tap Handler

- (void)userDidTapLink:(NSNotification *)notification
{
    [[UIApplication sharedApplication] openURL:notification.object];
}

@end
