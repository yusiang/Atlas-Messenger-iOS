//
//  LYRSynchronizationErrors.h
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRErrors.h"
#import "LYRTransportErrors.h"

extern NSString *const LYRSynchronizationErrorDomain;

typedef NS_ENUM(NSUInteger, LYRSynchronizationError) {
    LYRSynchronizationErrorUnprocessableSyncableChange    = 9000,
};
