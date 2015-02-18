//
//  ATLMErrors.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 9/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const ATLMErrorDomain;

typedef NS_ENUM(NSUInteger, ATLMAuthenticationError) {
    ATLMErrorUnknownError                            = 7000,
    
    /* Messaging Errors */
    ATLMInvalidFirstName                              = 7001,
    ATLMInvalidLastName                               = 7002,
    ATLMInvalidEmailAddress                           = 7003,
    ATLMInvalidPassword                               = 7004,
    ATLMInvalidAuthenticationNonce                    = 7005,
    ATLMNoAuthenticatedSession                        = 7006,
    ATLMRequestInProgress                             = 7007
};
