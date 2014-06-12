//
//  LYRCreateStreamOperation.m
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRCreateStreamOperation.h"
#import "TMemoryBuffer.h"
#import "TCompactProtocol.h"
#import "messaging.h"
#import "LYRSynchronizationErrors.h"
#import "LYRAuthenticationChallenge.h"
#import "LYRThriftHTTPResponseSerializer.h"

@interface LYRCreateStreamOperation ()
@property (nonatomic, strong, readonly) NSURL *baseURL;
@property (nonatomic, strong, readonly) NSURLSession *URLSession;
@property (nonatomic, strong, readwrite) LYRTStream *stream;
@property (nonatomic, strong, readwrite) NSError *error;
@end

@implementation LYRCreateStreamOperation

- (id)initWithBaseURL:(NSURL *)baseURL URLSession:(NSURLSession *)URLSession delegate:(id<LYROperationDelegate>)delegate
{
    self = [super initWithDelegate:delegate];
    if (self) {
        _baseURL = baseURL;
        _URLSession = URLSession;
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Failed to call designated initializer: Call `%@` instead.",
                                           NSStringFromSelector(@selector(initWithBaseURL:URLSession:))]
                                 userInfo:nil];
}

- (void)execute
{
    NSURL *URL = [NSURL URLWithString:@"streams" relativeToURL:self.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        LYRAuthenticationChallenge *challenge = [LYRAuthenticationChallenge authenticationChallengeWithResponse:response];
        
        if (challenge) {
            self.error = challenge.errorRespresentation;
        } else if (response && data) {
            NSError *error;
            BOOL success;
            LYRTResponse *createStreamResponse;
            success = [LYRThriftHTTPResponseSerializer responseObject:&createStreamResponse ofClass:[LYRTResponse class] forResponse:response data:data error:&error];
            if (success) self.stream = createStreamResponse.stream;
            else self.error = error;
        } else {
            self.error = error;
        }
        if (self.error) [self.delegate operation:self shouldFailDueToError:self.error];
        [self.stateMachine finish];
    }] resume];
}

@end
