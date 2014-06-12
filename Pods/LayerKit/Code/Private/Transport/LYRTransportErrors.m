//
//  LYRTransportErrors.m
//  LayerKit
//
//  Created by Blake Watters on 5/16/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRTransportErrors.h"
#import "LYRAuthenticationChallenge.h"

NSString *const LYRTransportErrorDomain = @"com.layer.LayerKit.Transport";
NSString *const LYRTransportErrorExceptionUserInfoKey = @"exception";
NSString *const LYRTransportErrorAuthenticationNonceUserInfoKey = @"nonce";

NSError *LYRTransportErrorFromThriftException(NSException<TBase> *exception)
{
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"An exception was encountered.", LYRTransportErrorExceptionUserInfoKey: exception };
    return [NSError errorWithDomain:LYRErrorDomain code:LYRTransportErrorProtocolException userInfo:userInfo];
}
