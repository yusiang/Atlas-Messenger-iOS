//
//  LSAppController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSApplicationController.h"
#import "LSConversationListViewController.h"

static NSString *LSApplicationDataDirectory(void)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
}

static BOOL LSIsRunningTests(void)
{
    return NSClassFromString(@"XCTestCase") != Nil;
}

@interface LYRClient ()

- (id)initWithBaseURL:(NSURL *)baseURL appID:(NSUUID *)appID;

@end

@interface LSApplicationController ()

@property (nonatomic) NSURL *baseURL;

@end

@implementation LSApplicationController

+ (instancetype)managerWithBaseURL:(NSURL *)baseURL
{
    NSParameterAssert(baseURL);
    return [[self alloc] initWithBaseURL:baseURL];
}

- (id)initWithBaseURL:(NSURL *)baseURL
{
    self = [super init];
    if (self) {
       
        NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-1000-8000-000000000000"];
        LYRClient *layerClient = [[LYRClient alloc] initWithBaseURL:baseURL appID:appID];
       
        _layerClient = layerClient;
        _persistenceManager = LSIsRunningTests() ? [LSPersistenceManager persistenceManagerWithInMemoryStore] : [LSPersistenceManager persistenceManagerWithStoreAtPath:[LSApplicationDataDirectory() stringByAppendingPathComponent:@"PersistentObjects"]];
        _APIManager = [LSAPIManager managerWithBaseURL:[NSURL URLWithString:@"http://10.66.0.35:8080/"] layerClient:layerClient];
    }
    return self;
}




@end
