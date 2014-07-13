//
//  LSMessageCellPresenter.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSMessageCellPresenter.h"

@interface LSMessageCellPresenter ()

@property (nonatomic) LSPersistenceManager *persistenceManager;
@property (nonatomic) NSIndexPath *indexPath;

@end

@implementation LSMessageCellPresenter

+ (instancetype)presenterWithMessage:(LYRMessage *)message indexPath:(NSIndexPath *)indexPath persistanceManager:(LSPersistenceManager *)persistenceManager
{
    return [[self alloc] initWithMessage:message indexPath:indexPath persistenceManager:persistenceManager];
}

- (id)initWithMessage:(LYRMessage *)message indexPath:(NSIndexPath *)indexPath persistenceManager:(LSPersistenceManager *)persistenceManager
{
    self = [super init];
    if (self) {
        _message = message;
        _persistenceManager = persistenceManager;
        _indexPath = indexPath;
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
    NSArray *persistedUsers = [[self.persistenceManager persistedUsersWithError:&error] allObjects];
    LSUser *sender;
    for (LSUser *user in persistedUsers) {
        if ([[user valueForKeyPath:@"userID"] isEqualToString:self.message.sentByUserID]) {
            sender = user;
        }
    }
    return sender.fullName;
}

- (UIImage *)imageForMessageSender
{
    return [UIImage imageNamed:@"kevin"];
}

- (NSUInteger)indexForPart
{
    return (NSUInteger)self.indexPath.row;
}

@end
