//
//  LYRSynchronizationManager.m
//  LayerKit
//
//  Created by Blake Watters on 4/25/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRSynchronizationManager.h"
#import "LYRReconciliationOperation.h"
#import "LYRInboundReconOperation.h"
#import "LYRSynchronizationOperation.h"
#import "LYRTransportErrors.h"

@interface LYRSynchronizationManager ()
@property (nonatomic) NSURL *baseURL;
@property (nonatomic) LYRSynchronizationDataSource *dataSource;
@end

@implementation LYRSynchronizationManager

- (id)initWithBaseURL:(NSURL *)baseURL sessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration datasource:(LYRSynchronizationDataSource *)dataSource delegate:(id<LYRSynchronizationManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _baseURL = baseURL;
        _sessionConfiguration = sessionConfiguration;
        _operationQueue = [NSOperationQueue new];
        _dataSource = dataSource;
        _delegate = delegate;
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer: Call `initWithBaseURL:sessionConfiguration:` instead." userInfo:nil];
}

- (void)start
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not yet implemented" userInfo:nil];
}

- (void)stop
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not yet implemented" userInfo:nil];
}

- (NSOperation *)execute
{
    if (self.sessionConfiguration == nil) {
        LYRLogError(@"Could not createa an NSURLSession without the session configuration. Client probably hasn't established a fully authenticated connection yet.");
        return nil;
    }
    NSURLSession *URLSession = [NSURLSession sessionWithConfiguration:self.sessionConfiguration];
    LYRSynchronizationOperation *synchronizationOperation = [[LYRSynchronizationOperation alloc] initWithBaseURL:self.baseURL URLSession:URLSession dataSource:self.dataSource delegate:self];
    [_operationQueue addOperation:synchronizationOperation];
    return synchronizationOperation;
}

- (NSOperation *)executeReconcilliationOperation
{
    LYRReconciliationOperation *reconSyncOperation = [[LYRReconciliationOperation alloc] initWithDataSource:self.dataSource delegate:self];
    [_operationQueue addOperation:reconSyncOperation];
    return reconSyncOperation;
}

- (NSOperation *)executeSynchronizationOperation
{
    // TODO: LYRInboundReconOperation doesn't do any network operations,
    // and it's tightly coupled with LYRSynchronizationOperation.
    return [self execute];
}

#pragma mark - LYROperationDelegate implementation

- (BOOL)operation:(NSOperation *)operation shouldFailDueToError:(NSError *)error
{
    if (![error isKindOfClass:[NSError class]]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"operation: %@ signaled shouldFaild with an object of type '%@' which is not a kind of '%@'.", operation, [error class], [NSError class]] userInfo:nil];
    }
    if ([error.domain isEqualToString:LYRTransportErrorDomain] && error.code == LYRTransportErrorAuthenticationChallenge) {
        [self.delegate synchronizationManager:self didFailWithError:error];
        return YES;
    }
    return NO;
}

@end
