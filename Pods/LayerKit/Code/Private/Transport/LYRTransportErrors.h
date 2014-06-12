//
//  LYRTransportErrors.h
//  LayerKit
//
//  Created by Blake Watters on 5/16/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRErrors.h"
#import "TBase.h"

/**
 The domain for errors emitted at the transport layer.
 */
extern NSString *const LYRTransportErrorDomain;
extern NSString *const LYRTransportErrorExceptionUserInfoKey;
extern NSString *const LYRTransportErrorAuthenticationNonceUserInfoKey;

typedef NS_ENUM(NSUInteger, LYRTransportError) {
    LYRTransportErrorProtocolException              = 4000, /* An exception was returned in the Thrift response */
    LYRTransportErrorAuthenticationChallenge        = 4001, /* An authentication challenge was encountered */
    LYRTransportErrorUnprocessableResponse          = 4002, /* A response was encountered that could not be processed */
    LYRTransportErrorNotConnected                   = 4003, /* A network failure has occurred */
    LYRTransportErrorNoAuthenticationRealm          = 4004, /* Transport manager is missing the realm */
};

NSError *LYRTransportErrorFromThriftException(NSException<TBase> *exception);
