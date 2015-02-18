//
//  ATLMParticipantDataSource
//  Atlas Messenger
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATLMPersistenceManager.h"

/**
 @abstract Data source for the `ATLMParticipantTableViewController`. Supplies a list of objects conforming to the `ATLMParticipant`
 protocol to the picker.
 */
@interface ATLMParticipantDataSource : NSObject

/**
 @abstract Designated initializer for the receiver. Calling `init` will raise NSInternalInconsistencyException.
 */
+ (instancetype)participantPickerDataSourceWithPersistenceManager:(ATLMPersistenceManager *)persistenceManager;

/**
 @abstract A set of participants conforming to the `ATLMParticipant` protocol.
 */
@property (nonatomic) NSSet *participants;

/**
 @abstract The `NSSet` of user identifiers to be excluded from the pariticipant set.
 @discussion Typically this will be the set of identifiers for a given conversation.
 */
@property (nonatomic) NSSet *excludedIdentifiers;

/**
 @abstract Searches for participants matching the provided search text.
 @param searchText The search text for which the search will be performed. 
 @param completion The completion block to be called upon completion of search. 
 */
- (void)participantsMatchingSearchText:(NSString *)searchText completion:(void(^)(NSSet *participants))completion;

@end
