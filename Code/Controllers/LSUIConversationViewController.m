//
//  LSUIConversationViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSUIConversationViewController.h"

static NSDateFormatter *LYRUIConversationDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMM dd, hh:mma";
    }
    return dateFormatter;
}

@interface LSUIConversationViewController () <LYRUIConversationViewControllerDataSource>

@end

@implementation LSUIConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dataSource = self;
}

- (id<LYRUIParticipant>)conversationViewController:(LYRUIConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier
{
    NSSet *set = [self.applicationContoller.persistenceManager participantsForIdentifiers:[NSSet setWithObject:participantIdentifier]];
    return [[set allObjects] firstObject];
}

- (NSString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date
{
    return [LYRUIConversationDateFormatter() stringFromDate:date];
}

- (NSString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus
{
    NSMutableArray *recipients = [[recipientStatus allKeys] mutableCopy];
    [recipients removeObject:self.applicationContoller.layerClient.authenticatedUserID];
    NSInteger status = [[recipientStatus valueForKey:[recipients lastObject]] integerValue];
    switch (status) {
        case LYRRecipientStatusInvalid:
            return @"Message Not Sent";
            break;
            
        case LYRRecipientStatusSent:
            return @"Message Sent";
            break;
            
        case LYRRecipientStatusDelivered:
            return @"Message Delivered";
            break;
            
        case LYRRecipientStatusRead:
            return @"Message Read";
            break;
            
        default:
            break;
    }
    return nil;
}

- (BOOL)converationViewController:(LYRUIConversationViewController *)conversationViewController shouldUpdateRecipientStatusForMessage:(LYRMessage *)message
{
    return NO;
}

@end
