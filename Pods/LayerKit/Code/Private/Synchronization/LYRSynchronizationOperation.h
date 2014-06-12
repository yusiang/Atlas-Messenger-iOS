//
//  LYRSynchronizationOperation.h
//  LayerKit
//
//  Created by Blake Watters on 4/30/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRConcurrentOperation.h"
#import "LYRSynchronizationDataSource.h"

@interface LYRSynchronizationOperation : LYRConcurrentOperation

- (id)initWithBaseURL:(NSURL *)baseURL URLSession:(NSURLSession *)URLSession dataSource:(LYRSynchronizationDataSource *)dataSource delegate:(id<LYROperationDelegate>)delegate;

@property (nonatomic, readonly) NSError *error;

@end
