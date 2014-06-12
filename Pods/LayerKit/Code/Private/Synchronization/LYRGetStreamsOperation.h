//
//  LYRGetStreamsOperation.h
//  LayerKit
//
//  Created by Blake Watters on 4/27/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRConcurrentOperation.h"
#import "LYRSynchronizationErrors.h"

/**
 
 */
@interface LYRGetStreamsOperation : LYRConcurrentOperation

- (id)initWithBaseURL:(NSURL *)baseURL URLSession:(NSURLSession *)URLSession userID:(NSUUID *)userID delegate:(id<LYROperationDelegate>)delegate;

@property (nonatomic, strong, readonly) NSUUID *userID;
@property (nonatomic, strong, readonly) NSArray *streams;
@property (nonatomic, strong, readonly) NSError *error;

@end
