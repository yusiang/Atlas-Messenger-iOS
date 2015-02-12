//
//  LSConversationViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationViewController.h"
#import "LSParticipantDataSource.h"
#import "LSMessageDetailViewController.h"
#import "LSConversationDetailViewController.h"
#import "LSImageViewController.h"
#import "LSUtilities.h"
#import "LSParticipantTableViewController.h"
#import "LSParticipantDataSource.h"

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
        dateFormatter.dateFormat = @"MMM dd, yyyy,"; // Nov 29, 2013,
    }
    return dateFormatter;
}

typedef NS_ENUM(NSInteger, LSDateProximity) {
    LSDateProximityToday,
    LSDateProximityYesterday,
    LSDateProximityWeek,
    LSDateProximityYear,
    LSDateProximityOther,
};

static LSDateProximity LSProximityToDate(NSDate *date)
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
        return LSDateProximityToday;
    }

    NSDateComponents *componentsToYesterday = [NSDateComponents new];
    componentsToYesterday.day = -1;
    NSDate *yesterday = [calendar dateByAddingComponents:componentsToYesterday toDate:now options:0];
    NSDateComponents *yesterdayComponents = [calendar components:calendarUnits fromDate:yesterday];
    if (dateComponents.day == yesterdayComponents.day &&
        dateComponents.month == yesterdayComponents.month &&
        dateComponents.year == yesterdayComponents.year &&
        dateComponents.era == yesterdayComponents.era) {
        return LSDateProximityYesterday;
    }

    if (dateComponents.weekOfMonth == todayComponents.weekOfMonth &&
        dateComponents.month == todayComponents.month &&
        dateComponents.year == todayComponents.year &&
        dateComponents.era == todayComponents.era) {
        return LSDateProximityWeek;
    }

    if (dateComponents.year == todayComponents.year &&
        dateComponents.era == todayComponents.era) {
        return LSDateProximityYear;
    }

    return LSDateProximityOther;
}

@interface LSConversationViewController () <LSConversationDetailViewControllerDelegate, LSConversationDetailViewControllerDataSource, LYRUIAddressBarControllerDataSource, LYRUIParticipantTableViewControllerDelegate>

@property (nonatomic) LSParticipantDataSource *participantDataSource;

@end

@implementation LSConversationViewController

NSString *const LSConversationViewControllerAccessibilityLabel = @"Conversation View Controller";
NSString *const LSDetailsButtonAccessibilityLabel = @"Details Button";
NSString *const LSDetailsButtonLabel = @"Details";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.accessibilityLabel = LSConversationViewControllerAccessibilityLabel;
    self.dataSource = self;
    self.delegate = self;
    if (self.conversation) {
        [self addDetailsButton];
    }
    [self markAllMessagesAsRead];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidTapLink:)
                                                 name:LYRUIUserDidTapLinkNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(conversationMetadataDidChange:)
                                                 name:LSConversationMetadataDidChangeNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.conversation.metadata valueForKey:LSConversationMetadataNameKey]) {
        self.title = [self.conversation.metadata valueForKey:LSConversationMetadataNameKey];
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

#pragma mark - LYRUIConversationViewControllerDataSource

/**
 
 LAYER UI KIT - Returns an object conforming to the `LYRUIParticipant` protocol.
 
 */
- (id<LYRUIParticipant>)conversationViewController:(LYRUIConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier
{
    if (participantIdentifier) {
        LSUser *user = [self.applicationController.persistenceManager userForIdentifier:participantIdentifier];
        if (user) return user;
        [[NSNotificationCenter defaultCenter] postNotificationName:LSAppEncounteredUnknownUser object:nil];
    }
    return nil;
}

/**
 
 LAYER UI KIT - Returns an `NSAttributedString` object for given date. The format of this string can be configured to
 whatever format your application wishes to display.
 
 */
- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter;
    LSDateProximity dateProximity = LSProximityToDate(date);
    switch (dateProximity) {
        case LSDateProximityToday:
        case LSDateProximityYesterday:
            dateFormatter = LSRelativeDateFormatter();
            break;
        case LSDateProximityWeek:
            dateFormatter = LSDayOfWeekDateFormatter();
            break;
        case LSDateProximityYear:
            dateFormatter = LSThisYearDateFormatter();
            break;
        case LSDateProximityOther:
            dateFormatter = LSDefaultDateFormatter();
            break;
    }

    NSString *dateString = [dateFormatter stringFromDate:date];
    NSString *timeString = [LSShortTimeFormatter() stringFromDate:date];
    
    NSMutableAttributedString *dateAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", dateString, timeString]];
    [dateAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, dateAttributedString.length)];
    [dateAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, dateAttributedString.length)];
    [dateAttributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(0, dateString.length)];
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
    return [[NSAttributedString alloc] initWithString:statusString attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]}];
}

