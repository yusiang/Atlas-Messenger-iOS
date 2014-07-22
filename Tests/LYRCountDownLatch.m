//
//  LYRCountDownLatch.m
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRCountDownLatch.h"

@interface LYRCountDownLatch ()
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
@property (nonatomic, assign) NSUInteger initialCount;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, strong) NSDate *timeoutDate;
@end

@implementation LYRCountDownLatch

+ (instancetype)latchWithCount:(NSUInteger)count timeoutInterval:(NSTimeInterval)timeoutInterval
{
    return [[self alloc] initWithCount:count timeoutInterval:timeoutInterval];
}

- (id)initWithCount:(NSUInteger)count timeoutInterval:(NSTimeInterval)timeoutInterval
{
	if (self) {
        _initialCount = count;
        _count = count;
        _timeoutInterval = timeoutInterval;
        _dispatchQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (id)init
{
	return [self initWithCount:1 timeoutInterval:1.0];
}

- (void)decrementCount
{
    dispatch_barrier_sync(self.dispatchQueue, ^{
        if (_count == 0) [NSException raise:NSInternalInconsistencyException format:@"Attempt to decrement count below zero"];
        _count--;
        self.timeoutDate = [NSDate dateWithTimeIntervalSinceNow:self.timeoutInterval];
    });
}

- (void)wait
{
    return [self waitTilCount:0];
}

- (BOOL)timedOut
{
    __block BOOL timedOut = NO;
    dispatch_sync(self.dispatchQueue, ^{
        timedOut = (_timeoutDate && [(NSDate *)[NSDate date] compare:_timeoutDate] == NSOrderedDescending);
    });
    return timedOut;
}

- (void)waitTilCount:(NSUInteger)desiredCount
{
    if (self.timedOut) return;
    
    self.timeoutDate = [NSDate dateWithTimeIntervalSinceNow:self.timeoutInterval];
    __block BOOL waiting = true;
    while (waiting && !self.timedOut) {
        dispatch_sync(_dispatchQueue, ^{
            waiting = _count > desiredCount;
        });
        if (waiting) [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
    }
    if (!waiting) self.timeoutDate = nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ initialCount=%lu, timeoutInterval=%.02f. count=%lu>", [self class], (unsigned long)self.initialCount, self.timeoutInterval, (unsigned long)self.count];
}

@end
