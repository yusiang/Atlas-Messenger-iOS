//
//  LYRGetStreamsOperation.m
//  LayerKit
//
//  Created by Blake Watters on 4/27/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRGetStreamsOperation.h"
#import "TMemoryBuffer.h"
#import "TCompactProtocol.h"
#import "messaging.h"
#import "LYRSynchronizationErrors.h"
#import "LYRStream.h"
#import "LYRAuthenticationChallenge.h"
#import "LYRThriftHTTPResponseSerializer.h"

@interface LYRGetStreamsOperation ()
@property (nonatomic, strong, readonly) NSURL *baseURL;
@property (nonatomic, strong, readonly) NSURLSession *URLSession;
@property (nonatomic, strong, readwrite) NSArray *streams;
@property (nonatomic, strong, readwrite) NSError *error;
@end

@implementation LYRGetStreamsOperation

- (id)initWithBaseURL:(NSURL *)baseURL URLSession:(NSURLSession *)URLSession userID:(NSUUID *)userID delegate:(id<LYROperationDelegate>)delegate;
{
    if (!baseURL) [NSException raise:NSInternalInconsistencyException format:@"`baseURL` cannot be `nil`."];
    if (!URLSession) [NSException raise:NSInternalInconsistencyException format:@"`URLSession` cannot be `nil`."];
    if (!userID) [NSException raise:NSInternalInconsistencyException format:@"`userID` cannot be `nil`."];
    self = [super initWithDelegate:delegate];
    if (self) {
        _baseURL = baseURL;
        _URLSession = URLSession;
        _userID = userID;
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Failed to call designated initializer: Call `%@` instead.",
                                           NSStringFromSelector(@selector(initWithBaseURL:URLSession:userID:))]
                                 userInfo:nil];
}

- (void)execute
{
    NSString *path = [NSString stringWithFormat:@"users/%@/streams", [self.userID UUIDString]];
    NSURL *URL = [NSURL URLWithString:path relativeToURL:self.baseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    LYRLogDebug(@"Fetching user's streams");
    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        LYRAuthenticationChallenge *challenge = [LYRAuthenticationChallenge authenticationChallengeWithResponse:response];
        
        if (challenge) {
            self.error = challenge.errorRespresentation;
        } else if (response && data) {
            NSError *error;
            BOOL success;
            LYRTResponse *getStreamsResponse;
            success = [LYRThriftHTTPResponseSerializer responseObject:&getStreamsResponse ofClass:[LYRTResponse class] forResponse:response data:data error:&error];
            if (success) {
                NSMutableArray *streams = [NSMutableArray arrayWithCapacity:getStreamsResponse.streams.count];
                for (LYRTStream *deStream in getStreamsResponse.streams) [streams addObject:[LYRStream streamWithThriftStream:deStream]];
                self.streams = streams;
                LYRLogDebug(@"Finished fetching user's streams: %@", streams);
            }
            else self.error = error;
        } else {
            self.error = error;
        }
        if (self.error) [self.delegate operation:self shouldFailDueToError:self.error];
        [self.stateMachine finish];
    }] resume];
}

@end
