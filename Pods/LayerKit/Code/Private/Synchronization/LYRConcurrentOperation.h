//
//  LYRConcurrentOperation.h
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRConcurrentOperationStateMachine.h"

@protocol LYROperationDelegate;

@interface LYRConcurrentOperation : NSOperation

+ (dispatch_queue_t)dispatchQueue;

@property (nonatomic, strong, readonly) LYRConcurrentOperationStateMachine *stateMachine;
@property (nonatomic, weak) id<LYROperationDelegate> delegate;

- (id)initWithDelegate:(id<LYROperationDelegate>)delegate;

// Entry point for operation. Must be implemented by subclass.
- (void)execute;
- (void)finish;

@end

@protocol LYROperationDelegate <NSObject>

@required
- (BOOL)operation:(NSOperation *)operation shouldFailDueToError:(NSError *)error;

@end