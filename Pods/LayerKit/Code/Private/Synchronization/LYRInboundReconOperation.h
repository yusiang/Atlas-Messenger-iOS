//
//  LYRInboundReconOperation.h
//  LayerKit
//
//  Created by Klemen Verdnik on 12/05/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRSynchronizationDataSource.h"
#import "LYRConcurrentOperation.h"

@interface LYRInboundReconOperation : NSOperation

- (id)initWithDataSource:(LYRSynchronizationDataSource *)dataSource delegate:(id<LYROperationDelegate>)delegate;

@property (nonatomic, readonly) NSUInteger changes;
@property (nonatomic, readonly) NSError *error;

@end
