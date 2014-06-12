//
//  LYRPublishEventsOperation.h
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRConcurrentOperation.h"

@interface LYRPublishEventsOperation : LYRConcurrentOperation

- (id)initWithBaseURL:(NSURL *)baseURL URLSession:(NSURLSession *)URLSession eventsByStreamID:(NSDictionary *)eventsByStreamID delegate:(id<LYROperationDelegate>)delegate;

/**
 @abstract
 */
@property (nonatomic, readonly) NSMapTable *sequencesByEvent;

// `nil` if no errors...
@property (nonatomic, readonly) NSMapTable *errorsByEvent;

@end
