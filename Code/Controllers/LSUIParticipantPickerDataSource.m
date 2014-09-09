//
//  LSUIParticipantPickerDataSource.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSUIParticipantPickerDataSource.h"

@interface LSUIParticipantPickerDataSource ()

@property (nonatomic, strong) LSPersistenceManager *persistenceManager;

@end

@implementation LSUIParticipantPickerDataSource

@synthesize participants = _participants;

+ (instancetype)participantPickerDataSourceWithPersistenceManager:(LSPersistenceManager *)persistenceManager
{
    return [[self alloc] initWithPersistenceManager:persistenceManager];
}

- (id)initWithPersistenceManager:(LSPersistenceManager *)persistenceManager
{
    self = [super init];
    if (self) {
        
        _persistenceManager = persistenceManager;
        
        NSError *error;
        _participants = [persistenceManager persistedUsersWithError:&error];
        
    }
    return self;
}

- (void)searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(fullName like[cd] %@)", [NSString stringWithFormat:@"*%@*", searchText]];
    completion([self.participants filteredSetUsingPredicate:searchPredicate]);
}

- (NSSet *)participants
{
    return _participants;
}

@end
