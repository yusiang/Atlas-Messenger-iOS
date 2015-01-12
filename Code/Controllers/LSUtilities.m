//
//  LSUtilities.m
//  LayerSample
//
//  Created by Kevin Coleman on 7/1/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSPersistenceManager.h"
#import "LSUtilities.h"

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
        case LYRUIProduction:
            return @"https://conf.lyr8.net/conf";
        case LYRUIDevelopment:
            return @"https://conf.lyr8.net/conf";
        case LYRUIStage1:
             return @"https://conf.stage1.lyr8.net/conf";
        case LYRUIDev1:
            return @"https://dev-1.preview.layer.com:444/conf";
        case LSTestEnvironment:
            return @"https://conf.lyr8.net/conf";
        case LSAdHoc:
            return @"https://130.211.117.22:444/conf";
        default:
            return nil;
    }
}

NSUUID *LSLayerAppID(LSEnvironment environment)
{
    switch (environment) {
        case LYRUIProduction:
            return [[NSUUID alloc] initWithUUIDString:@"9ec30af8-5591-11e4-af9e-f7a201004a3b"];
        case LYRUIDevelopment:
            return [[NSUUID alloc] initWithUUIDString:@"361ff3ca-70e0-11e4-a4ef-1dec000000e6"];
        case LYRUIStage1:
            return [[NSUUID alloc] initWithUUIDString:@"24f43c32-4d95-11e4-b3a2-0fd00000020d"];
        case LYRUIDev1:
            return [[NSUUID alloc] initWithUUIDString:@"9ae66b44-1682-11e4-92e4-0b53000001d0"];
        case LSTestEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"46dfa7da-6d1d-11e4-a787-e6f4000000e7"];
        case LSAdHoc:
            return [[NSUUID alloc] initWithUUIDString:@"d354316c-63be-11e4-841a-364a00000bce"];
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
    if (LSIsRunningTests()){
        return [LSPersistenceManager persistenceManagerWithInMemoryStore];
    }
    return [LSPersistenceManager persistenceManagerWithStoreAtPath:[LSApplicationDataDirectory() stringByAppendingPathComponent:@"PersistentObjects"]];
}

void LSAlertWithError(NSError *error)
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unexpected Error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}
