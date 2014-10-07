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
            break;
        case LYRUIDevelopment:
            return @"https://conf.lyr8.net/conf";
            break;
        case LYRUIStage1:
             return @"https://conf.stage1.lyr8.net/conf";
            break;
        case LSTestEnvironment:
            return @"https://conf.lyr8.net/conf";
    
        default:
            break;
    }
}

NSUUID *LSLayerAppID(LSEnvironment environment)
{
    switch (environment) {
        case LYRUIProduction:
            return [[NSUUID alloc] initWithUUIDString:@"4ecc1f16-0c5e-11e4-ac3e-276b00000a10"];
            break;
        case LYRUIDevelopment:
            return [[NSUUID alloc] initWithUUIDString:@"ce2c45a4-3e97-11e4-9d4c-6a9900000431"];
            break;
        case LYRUIStage1:
            return [[NSUUID alloc] initWithUUIDString:@"24f43c32-4d95-11e4-b3a2-0fd00000020d"];
            break;
        case LSTestEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"ce2c45a4-3e97-11e4-9d4c-6a9900000431"];
            break;
            
        default:
            break;
    }
}

NSString *LSApplicationDataDirectory(void)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
}

NSString *LSLayerPersistencePath(LSEnvironment environment)
{
    return [LSApplicationDataDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqllite", LSLayerAppID(environment)]];
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
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

CGRect LSImageRectForThumb(CGSize size, NSUInteger maxConstraint)
{
    CGRect thumbRect;
    if (size.width > size.height) {
        double ratio = maxConstraint/size.width;
        double height = size.height * ratio;
        thumbRect = CGRectMake(0, 0, maxConstraint, height);
    } else {
        double ratio = maxConstraint/size.height;
        double width = size.width * ratio;
        thumbRect = CGRectMake(0, 0, width, maxConstraint);
    }
    return thumbRect;
}

NSString *MIMETypeTextPlain()
{
    return @"text/plain";
}

NSString *MIMETypeImagePNG()
{
    return @"image/png";
}

NSString *MIMETypeImageJPEG()
{
    return @"image/jpeg";
}

