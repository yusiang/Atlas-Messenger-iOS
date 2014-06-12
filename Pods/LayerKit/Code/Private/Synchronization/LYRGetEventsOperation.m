//
//  LYRGetEventsOperation.m
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRGetEventsOperation.h"
#import "LYREvent.h"
#import "TMemoryBuffer.h"
#import "messaging.h"
#import "TCompactProtocol.h"
#import "LYRSynchronizationErrors.h"
#import "LYRUUIDData.h"
#import "LYRAuthenticationChallenge.h"
#import "LYRThriftHTTPResponseSerializer.h"

@interface LYRGetEventsOperation ()
@property (nonatomic, strong, readonly) NSURL *baseURL;
@property (nonatomic, strong, readonly) NSURLSession *URLSession;
@property (nonatomic, strong, readonly) NSMapTable *sequencesByStream;
@property (nonatomic, strong, readwrite) NSMapTable *eventsByStream; // Will be an `NSNumber` or an `NSError`
@end

@implementation LYRGetEventsOperation

- (id)initWithBaseURL:(NSURL *)baseURL URLSession:(NSURLSession *)URLSession sequencesByStream:(NSMapTable *)sequencesByStream delegate:(id<LYROperationDelegate>)delegate;
{
    self = [super initWithDelegate:delegate];
    if (self) {
        _baseURL = baseURL;
        _URLSession = URLSession;
        _sequencesByStream = sequencesByStream;
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Failed to call designated initializer: Call `%@` instead.",
                                           NSStringFromSelector(@selector(initWithBaseURL:URLSession:sequencesByStream:))]
                                 userInfo:nil];
}

- (void)execute
{
    dispatch_queue_t resultsQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    dispatch_group_t dispatchGroup = dispatch_group_create();
    NSMapTable *resultsByStream = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality
                                                            valueOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality capacity:0];
    
    for (LYRTStream *stream in self.sequencesByStream) {
        NSIndexSet *sequences = [self.sequencesByStream objectForKey:stream];
        
        [sequences enumerateIndexesUsingBlock:^(NSUInteger sequence, BOOL *stop) {
            NSUUID *streamID = LYRUUIDFromData(stream.stream_id);
            NSString *path = [NSString stringWithFormat:@"streams/%@/events/%lu", [streamID UUIDString], (unsigned long)sequence];
            NSURL *URL = [NSURL URLWithString:path relativeToURL:self.baseURL];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            
            dispatch_group_enter(dispatchGroup);
            [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                id result = nil; // Will either be an `NSError` or an `NSNumber`
                LYRAuthenticationChallenge *challenge = [LYRAuthenticationChallenge authenticationChallengeWithResponse:response];
                
                if (!response && error) {
                    result = error;
                } else if (challenge) {
                    result = challenge.errorRespresentation;
                } else if (response && [data length]) {
                    NSError *error;
                    BOOL success;
                    LYRTResponse *getEventResponse;
                    success = [LYRThriftHTTPResponseSerializer responseObject:&getEventResponse ofClass:[LYRTResponse class] forResponse:response data:data error:&error];
                    if (success) {
                        LYREvent *event = [LYREvent eventWithThriftEvent:getEventResponse.event];
                        event.stream_id = LYRDataFromUUID(streamID);
                        event.seq = (uint32_t)sequence;
                        result = event;
                    }
                    else result = error;
                } else {
                    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"An unprocessable response was encountered.", NSURLErrorFailingURLErrorKey: URL, @"response": response, @"sequence": @(sequence) };
                    result = [NSError errorWithDomain:LYRErrorDomain code:LYRTransportErrorUnprocessableResponse userInfo:userInfo];
                }
                if ([result isKindOfClass:[NSError class]] && [self.delegate operation:self shouldFailDueToError:result]) {
                    *stop = YES;
                }
                dispatch_barrier_async(resultsQueue, ^{
                    if ([resultsByStream objectForKey:stream] == nil) [resultsByStream setObject:[NSMutableArray new] forKey:stream];
                    [[resultsByStream objectForKey:stream] addObject:result];
                    dispatch_group_leave(dispatchGroup);
                });
            }] resume];
        }];
    }
    
    dispatch_group_notify(dispatchGroup, [[self class] dispatchQueue], ^{
        self.eventsByStream = resultsByStream;
        [self.stateMachine finish];
    });
}

@end
