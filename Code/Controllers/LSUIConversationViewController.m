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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id<LYRUIParticipant>)conversationViewController:(LYRUIConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier
{
    NSSet *set = [self.persistenceManager participantsForIdentifiers:[NSSet setWithObject:participantIdentifier]];
    return [[set allObjects] firstObject];
}

- (NSString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date
{
    [dateFormatter setDateFormat:@"MMM dd, hh:mma"];
    NSString *dateLabel = [dateFormatter stringFromDate:date];
    return dateLabel;

}

- (NSString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus
{
    NSArray *recipients = [recipientStatus allKeys];
    NSInteger status = [[recipientStatus valueForKey:[recipients firstObject]] integerValue];
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
