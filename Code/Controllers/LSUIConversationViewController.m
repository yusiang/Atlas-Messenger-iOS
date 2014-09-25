//
//  LSUIConversationViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSUIConversationViewController.h"

@interface LSUIConversationViewController () <LYRUIConversationViewControllerDataSource>

@end

@implementation LSUIConversationViewController

static NSDateFormatter *dateFormatter;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    self.dataSource = self;
}

- (id<LYRUIParticipant>)conversationViewController:(LYRUIConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier
{
    NSSet *set = [self.persistenceManager participantsForIdentifiers:[NSSet setWithObject:participantIdentifier]];
    return [[set allObjects] firstObject];
}

- (NSString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date
{
    [dateFormatter setDateFormat:@"MMM dd, hh:mma"];
    return [dateFormatter stringFromDate:date];
}

- (NSString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus
{
    NSArray *recipients = [recipientStatus allKeys];
    NSInteger status = [[recipientStatus valueForKey:[recipients lastObject]] integerValue];
    switch (status) {
        case LYRRecipientStatusInvalid:
            return @"Message Not Sent";
            break;
        case LYRRecipientStatusSent:
            return @"Sent";
            break;
        case LYRRecipientStatusDelivered:
            return @"Delivered";
            break;
        case LYRRecipientStatusRead:
            return @"Message Read";
            break;
        default:
            break;
    }
    return nil;
}

@end
