//
//  LYRTestSPDYTrustEvaluator.h
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPDYTLSTrustEvaluator.h"

@interface LYRTestSPDYTrustEvaluator : NSObject <SPDYTLSTrustEvaluator>
+ (instancetype)sharedTrustEvaluator;
@end
