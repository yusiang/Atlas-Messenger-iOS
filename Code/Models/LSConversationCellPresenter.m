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

@end

@implementation LSConversationCellPresenter

- (NSString *)conversationLabel
{

    self.participantNames = [self fullNamesForParticiapnts:self.conversation.participants];

    NSArray *sortedFullNames = [self.participantNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSString *conversationLabel = [self conversationLabelForNames:sortedFullNames];

    return conversationLabel;
}

- (NSString *)conversationLabelForNames:(NSArray *)names
{
    NSString *conversationLabel;
    if (names.count > 0) {
        conversationLabel = [names objectAtIndex:0];
        for (int i = 1; i < names.count; i++) {
            conversationLabel = [NSString stringWithFormat:@"%@, %@", conversationLabel, [names objectAtIndex:i]];
        }
    }
    return conversationLabel;
}

- (UIImage *)imageForAuthenticatedUser
{
    return nil;
}

- (NSMutableArray *)fullNamesForParticiapnts:(NSSet *)participants
{
    NSError *error;
    LSSession *session = [self.persistenceManager persistedSessionWithError:&error];
    LSUser *authenticatedUser = session.user;
    
    NSMutableArray *fullNames = [NSMutableArray new];
    NSSet *persistedUsers = [self.persistenceManager persistedUsersWithError:&error];
    for (NSString *userID in participants) {
        for (LSUser *persistedUser in persistedUsers) {
            if ([userID isEqualToString:persistedUser.userID] && ![userID isEqualToString:authenticatedUser.userID]) {
                [fullNames addObject:persistedUser.fullName];
            }
        }
    }

    return fullNames;
}

@end
