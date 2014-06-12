//
//  LYRGetStreamOperation.h
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRConcurrentOperation.h"
#import "messaging.h"

@interface LYRGetStreamOperation : LYRConcurrentOperation

- (id)initWithBaseURL:(NSURL *)baseURL URLSession:(NSURLSession *)URLSession streamID:(NSUUID *)streamID delegate:(id<LYROperationDelegate>)delegate;

@property (nonatomic, strong, readonly) NSUUID *streamID;
@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, strong, readonly) LYRTStream *stream;

@end
