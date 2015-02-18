//
//  ATLMUtilities.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 7/1/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "ATLMPersistenceManager.h"
#import "ATLMUtilities.h"

NSString *const ATLMAppEncounteredUnknownUser = @"LSAppEncounteredUnknownUser";

BOOL ATLMIsRunningTests(void)
{
    return NSClassFromString(@"XCTestCase") != Nil;
}

NSURL *ATLMRailsBaseURL(void)
{
    return [NSURL URLWithString:@"https://layer-identity-provider.herokuapp.com"];
}

NSString *ATLMLayerConfigurationURL(ATLMEnvironment environment)
{
    switch (environment) {
        case ATLMProductionEnvironment:
            return @"https://conf.lyr8.net/conf";               //https://developer.layer.com/dashboard/login

        case ATLMProductionDebugEnvironment:
            return @"https://conf.lyr8.net/conf";               //https://developer.layer.com/dashboard/login
        
        case ATLMStagingEnvironment:
            return @"https://conf.stage1.lyr8.net/conf";        //https://developer.stage1.lyr8.net/dashboard
            
        case ATLMStagingDebugEnvironment:
             return @"https://conf.stage1.lyr8.net/conf";       //https://developer.stage1.lyr8.net/dashboard

        case ATLMTestEnvironment:
            return @"https://conf.lyr8.net/conf";               //https://developer.layer.com/dashboard/login

        case ATLMAdHocEnvironment:
            return @"https://130.211.117.22:444/conf";
            
        case ATLMLoadTestEnvironment:
            return @"https://conf.dev1.lyr8.net/conf";          //https://developer.dev1.lyr8.net/dashboard/login
            
        default:
            return nil;
    }
}

NSUUID *ATLMLayerAppID(ATLMEnvironment environment)
{
    switch (environment) {
        case ATLMProductionEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"9ec30af8-5591-11e4-af9e-f7a201004a3b"];

        case ATLMProductionDebugEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"361ff3ca-70e0-11e4-a4ef-1dec000000e6"];
            
        case ATLMStagingEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"84002f7e-9b56-11e4-b7c1-e6d202002423"];
            
        case ATLMStagingDebugEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"8d6ee1c2-9b56-11e4-8bf1-e6d202002423"];

        case ATLMTestEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"46dfa7da-6d1d-11e4-a787-e6f4000000e7"];

        case ATLMAdHocEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"d354316c-63be-11e4-841a-364a00000bce"];
        
        case ATLMLoadTestEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"7c5cc92c-9de4-11e4-a951-a84200000d8d"];
        
        default:
            return nil;
    }
}

NSString *ATLMApplicationDataDirectory(void)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

ATLMPersistenceManager *ATLMPersitenceManager(void)
{
    if (ATLMIsRunningTests()) {
        return [ATLMPersistenceManager persistenceManagerWithInMemoryStore];
    }
    return [ATLMPersistenceManager persistenceManagerWithStoreAtPath:[ATLMApplicationDataDirectory() stringByAppendingPathComponent:@"PersistentObjects"]];
}

void ATLMAlertWithError(NSError *error)
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unexpected Error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}
