//
//  LYRSynchronizationManager.h
//  LayerKit
//
//  Created by Blake Watters on 4/25/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRSynchronizationDataSource.h"
#import "LYRConcurrentOperation.h"

@class LYRTransportManager;

typedef NS_ENUM(NSInteger, LYRSynchronizationPolicy) {
    LYRSYnchronizationPolicyOnDemand
};

@protocol LYRSynchronizationManagerDelegate;

@interface LYRSynchronizationManager : NSObject <LYROperationDelegate>

- (id)initWithBaseURL:(NSURL *)baseURL sessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration datasource:(LYRSynchronizationDataSource *)dataSource delegate:(id<LYRSynchronizationManagerDelegate>)delegate;

@property (nonatomic, weak) id<LYRSynchronizationManagerDelegate> delegate;
@property (nonatomic, assign) LYRSynchronizationPolicy synchronizationPolicy;
@property (nonatomic, readonly) NSOperationQueue *operationQueue;
@property (nonatomic) NSURLSessionConfiguration *sessionConfiguration;

/// @name Managing Synchronization State

- (void)start;
- (void)stop;
@property (nonatomic, readonly) BOOL isRunning;

///---------------------------
/// @name Executing Operations
///---------------------------

// Run the whole process
- (NSOperation *)execute;

- (NSOperation *)executeReconcilliationOperation;
- (NSOperation *)executeSynchronizationOperation;

@end

@protocol LYRSynchronizationManagerDelegate <NSObject>

@required
// Only called for non-recoverable errors
- (void)synchronizationManager:(LYRSynchronizationManager *)synchronizationManager didFailWithError:(NSError *)error;

@end
