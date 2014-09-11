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
//    NSCalendar* calendar = [NSCalendar currentCalendar];
//    
//    unsigned int conversationDateFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
//    NSDateComponents* conversationDateComponents = [calendar components:conversationDateFlags fromDate:date];
//    NSDate *conversationDate = [calendar dateFromComponents:conversationDateComponents];
//    
//    unsigned int currentDateFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
//    NSDateComponents* currentDateComponents = [calendar components:currentDateFlags fromDate:[NSDate date]];
//    NSDate *currentDate = [calendar dateFromComponents:currentDateComponents];

    [dateFormatter setDateFormat:@"MMM dd, hh:mma"];
    NSString *dateLabel = [dateFormatter stringFromDate:date];
    return dateLabel;

}

- (NSString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForOfRecipientStatus:(LYRRecipientStatus)recipientStatus forMessage:(LYRMessage *)message atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
