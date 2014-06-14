//
//  LYRTestSPDYTrustEvaluator.m
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRTestSPDYTrustEvaluator.h"

@implementation LYRTestSPDYTrustEvaluator

+ (instancetype)sharedTrustEvaluator
{
    static LYRTestSPDYTrustEvaluator *trustEvaluator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        trustEvaluator = [LYRTestSPDYTrustEvaluator new];
    });
    return trustEvaluator;
}

- (BOOL)evaluateServerTrust:(SecTrustRef)trust forHost:(NSString *)host
{
    return YES;
}

@end