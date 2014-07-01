//
//  LSMessageCellPresenter.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSMessageCellPresenter.h"

@implementation LSMessageCellPresenter

- (BOOL)messageWasSentByAuthenticatedUser
{
    NSError *error;
    LSSession *session = [self.persistenceManager persistedSessionWithError:&error];
    LSUser *authenticatedUser = session.user;
    
    if ([self.message.sentByUserID isEqualToString:authenticatedUser.userID]) {
        return YES;
    }
    
    return NO;
}

- (NSString *)senderLabel
{
    NSError *error;
    LSSession *session = [self.persistenceManager persistedSessionWithError:&error];
    LSUser *authenticatedUser = session.user;
    return authenticatedUser.fullName;
}

@end
