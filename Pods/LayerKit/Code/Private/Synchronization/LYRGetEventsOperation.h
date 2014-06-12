//
//  LYRGetEventsOperation.h
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRConcurrentOperation.h"

@interface LYRGetEventsOperation : LYRConcurrentOperation

// NOTE: sequencesByStream is an `LYRTStream` => `NSIndexSet`
- (id)initWithBaseURL:(NSURL *)baseURL URLSession:(NSURLSession *)URLSession sequencesByStream:(NSMapTable *)sequencesByStream delegate:(id<LYROperationDelegate>)delegate;

@property (nonatomic, readonly) NSMapTable *eventsByStream; // Will be an `LYRTEvent` or an `NSError`

@end
