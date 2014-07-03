//
//  LSMessageCellPresenter.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSMessageCellPresenter.h"

@interface LSMessageCellPresenter ()

@property (nonatomic, strong) LSPersistenceManager *persistenceManager;

@end

@implementation LSMessageCellPresenter

+ (instancetype)presenterWithMessage:(LYRMessage *)message persistanceManager:(LSPersistenceManager *)persistenceManager
{
    return [[self alloc] initWithMessage:message persistenceManager:persistenceManager];
}

- (id)initWithMessage:(LYRMessage *)message persistenceManager:(LSPersistenceManager *)persistenceManager
{
    self = [super init];
    if (self) {
        _message = message;
        _persistenceManager = persistenceManager;
    }
    return self;
}

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

- (NSString *)labelForMessageSender
{
    NSError *error;
    LSSession *session = [self.persistenceManager persistedSessionWithError:&error];
    LSUser *authenticatedUser = session.user;
    return authenticatedUser.fullName;
}

- (UIImage *)imageForMessageSender
{
    return [UIImage imageNamed:@"kevin"];
}

@end
