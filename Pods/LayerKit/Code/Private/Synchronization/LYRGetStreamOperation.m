//
//  LYRGetStreamOperation.m
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRGetStreamOperation.h"
#import "TMemoryBuffer.h"
#import "TCompactProtocol.h"
#import "messaging.h"
#import "LYRSynchronizationErrors.h"
#import "LYRAuthenticationChallenge.h"
#import "LYRThriftHTTPResponseSerializer.h"

@interface LYRGetStreamOperation ()
@property (nonatomic, strong, readonly) NSURL *baseURL;
@property (nonatomic, strong, readonly) NSURLSession *URLSession;
@property (nonatomic, strong, readwrite) LYRTStream *stream;
@property (nonatomic, strong, readwrite) NSError *error;
@end

@implementation LYRGetStreamOperation

- (id)initWithBaseURL:(NSURL *)baseURL URLSession:(NSURLSession *)URLSession streamID:(NSUUID *)streamID delegate:(id<LYROperationDelegate>)delegate
{
    self = [super initWithDelegate:delegate];
    if (self) {
        _baseURL = baseURL;
        _URLSession = URLSession;
        _streamID = streamID;
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Failed to call designated initializer: Call `%@` instead.",
                                           NSStringFromSelector(@selector(initWithBaseURL:URLSession:streamID:))]
                                 userInfo:nil];
}

- (void)execute
{
    NSString *path = [NSString stringWithFormat:@"streams/%@", [self.streamID UUIDString]];
    NSURL *URL = [NSURL URLWithString:path relativeToURL:self.baseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        LYRAuthenticationChallenge *challenge = [LYRAuthenticationChallenge authenticationChallengeWithResponse:response];
        
        if (challenge) {
            self.error = challenge.errorRespresentation;
        }
        else if (response && data) {
            NSError *error;
            BOOL success;
            LYRTResponse *getStreamResponse;
            success = [LYRThriftHTTPResponseSerializer responseObject:&getStreamResponse ofClass:[LYRTResponse class] forResponse:response data:data error:&error];
            if (success) self.stream = getStreamResponse.stream;
            else self.error = error;
        } else {
            self.error = error;
        }
        if (self.error) [self.delegate operation:self shouldFailDueToError:self.error];
        [self.stateMachine finish];
    }] resume];
}

@end
