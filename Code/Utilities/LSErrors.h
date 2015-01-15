//
//  LSErrors.h
//  LayerSample
//
//  Created by Kevin Coleman on 9/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const LSErrorDomain;

typedef NS_ENUM(NSUInteger, LSAuthenticationError) {
    LSErrorUnknownError                            = 7000,
    
    /* Messaging Errors */
    LSInvalidFirstName                              = 7001,
    LSInvalidLastName                               = 7002,
    LSInvalidEmailAddress                           = 7003,
    LSInvalidPassword                               = 7004,
    LSInvalidAuthenticationNonce                    = 7005,
    LSNoAuthenticatedSession                        = 7006,
};
