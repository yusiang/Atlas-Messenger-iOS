//
//  LSUIConversationViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSUIConversationViewController.h"
#import "LSConversationDetailViewController.h"

static NSDateFormatter *LYRUIConversationDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMM dd, hh:mma";
    }
    return dateFormatter;
}

@interface LSUIConversationViewController () <LYRUIConversationViewControllerDataSource, LYRUIConversationViewControllerDelegate, LSConversationDetailViewControllerDelegate>

@end

@implementation LSUIConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addContactsButton];
    self.dataSource = self;
    self.delegate = self;
}

- (id<LYRUIParticipant>)conversationViewController:(LYRUIConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier
{
    if (participantIdentifier) {
        NSSet *set = [self.applicationContoller.persistenceManager participantsForIdentifiers:[NSSet setWithObject:participantIdentifier]];
        return [[set allObjects] firstObject];
    }
    return nil;
}

- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date
{
    NSString *dateString = [LYRUIConversationDateFormatter() stringFromDate:date];
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

- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus
{
    NSMutableArray *recipients = [[recipientStatus allKeys] mutableCopy];
    [recipients removeObject:self.applicationContoller.layerClient.authenticatedUserID];
    
    NSAttributedString *attributedString;
    
    NSInteger status = [[recipientStatus valueForKey:[recipients lastObject]] integerValue];
    switch (status) {
        case LYRRecipientStatusInvalid:
            attributedString = [[NSAttributedString alloc] initWithString:@"Message Not Sent"];
            break;
            
        case LYRRecipientStatusSent:
            attributedString = [[NSAttributedString alloc] initWithString:@"Message Not Sent"];
            break;
            
        case LYRRecipientStatusDelivered:
            attributedString = [[NSAttributedString alloc] initWithString:@"Message Not Sent"];
            break;
            
        case LYRRecipientStatusRead:
            attributedString = [[NSAttributedString alloc] initWithString:@"Message Not Sent"];
            break;
            
        default:
            break;
    }
    return attributedString;
}

- (BOOL)converationViewController:(LYRUIConversationViewController *)conversationViewController shouldUpdateRecipientStatusForMessage:(LYRMessage *)message
{
    return YES;
}

#pragma mark - LYRUIConversationViewController Delegate

- (void)conversationViewController:(LYRUIConversationViewController *)viewController didSendMessage:(LYRMessage *)message
{
    NSLog(@"Message Sent: %@", message);
}

- (void)conversationViewController:(LYRUIConversationViewController *)viewController didFailSendingMessageWithError:(NSError *)error
{
    NSLog(@"Message Send Failed with Error: %@", error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Messaging Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark Contact Button

- (void)addContactsButton
{
    UIBarButtonItem *contactsButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Contacts"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(contactsButtonTapped)];
    contactsButtonItem.accessibilityLabel = @"Contacts";
    self.navigationItem.rightBarButtonItem = contactsButtonItem;
}

- (void)contactsButtonTapped
{
    LSConversationDetailViewController *detailViewController = [LSConversationDetailViewController conversationDetailViewControllerLayerClient:self.layerClient conversation:self.conversation];
    detailViewController.detailDelegate = self;
    detailViewController.applicationController = self.applicationContoller;
    [self.navigationController pushViewController:detailViewController animated:TRUE];
}

- (id<LYRUIParticipant>)conversationDetailViewController:(LSConversationDetailViewController *)conversationDetailViewController participantForIdentifier:(NSString *)participantIdentifier
{
    return [self.dataSource conversationViewController:self participantForIdentifier:participantIdentifier];
}


@end
