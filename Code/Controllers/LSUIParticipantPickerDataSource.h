//
//  LSUIParticipantPickerDataSource.h
//  LayerSample
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRUIParticipantPickerController.h"
#import "LSPersistenceManager.h"

/**
 @abstract Data source for the `LYRUIParticipantPicker. Supplies a list of object conforming to the `LYRUIParticipant`
 protocol to the to the picker.
 */
@interface LSUIParticipantPickerDataSource : NSObject <LYRUIParticipantPickerDataSource>

/**
 @abstract Designated initializer for the receiver. Calling `init` will raise NSInternalInconsistencyException
 */
+ (instancetype)participantPickerDataSourceWithPersistenceManager:(LSPersistenceManager *)persistenceManager;

/**
 @abstract The `NSSet` of user identifiers to be excluded from the pariticipant picker. 
 @discussion Typically this will be the set of identifiers for a given conversation.
 */
@property (nonatomic) NSSet *excludedIdentifiers;

@end
