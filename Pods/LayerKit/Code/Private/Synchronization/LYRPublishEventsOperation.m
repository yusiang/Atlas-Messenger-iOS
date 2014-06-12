//
//  LYRPublishEventsOperation.m
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRPublishEventsOperation.h"
#import "LYREvent.h"
#import "TMemoryBuffer.h"
#import "messaging.h"
#import "TCompactProtocol.h"
#import "LYRSynchronizationErrors.h"
#import "LYRUUIDData.h"
#import "NSURLRequest+SPDYURLRequest.h"
#import "LYRAuthenticationChallenge.h"
#import "LYRThriftHTTPResponseSerializer.h"

static NSString *LYRStringFromEventType(int eventType)
{
    switch (eventType) {
        case EventType_APPLICATION:
            return @"APPLICATION";
            break;
        case EventType_MEMBER_ADDED:
            return @"MEMBER_ADDED";
            break;
        case EventType_MEMBER_REMOVED:
            return @"MEMBER_REMOVED";
            break;
        case EventType_MESSAGE:
            return @"MESSAGE";
            break;
        case EventType_MESSAGE_DELIVERED:
            return @"MESSAGE_DELIVERED";
            break;
        case EventType_MESSAGE_READ:
            return @"MESSAGE_READ";
            break;
        case EventType_METADATA_ADDED:
            return @"METADATA_ADDED";
            break;
        case EventType_METADATA_REMOVED:
            return @"METADATA_REMOVED";
            break;
            
        default:
            break;
    }
    return [NSString stringWithFormat:@"UNKNOWN TYPE (%d)", eventType];
}

static NSString *LYRStringDescribingEvent(LYREvent *event)
{
    return [NSString stringWithFormat:@"<%@:%p type=%@, streamUUID=%@, server_sequence=%d, client_seq=%d, member_id=%@>",
            [event class], event, LYRStringFromEventType(event.type), [LYRUUIDFromData(event.stream_id) UUIDString],
            event.seq, event.client_seq, event.member_id];
}

@interface LYRPublishEventsOperation ()
@property (nonatomic, readonly) NSURL *baseURL;
@property (nonatomic, readonly) NSURLSession *URLSession;
@property (nonatomic, readonly) NSDictionary *eventsByStreamID;
@property (nonatomic, readwrite) NSMapTable *sequencesByEvent;
@property (nonatomic, readwrite) NSMapTable *errorsByEvent;
@end

@implementation LYRPublishEventsOperation

- (id)initWithBaseURL:(NSURL *)baseURL URLSession:(NSURLSession *)URLSession eventsByStreamID:(NSDictionary *)eventsByStreamID delegate:(id<LYROperationDelegate>)delegate
{
    self = [super initWithDelegate:delegate];
    if (self) {
        _baseURL = baseURL;
        _URLSession = URLSession;
        _eventsByStreamID = eventsByStreamID;
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Failed to call designated initializer: Call `%@` instead.",
                                           NSStringFromSelector(@selector(initWithBaseURL:URLSession:eventsByStreamID:))]
                                 userInfo:nil];
}

- (void)execute
{
    dispatch_queue_t resultsQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    dispatch_group_t dispatchGroup = dispatch_group_create();
    NSMapTable *sequenceResults = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality
                                                            valueOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality capacity:0];
    NSMapTable *errorsResults = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality
                                                          valueOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality capacity:0];
    
    LYRLogDebug(@"<%@:%p> Publishing Events for %ld Streams...", [self class], self, (unsigned long)[self.eventsByStreamID count]);
    
    for (NSUUID *streamID in self.eventsByStreamID) {
        NSString *path = [NSString stringWithFormat:@"streams/%@/events", [streamID UUIDString]];
        NSURL *URL = [NSURL URLWithString:path relativeToURL:self.baseURL];
        LYRLogDebug(@"<%@:%p> Publishing %lu Events to Stream ID %@", [self class], self, (unsigned long)[self.eventsByStreamID[streamID] count], [streamID UUIDString]);
        __block BOOL shouldBreak = NO;
        for (LYRTEvent *event in self.eventsByStreamID[streamID]) {
            if (shouldBreak) break;
            
            TMemoryBuffer *buffer = [TMemoryBuffer new];
            TCompactProtocol *protocol = [[TCompactProtocol alloc] initWithTransport:buffer strictRead:NO strictWrite:YES];
            [event write:protocol];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
            request.HTTPMethod = @"POST";
            request.HTTPBody = [buffer getBuffer];
            
            dispatch_group_enter(dispatchGroup);
            // TODO: Was LYRLogVerbose
            LYRLogVerbose(@"<%@:%p> POST %@ :: %@", [self class], self, [URL relativeString], LYRStringDescribingEvent(event));
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
                    LYRTResponse *postEventResponse;
                    success = [LYRThriftHTTPResponseSerializer responseObject:&postEventResponse ofClass:[LYRTResponse class] forResponse:response data:data error:&error];
                    if (success) result = @(postEventResponse.seq);
                    else result = error;

                    // TODO: LYRLogDebug???
                    LYRLogVerbose(@"<%@:%p> POST %@ (%ld) => %ld [%@]", [self class], self, [URL relativeString], [(NSHTTPURLResponse *)response statusCode], postEventResponse.seq, LYRStringDescribingEvent(event));
                } else {
                    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"An unprocessable response was encountered.", NSURLErrorFailingURLErrorKey: URL, @"response": response ?: [NSNull null], @"event": event };
                    result = [NSError errorWithDomain:LYRErrorDomain code:LYRTransportErrorUnprocessableResponse userInfo:userInfo];
                }

                dispatch_barrier_async(resultsQueue, ^{
                    if ([result isKindOfClass:[NSError class]]) {
                        LYRLogError(@"<%@:%p> Request %@ failed for Event %@: %@", [self class], self, request, event, result);
                        [errorsResults setObject:result forKey:event];
                        if ([self.delegate operation:self shouldFailDueToError:result]) {
                            shouldBreak = YES;
                        }
                    } else {
                        LYRLogVerbose(@"<%@:%p> Published event %@ (sequence=%@)", [self class], self, event, result);
                        [sequenceResults setObject:result forKey:event];
                    }
                    dispatch_group_leave(dispatchGroup);
                });
            }] resume];
        }
    }
    
    dispatch_group_notify(dispatchGroup, [[self class] dispatchQueue], ^{
        self.sequencesByEvent = sequenceResults;
        self.errorsByEvent = [errorsResults count] ? errorsResults : nil;
        [self finish];
    });
}

@end
