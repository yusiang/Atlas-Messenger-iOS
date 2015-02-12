//
//  LSParticipantDataSource
//  LayerSample
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSPersistenceManager.h"

/**
 @abstract Data source for the `LYRUIParticipantPicker`. Supplies a list of objects conforming to the `LYRUIParticipant`
 protocol to the picker.
 */
@interface LSParticipantDataSource : NSObject

/**
 @abstract Designated initializer for the receiver. Calling `init` will raise NSInternalInconsistencyException.
 */
+ (instancetype)participantPickerDataSourceWithPersistenceManager:(LSPersistenceManager *)persistenceManager;


- (void)participantsMatchingSearchText:(NSString *)searchText completion:(void(^)(NSSet *participants))completion;
         
@property (nonatomic) NSSet *participants;

/**
 @abstract The `NSSet` of user identifiers to be excluded from the pariticipant picker. 
 @discussion Typically this will be the set of identifiers for a given conversation.
 */
@property (nonatomic) NSSet *excludedIdentifiers;

@end
