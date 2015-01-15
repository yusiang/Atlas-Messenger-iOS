//
//  LSUIParticipantPickerDataSource.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSUIParticipantPickerDataSource.h"

@interface LSUIParticipantPickerDataSource ()

@property (nonatomic) LSPersistenceManager *persistenceManager;

@end

@implementation LSUIParticipantPickerDataSource

+ (instancetype)participantPickerDataSourceWithPersistenceManager:(LSPersistenceManager *)persistenceManager
{
    return [[self alloc] initWithPersistenceManager:persistenceManager];
}

- (id)initWithPersistenceManager:(LSPersistenceManager *)persistenceManager
{
    self = [super init];
    if (self) {
        _persistenceManager = persistenceManager;
    }
    return self;
}

- (id)init
{
     @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}

#pragma mark - LYRUIParticipantPickerDataSource

- (void)participantPickerController:(LYRUIParticipantPickerController *)participantPickerController searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    [self.persistenceManager performUserSearchWithString:searchText completion:^(NSArray *users, NSError *error) {
        NSPredicate *exclusionPredicate = [NSPredicate predicateWithFormat:@"NOT participantIdentifier IN %@", self.excludedIdentifiers];
        NSArray *availableParticipants = [users filteredArrayUsingPredicate:exclusionPredicate];
        completion([NSSet setWithArray:availableParticipants]);
    }];
}

- (NSSet *)participantsForParticipantPickerController:(LYRUIParticipantPickerController *)participantPickerController
{
    NSMutableSet *participants = [[self.persistenceManager persistedUsersWithError:nil] mutableCopy];
    NSSet *participantsToExclude = [self.persistenceManager usersForIdentifiers:self.excludedIdentifiers];
    [participants minusSet:participantsToExclude];
    return participants;
}

@end
