//
//  LYRCountDownLatch.h
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The `LYRCountDownLatch` class is an Objective-C implementation of the `CountDownLatch` class from Java.
 It is useful for coordinating the
 */
@interface LYRCountDownLatch : NSObject

+ (instancetype)latchWithCount:(NSUInteger)count timeoutInterval:(NSTimeInterval)timeoutInterval;
@property (nonatomic, assign, readonly) NSUInteger count;
@property (nonatomic, readonly) BOOL timedOut;
- (void)decrementCount;


- (void)waitTilCount:(NSUInteger)desiredCount;
- (void)wait;

@end
