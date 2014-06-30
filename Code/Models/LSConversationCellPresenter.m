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
    if (!self.participantNames) {
        self.participantNames = [self fullNamesForParticiapnts:self.conversation.participants];
    }
    
    NSArray *sortedFullNames = [self.participantNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSString *conversationLabel = [sortedFullNames objectAtIndex:0];
    for (int i = 1; i < sortedFullNames.count; i++) {
        conversationLabel = [NSString stringWithFormat:@"%@, %@", conversationLabel, [self.participantNames objectAtIndex:i]];
    }

    return conversationLabel;
}

- (UIImage *)imageForAuthenticatedUser
{
    return nil;
}

- (NSMutableArray *)fullNamesForParticiapnts:(NSSet *)participants
{
    NSMutableArray *fullNames = [NSMutableArray new];
    NSArray *persistedUsers = [self.persistenceManager.persistedUsers allObjects];
    for (NSString *userID in participants) {
        for (LSUser *persistedUser in persistedUsers) {
            if ([userID isEqualToString:persistedUser.userID]) {
                [fullNames addObject:persistedUser.fullName];
            }
        }
    }
    return fullNames;
}

@end
