//
//  LYRConcurrentOperationStateMachine.m
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "TransitionKit.h"
#import "LYRConcurrentOperationStateMachine.h"

NSString *const LYRConcurrentOperationFailureException = @"LYRConcurrentOperationFailureException";

static NSString *const LYRConcurrentOperationStateReady = @"Ready";
static NSString *const LYRConcurrentOperationStateExecuting = @"Executing";
static NSString *const LYRConcurrentOperationStateFinished = @"Finished";

static NSString *const LYRConcurrentOperationEventStart = @"start";
static NSString *const LYRConcurrentOperationEventFinish = @"finish";

static NSString *const LYRConcurrentOperationLockName = @"org.restkit.operation.lock";

@interface LYRConcurrentOperationStateMachine ()
@property (nonatomic, strong) TKStateMachine *stateMachine;
@property (nonatomic, weak, readwrite) NSOperation *operation;
@property (nonatomic, assign, readwrite) dispatch_queue_t dispatchQueue;
@property (nonatomic, assign, getter = isCancelled) BOOL cancelled;
@property (nonatomic, copy) void (^cancellationBlock)(void);
@property (nonatomic, strong) NSRecursiveLock *lock;
@end

@implementation LYRConcurrentOperationStateMachine

- (id)initWithOperation:(NSOperation *)operation dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    if (! operation) [NSException raise:NSInvalidArgumentException format:@"Invalid argument: `operation` cannot be nil."];
    if (! dispatchQueue) [NSException raise:NSInvalidArgumentException format:@"Invalid argument: `dispatchQueue` cannot be nil."];
    self = [super init];
    if (self) {
        self.operation = operation;
        self.dispatchQueue = dispatchQueue;
        self.stateMachine = [TKStateMachine new];
        self.lock = [NSRecursiveLock new];
        [self.lock setName:LYRConcurrentOperationLockName];
        
        // NOTE: State transitions are guarded by a lock via start/finish/cancel action methods
        TKState *readyState = [TKState stateWithName:LYRConcurrentOperationStateReady];
        __weak __typeof(&*self)weakSelf = self;
        [readyState setWillExitStateBlock:^(TKState *state, TKTransition *transition) {
            [weakSelf.operation willChangeValueForKey:@"isReady"];
        }];
        [readyState setDidExitStateBlock:^(TKState *state, TKTransition *transition) {
            [weakSelf.operation didChangeValueForKey:@"isReady"];
        }];
        
        TKState *executingState = [TKState stateWithName:LYRConcurrentOperationStateExecuting];
        [executingState setWillEnterStateBlock:^(TKState *state, TKTransition *transition) {
            [weakSelf.operation willChangeValueForKey:@"isExecuting"];
        }];
        // NOTE: isExecuting KVO for `setDidEnterStateBlock:` configured below in `setExecutionBlock`
        [executingState setWillExitStateBlock:^(TKState *state, TKTransition *transition) {
            [weakSelf.operation willChangeValueForKey:@"isExecuting"];
        }];
        [executingState setDidExitStateBlock:^(TKState *state, TKTransition *transition) {
            [weakSelf.operation didChangeValueForKey:@"isExecuting"];
        }];
        [executingState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
            [NSException raise:NSInternalInconsistencyException format:@"You must configure an execution block via `setExecutionBlock:`."];
        }];
        
        TKState *finishedState = [TKState stateWithName:LYRConcurrentOperationStateFinished];
        [finishedState setWillEnterStateBlock:^(TKState *state, TKTransition *transition) {
            [weakSelf.operation willChangeValueForKey:@"isFinished"];
        }];
        [finishedState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
            [weakSelf.operation didChangeValueForKey:@"isFinished"];
        }];
        [finishedState setWillExitStateBlock:^(TKState *state, TKTransition *transition) {
            [weakSelf.operation willChangeValueForKey:@"isFinished"];
        }];
        [finishedState setDidExitStateBlock:^(TKState *state, TKTransition *transition) {
            [weakSelf.operation didChangeValueForKey:@"isFinished"];
        }];
        
        [self.stateMachine addStates:@[ readyState, executingState, finishedState ]];
        
        TKEvent *startEvent = [TKEvent eventWithName:LYRConcurrentOperationEventStart transitioningFromStates:@[ readyState ] toState:executingState];
        TKEvent *finishEvent = [TKEvent eventWithName:LYRConcurrentOperationEventFinish transitioningFromStates:@[ executingState ] toState:finishedState];
        [self.stateMachine addEvents:@[ startEvent, finishEvent ]];
        
        self.stateMachine.initialState = readyState;
        [self.stateMachine activate];
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke initWithOperation: instead.",
                                           NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (BOOL)isReady
{
    return [self.stateMachine isInState:LYRConcurrentOperationStateReady];
}

- (BOOL)isExecuting
{
    return [self.stateMachine isInState:LYRConcurrentOperationStateExecuting];
}

- (BOOL)isFinished
{
    return [self.stateMachine isInState:LYRConcurrentOperationStateFinished];
}

- (void)start
{
    if (! self.dispatchQueue) [NSException raise:NSInternalInconsistencyException format:@"You must configure an `operationQueue`."];
    [self performBlockWithLock:^{
        NSError *error = nil;
        BOOL success = [self.stateMachine fireEvent:LYRConcurrentOperationEventStart userInfo:nil error:&error];
        if (! success) [NSException raise:LYRConcurrentOperationFailureException format:@"The operation unexpectedly failed to start due to an error: %@", error];
    }];
}

- (void)finish
{
    // Ensure that we are finished from the operation queue
    dispatch_async(self.dispatchQueue, ^{
        [self performBlockWithLock:^{
            NSError *error = nil;
            BOOL success = [self.stateMachine fireEvent:LYRConcurrentOperationEventFinish userInfo:nil error:&error];
            if (! success) [NSException raise:LYRConcurrentOperationFailureException format:@"The operation unexpectedly failed to finish due to an error: %@", error];
        }];
    });
}

- (void)cancel
{
    if ([self isCancelled] || [self isFinished]) return;
    [self performBlockWithLock:^{
        self.cancelled = YES;
    }];
    
    if (self.cancellationBlock) {
        dispatch_async(self.dispatchQueue, ^{
            [self performBlockWithLock:self.cancellationBlock];
        });
    }
}

- (void)setExecutionBlock:(void (^)(void))block
{
    __weak __typeof(&*self)weakSelf = self;
    TKState *executingState = [self.stateMachine stateNamed:LYRConcurrentOperationStateExecuting];
    [executingState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        [weakSelf.operation didChangeValueForKey:@"isExecuting"];
        dispatch_async(weakSelf.dispatchQueue, ^{
            block();
        });
    }];
}

- (void)setFinalizationBlock:(void (^)(void))block
{
    __weak __typeof(&*self)weakSelf = self;
    TKState *finishedState = [self.stateMachine stateNamed:LYRConcurrentOperationStateFinished];
    [finishedState setWillEnterStateBlock:^(TKState *state, TKTransition *transition) {
        [weakSelf performBlockWithLock:^{
            // Must emit KVO as we are replacing the block configured in `initWithOperation:queue:`
            [weakSelf.operation willChangeValueForKey:@"isFinished"];
            block();
        }];
    }];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p (for %@:%p), state: %@, cancelled: %@>",
            [self class], self,
            [self.operation class], self.operation,
            self.stateMachine.currentState.name,
            ([self isCancelled] ? @"YES" : @"NO")];
}

- (void)performBlockWithLock:(void (^)())block
{
    [self.lock lock];
    block();
    [self.lock unlock];
}

@end
