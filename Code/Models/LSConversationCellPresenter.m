//
//  LSConversationCellPresenter.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationCellPresenter.h"
#import "LSUser.h"

@interface LSPersistenceManager ()

- (LSUser *)userWithIdentifier:(NSString *)userID;

@end

@interface LSConversationCellPresenter ()

@property (nonatomic, strong) LSPersistenceManager *persistenceManager;
@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation LSConversationCellPresenter

+ (instancetype)presenterWithConversation:(LYRConversation *)conversation
                                  message:(LYRMessage *)message
                            dateFormatter:(NSDateFormatter *)dateFormatter
                       persistanceManager:(LSPersistenceManager *)persistenceManager
{
    return [[self alloc] initWithConversation:conversation message:message dateFormatter:dateFormatter persistenceManager:persistenceManager];
}
            
- (id)initWithConversation:(LYRConversation *)conversation
                   message:(LYRMessage *)message
             dateFormatter:(NSDateFormatter *)dateFormatter
        persistenceManager:(LSPersistenceManager *)persistenceManager
{
    self = [super init];
    if (self) {
        _conversation = conversation;
        _message = message;
        _persistenceManager = persistenceManager;
        _dateFormatter = dateFormatter;
    }
    return self;
}

- (NSString *)conversationLabel
{
    NSArray *sortedParticipantNames = [self sortedFullNamesForParticiapnts:self.conversation.participants];
    return [self conversationLabelForParticipantNames:sortedParticipantNames];
}

- (UIImage *)conversationImage
{
    return nil;
}

- (NSString *)conversationDateLabel
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned int conversationDateFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents* conversationDateComponents = [calendar components:conversationDateFlags fromDate:self.conversation.lastMessage.sentAt];
    NSDate *conversationDate = [calendar dateFromComponents:conversationDateComponents];
    
    unsigned int currentDateFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents* currentDateComponents = [calendar components:currentDateFlags fromDate:[NSDate date]];
    NSDate *currentDate = [calendar dateFromComponents:currentDateComponents];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([conversationDate compare:currentDate] == NSOrderedAscending) {
        [formatter setDateFormat:@"MMM dd"];
    } else {
        [formatter setDateFormat:@"hh:mm a"];
    }
    return [formatter stringFromDate:self.conversation.lastMessage.sentAt];
}

- (NSArray *)sortedFullNamesForParticiapnts:(NSSet *)participantIDs
{
    NSError *error;
    LSSession *session = [self.persistenceManager persistedSessionWithError:&error];
    LSUser *authenticatedUser = session.user;
    
    NSMutableArray *fullNames = [NSMutableArray new];
    NSSet *persistedUsers = [self.persistenceManager persistedUsersWithError:&error];
    for (NSString *userID in participantIDs) {
        for (LSUser *persistedUser in persistedUsers) {
            if ([userID isEqualToString:persistedUser.userID] && ![userID isEqualToString:authenticatedUser.userID]) {
                [fullNames addObject:persistedUser.fullName];
            }
        }
    }
    return [fullNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSString *)conversationLabelForParticipantNames:(NSArray *)participantNames
{
    NSString *conversationLabel;
    if (participantNames.count > 0) {
        conversationLabel = [participantNames objectAtIndex:0];
        for (int i = 1; i < participantNames.count; i++) {
            conversationLabel = [NSString stringWithFormat:@"%@, %@", conversationLabel, [participantNames objectAtIndex:i]];
        }
    }
    return conversationLabel;
}
@end
