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
        case LYRUIDev1:
            return @"https://dev-1.preview.layer.com:444/conf";
            break;
        case LSTestEnvironment:
            return @"https://conf.lyr8.net/conf";
        case LSAdHoc:
            return @"https://130.211.117.22:444/conf";
        default:
            break;
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

