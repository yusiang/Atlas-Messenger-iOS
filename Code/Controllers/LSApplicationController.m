//
//  LSAppController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSApplicationController.h"
#import "LSConversationListViewController.h"
#import "LSUtilities.h"

@interface LSApplicationController ()

@property (nonatomic) NSURL *baseURL;

@end

@implementation LSApplicationController

+ (instancetype)controllerWithBaseURL:(NSURL *)baseURL layerClient:(LYRClient *)layerClient
{
    NSParameterAssert(baseURL);
    NSParameterAssert(layerClient);
    return [[self alloc] initWithBaseURL:baseURL layerClient:layerClient];
}

- (id)initWithBaseURL:(NSURL *)baseURL layerClient:(LYRClient *)layerClient
{
    self = [super init];
    if (self) {
       
        _layerClient = layerClient;
        _persistenceManager = LSIsRunningTests() ? [LSPersistenceManager persistenceManagerWithInMemoryStore] : [LSPersistenceManager persistenceManagerWithStoreAtPath:[LSApplicationDataDirectory() stringByAppendingPathComponent:@"PersistentObjects"]];
        _APIManager = [LSAPIManager managerWithBaseURL:[NSURL URLWithString:@"http://10.66.0.35:8080/"] layerClient:layerClient];
        
    }
    return self;
}




@end
