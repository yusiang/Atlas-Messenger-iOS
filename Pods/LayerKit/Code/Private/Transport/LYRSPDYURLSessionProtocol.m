//
//  LYRSPDYURLSessionProtocol.m
//  LayerKit
//
//  Created by Klemen Verdnik on 21/04/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRSPDYURLSessionProtocol.h"
#import "SPDYCommonLogger.h"
#import "SPDYOrigin.h"
#import "SPDYSession.h"
#import "SPDYSessionManager.h"
#import "SPDYTLSTrustEvaluator.h"
#import <objc/runtime.h>

static NSHashTable *LYRSPDYSessionsIndex;

@implementation LYRSPDYURLSessionProtocol

+ (void)initialize
{
    [super initialize];
    LYRSPDYSessionsIndex = [NSHashTable weakObjectsHashTable];
}

+ (NSArray *)sessions
{
    return [LYRSPDYSessionsIndex allObjects];
}

- (void)startLoading
{
    NSURLRequest *request = self.request;
    SPDY_INFO(@"LYRSPDY start loading %@", request.URL.absoluteString);

    NSError *error;
    SPDYSession *session = [SPDYSessionManager sessionForURL:request.URL error:&error];
    Ivar _sessionIvar = class_getInstanceVariable([self superclass], "_session");
    object_setIvar(self, _sessionIvar, session);
    if (!session) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [session issueRequest:self];
        if (![LYRSPDYSessionsIndex containsObject:session]) {
            LYRLogVerbose(@"adding a SPDY session in the session collection [%lu]", (unsigned long)[LYRSPDYSessionsIndex count]);
            [LYRSPDYSessionsIndex addObject:session];
        }
    }
}

@end
