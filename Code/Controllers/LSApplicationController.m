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

+ (instancetype)controllerWithBaseURL:(NSURL *)baseURL layerClient:(LYRClient *)layerClient persistenceManager:(LSPersistenceManager *)persistenceManager
{
    NSParameterAssert(baseURL);
    NSParameterAssert(layerClient);
    return [[self alloc] initWithBaseURL:baseURL layerClient:layerClient persistenceManager:persistenceManager];
}

- (id)initWithBaseURL:(NSURL *)baseURL layerClient:(LYRClient *)layerClient persistenceManager:(LSPersistenceManager *)persistenceManager
{
    self = [super init];
    if (self) {
        _layerClient = layerClient;
        _persistenceManager = persistenceManager;
        _APIManager = [LSAPIManager managerWithBaseURL:baseURL layerClient:layerClient];
        _notificationObserver = [[LSNotificationObserver alloc] initWithClient:layerClient];
    }
    return self;
}

@end