/**
 
 LAYER UI KIT - Return an `NSOrderedSet` of `LYRMessage` objects. If nil is returned, controller will fall back to default
 message sending behavior. If an empty `NSOrderedSet` is returned, no messages will be sent.
 
 */
- (NSOrderedSet *)conversationViewController:(LYRUIConversationViewController *)conversationViewController messagesForContentParts:(NSArray *)contentParts
{
    return nil;
}

#pragma mark - LYRUIConversationViewControllerDelegate

/**
 
 LAYER UI KIT - Handle succesful message send if needed.
 
 */
- (void)conversationViewController:(LYRUIConversationViewController *)viewController didSendMessage:(LYRMessage *)message
{
    NSLog(@"Successful Message Send");
    [self addDetailsButton];
}

/**
 
 LAYER UI KIT - React to unsuccesful message send if needed.
 
 */
- (void)conversationViewController:(LYRUIConversationViewController *)viewController didFailSendingMessage:(LYRMessage *)message error:(NSError *)error;
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
- (void)conversationViewController:(LYRUIConversationViewController *)viewController didSelectMessage:(LYRMessage *)message
{
    if (self.applicationController.debugModeEnabled) {
        LSMessageDetailViewController *controller = [LSMessageDetailViewController messageDetailViewControllerWithMessage:message applicationController:self.applicationController];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    } else {
        LYRMessagePart *part = message.parts.firstObject;
        if ([part.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG] || [part.MIMEType isEqualToString:LYRUIMIMETypeImagePNG]) {
            UIImage *image = [[UIImage alloc] initWithData:part.data];
            if (!image) return;
            LSImageViewController *imageViewController = [[LSImageViewController alloc] initWithImage:image];
            [self.navigationController pushViewController:imageViewController animated:YES];
        }
    }
}

#pragma mark - LYRUIAddressBarControllerDelegate

/**
 
 LAYER UI KIT - Allows your applicaiton to react to a tap on the `addContacts` button of the `LYRUIAddressBarViewController`. 
 In this case, we present an `LYRUIParticipantPickerController` component.
 
 */
- (void)addressBarViewController:(LYRUIAddressBarViewController *)addressBarViewController didTapAddContactsButton:(UIButton *)addContactsButton
{
    NSSet *selectedParticipantIdentifiers = [addressBarViewController.selectedParticipants valueForKey:@"participantIdentifier"];
    self.participantDataSource = [LSParticipantDataSource participantPickerDataSourceWithPersistenceManager:self.applicationController.persistenceManager];
    self.participantDataSource.excludedIdentifiers = selectedParticipantIdentifiers;
    
    LSParticipantTableViewController  *controller = [LSParticipantTableViewController participantTableViewControllerWithParticipants:self.participantDataSource.participants sortType:LYRUIParticipantPickerSortTypeFirstName];
    controller.delegate = self;
    controller.allowsMultipleSelection = NO;
    
    UINavigationController *navigationController =[[UINavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - LYRUIAddressBarControllerDataSource

/**
 
 LAYER UI KIT - Searches for a participant given and search string.
 
 */
- (void)addressBarViewController:(LYRUIAddressBarViewController *)addressBarViewController searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSArray *participants))completion
{
    [self.applicationController.persistenceManager performUserSearchWithString:searchText completion:^(NSArray *users, NSError *error) {
        completion(users ?: @[]);
    }];
}

#pragma mark - LYRUIParticipantTableViewControllerDelegate

- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<LYRUIParticipant>)participant
{
    [self.addressBarController selectParticipant:participant];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    [self.participantDataSource participantsMatchingSearchText:searchText completion:^(NSSet *participants) {
        completion(participants);
    }];
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
    [self.navigationController popToViewController:self animated:YES];
}

- (void)conversationDetailViewController:(LSConversationDetailViewController *)conversationDetailViewController didChangeConversation:(LYRConversation *)conversation
{
    self.conversation = conversation;
    [self configureTitle];
}

#pragma mark - Details Button Actions

- (void)addDetailsButton
{
    if (self.navigationItem.rightBarButtonItem) return;

    UIBarButtonItem *detailsButtonItem = [[UIBarButtonItem alloc] initWithTitle:LSDetailsButtonLabel
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(detailsButtonTapped)];
    detailsButtonItem.accessibilityLabel = LSDetailsButtonAccessibilityLabel;
    self.navigationItem.rightBarButtonItem = detailsButtonItem;
}

- (void)detailsButtonTapped
{
    LSConversationDetailViewController *detailViewController = [LSConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
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
    if ([self.conversation.metadata valueForKey:LSConversationMetadataNameKey]) {
        self.title = [self.conversation.metadata valueForKey:LSConversationMetadataNameKey];
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
        id<LYRUIParticipant> participant = [self.dataSource conversationViewController:self participantForIdentifier:otherParticipantID];
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
