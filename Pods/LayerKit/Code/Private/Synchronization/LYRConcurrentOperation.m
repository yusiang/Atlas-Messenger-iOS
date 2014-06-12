//
//  LYRConcurrentOperation.m
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRConcurrentOperation.h"

@implementation LYRConcurrentOperation

+ (dispatch_queue_t)dispatchQueue
{
    static dispatch_queue_t dispatchQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatchQueue = dispatch_queue_create("com.layer.synchronization.operation-dispatch-queue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return dispatchQueue;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Failed to call designated initializer: Call `%@` instead.", NSStringFromSelector(@selector(initWithDelegate:))]
                                 userInfo:nil];
}

- (id)initWithDelegate:(id<LYROperationDelegate>)delegate
{
    self = [super init];
    if (self) {
        if (!delegate) [NSException exceptionWithName:NSInternalInconsistencyException reason:@"LYRConcurrentOperation needs a valid delegate" userInfo:nil];
        else _delegate = delegate;
        __weak __typeof(&*self)weakSelf = self;
        _stateMachine = [[LYRConcurrentOperationStateMachine alloc] initWithOperation:self dispatchQueue:[[self class] dispatchQueue]];
        NSString *operationIdentity = [NSString stringWithFormat:@"<%@:%p>", [weakSelf class], weakSelf];
        [self.stateMachine setFinalizationBlock:^{
            LYRLogDebug(@"%@ finished.%@", operationIdentity, (weakSelf.isCancelled) ? @" (cancelled)" : @"");
        }];
        [self.stateMachine setExecutionBlock:^{
            if (weakSelf.isCancelled) {
                [weakSelf.stateMachine finish];
            } else {
                LYRLogDebug(@"%@ starting...", operationIdentity);
                [weakSelf execute];
            }
        }];
    }
    return self;
}

#pragma mark - NSOperation

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isReady
{
    return [self.stateMachine isReady] && [super isReady];
}

- (BOOL)isExecuting
{
    return [self.stateMachine isExecuting];
}

- (BOOL)isFinished
{
    return [self.stateMachine isFinished];
}

- (void)start
{
    [self.stateMachine start];
}

- (void)cancel
{
    [super cancel];
    [self.stateMachine cancel];
}

#pragma mark - Subclass Hooks

- (void)finish
{
    [self.stateMachine finish];
}

- (void)execute
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Subclass must implement `%@`", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
