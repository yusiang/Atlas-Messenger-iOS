//
//  LSUtilities.m
//  LayerSample
//
//  Created by Kevin Coleman on 7/1/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSPersistenceManager.h"
#import "LSUtilities.h"

NSString *const LSAppShouldFetchContactsNotification = @"LSAppShouldFetchContactsNotification";

BOOL LSIsRunningTests(void)
{
    return NSClassFromString(@"XCTestCase") != Nil;
}

NSURL *LSRailsBaseURL(void)
{
    return [NSURL URLWithString:@"https://layer-identity-provider.herokuapp.com"];
}

NSString *LSLayerConfigurationURL(LSEnvironment environment)
{
    switch (environment) {
        case LSProductionEnvironment:
            return @"https://conf.lyr8.net/conf";               //https://developer.layer.com/dashboard/login

        case LSProductionDebugEnvironment:
            return @"https://conf.lyr8.net/conf";               //https://developer.layer.com/dashboard/login
        
        case LSStagingEnvironment:
            return @"https://conf.stage1.lyr8.net/conf";        //https://developer.stage1.lyr8.net/dashboard
            
        case LSStagingDebugEnvironment:
             return @"https://conf.stage1.lyr8.net/conf";       //https://developer.stage1.lyr8.net/dashboard

        case LSTestEnvironment:
            return @"https://conf.lyr8.net/conf";               //https://developer.layer.com/dashboard/login

        case LSAdHocEnvironment:
            return @"https://130.211.117.22:444/conf";
            
        case LSLoadTestEnvironment:
            return @"https://conf.dev1.lyr8.net/conf";          //https://developer.dev1.lyr8.net/dashboard/login
            
        default:
            return nil;
    }
}

NSUUID *LSLayerAppID(LSEnvironment environment)
{
    switch (environment) {
        case LSProductionEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"9ec30af8-5591-11e4-af9e-f7a201004a3b"];

        case LSProductionDebugEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"361ff3ca-70e0-11e4-a4ef-1dec000000e6"];
            
        case LSStagingEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"84002f7e-9b56-11e4-b7c1-e6d202002423"];
            
        case LSStagingDebugEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"8d6ee1c2-9b56-11e4-8bf1-e6d202002423"];

        case LSTestEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"46dfa7da-6d1d-11e4-a787-e6f4000000e7"];

        case LSAdHocEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"d354316c-63be-11e4-841a-364a00000bce"];
        
        case LSLoadTestEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"7c5cc92c-9de4-11e4-a951-a84200000d8d"];
        
        default:
            return nil;
    }
}

NSString *LSApplicationDataDirectory(void)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

LSPersistenceManager *LSPersitenceManager(void)
{
    if (LSIsRunningTests()) {
        return [LSPersistenceManager persistenceManagerWithInMemoryStore];
    }
    return [LSPersistenceManager persistenceManagerWithStoreAtPath:[LSApplicationDataDirectory() stringByAppendingPathComponent:@"PersistentObjects"]];
}

void LSAlertWithError(NSError *error)
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unexpected Error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}
