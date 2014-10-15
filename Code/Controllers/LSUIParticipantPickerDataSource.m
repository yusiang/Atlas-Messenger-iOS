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
@property (nonatomic) NSPredicate *searchPredicate;

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
    }
    return self;
}

- (id)init
{
     @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}

- (void)searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    // KC TODO - Cache this predicate but not sure how?
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(fullName like[cd] %@)", [NSString stringWithFormat:@"*%@*", searchText]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.persistenceManager persistedUsersWithError:nil];
        NSSet *filteredParticipants = [[self participants] filteredSetUsingPredicate:searchPredicate];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(filteredParticipants);
        });
    });
}

- (NSSet *)participants
{
    return [self.persistenceManager persistedUsersWithError:nil];
}

@end
