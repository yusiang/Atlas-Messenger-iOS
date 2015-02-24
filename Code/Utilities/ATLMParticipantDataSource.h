//
//  ATLMParticipantDataSource
//  Atlas Messenger
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import "ATLMPersistenceManager.h"

/**
 @abstract The `ATLMParticipantDataSource` provides an interface for querying the Atlas Messenger persistence layer for `ATLMUser` objects. It also provides the ability to filter participants via the `excludedIdentifiers` property.
 */
@interface ATLMParticipantDataSource : NSObject

/**
 @abstract Designated initializer for the receiver. Calling `init` will raise NSInternalInconsistencyException.
 */
+ (instancetype)participantDataSourceWithPersistenceManager:(ATLMPersistenceManager *)persistenceManager;

/**
 @abstract A set of participants conforming to the `ATLMParticipant` protocol.
 */
@property (nonatomic) NSSet *participants;

/**
 @abstract The `NSSet` of user identifiers to be excluded from the participant set and queries.
 @discussion Typically this will be the set of identifiers for a given conversation.
 */
@property (nonatomic) NSSet *excludedIdentifiers;

/**
 @abstract Queries the receiver for a user with a `participantIdentifier` matching the supplied identifier.
 @return An object confroming to the `ATLParticipant` protocol or `nil` if no match is found.
 */
- (id<ATLParticipant>)participantForIdentifier:(NSString *)identifier;

/**
 @abstract Searches for participants matching the provided search text.
 @param searchText The search text for which the search will be performed. 
 @param completion The completion block to be called upon completion of search. The block has no return value and accepts one argument: an `NSSet` of objects conforming to the `ATLParticipant` protocol.
 */
- (void)participantsMatchingSearchText:(NSString *)searchText completion:(void(^)(NSSet *participants))completion;

@end
