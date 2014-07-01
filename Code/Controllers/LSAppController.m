//
//  LSAppController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSAppController.h"
#import "LSConversationListViewController.h"

static void LSAlertWithError(NSError *error)
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unexpected Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

static BOOL LSIsRunningTests(void)
{
    return NSClassFromString(@"XCTestCase") != Nil;
}

static NSString *LSApplicationDataDirectory(void)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
}

static NSURL *LSLayerBaseURL(void)
{
    if (LSIsRunningTests()) {
        NSString *environmentHost = [NSProcessInfo processInfo].environment[@"LAYER_TEST_HOST"];
        if (environmentHost) {
            return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@:7072", environmentHost]];
        }
    }
    return [NSURL URLWithString:@"https://10.66.0.35:7072"];
}

@interface LYRClient ()

- (id)initWithBaseURL:(NSURL *)baseURL appID:(NSUUID *)appID;

@end


@implementation LSAppController

- (id)init
{
    self = [super init];
    if (self) {
        
        NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-1000-8000-000000000000"];
        LYRClient *layerClient = [[LYRClient alloc] initWithBaseURL:LSLayerBaseURL() appID:appID];
        self.layerClient = layerClient;
        
        self.persistenceManager = LSIsRunningTests() ? [LSPersistenceManager persistenceManagerWithInMemoryStore] : [LSPersistenceManager persistenceManagerWithStoreAtPath:[LSApplicationDataDirectory() stringByAppendingPathComponent:@"PersistentObjects"]];
        self.APIManager = [LSAPIManager managerWithBaseURL:[NSURL URLWithString:@"http://10.66.0.35:8080/"] layerClient:layerClient];
    }
    return self;
}


@end
