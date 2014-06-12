//
//  LYRErrors.h
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const LYRErrorDomain;

typedef NS_ENUM(NSUInteger, LYRError) {
    LYRErrorUnknownError = 1000,
    
    /* Messaging Errors */
    LYRErrorInvalidMessage              = 1001,
    LYRErrorTooManyParticipants         = 1002,
    LYRErrorDataLengthExceedsMaximum    = 1003,
};
