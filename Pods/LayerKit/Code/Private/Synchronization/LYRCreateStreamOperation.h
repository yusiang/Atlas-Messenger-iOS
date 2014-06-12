//
//  LYRCreateStreamOperation.h
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRConcurrentOperation.h"
#import "messaging.h"

@interface LYRCreateStreamOperation : LYRConcurrentOperation

- (id)initWithBaseURL:(NSURL *)baseURL URLSession:(NSURLSession *)URLSession delegate:(id<LYROperationDelegate>)delegate;

@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, strong, readonly) LYRTStream *stream;

@end
