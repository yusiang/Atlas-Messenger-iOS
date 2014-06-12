//
//  LYRSynchronizationDataSource.h
//  LayerKit
//
//  Created by Klemen Verdnik on 25/04/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRSynchronizationDataSource.h"

@interface LYRSynchronizationDataSource ()

/**
 @abstract Collects and returns a set of events that cannot be published to the server, since their streams haven't been created on the server yet.
 @param database Database reference.
 @param error An error object describing the failure that was encountered.
 @return A set of event objects in a form of `LYREvent` instances; empty set, if the operation yielded no results; `nil` in case of a failure.
 */
- (NSSet *)unpublishableEventsInDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

@end
