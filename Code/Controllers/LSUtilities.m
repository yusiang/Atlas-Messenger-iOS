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
        case LSProductionEnvironment:
            return @"https://na-3.preview.layer.com/client_configuration.json";
            break;
        case LSDevelopmentEnvironment:
            return @"https://dev-1.preview.layer.com/client_configuration.json";
            break;
        case LSTestEnvironment:
            return @"172.17.8.101/client_configuration.json";
            break;
            
        default:
            break;
    }
}

NSUUID *LSLayerAppID(LSEnvironment environment)
{
    switch (environment) {
        case LSProductionEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"4ecc1f16-0c5e-11e4-ac3e-276b00000a10"];
            break;
        case LSDevelopmentEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"9ae66b44-1682-11e4-92e4-0b53000001d0"];
            break;
        case LSTestEnvironment:
            return [[NSUUID alloc] initWithUUIDString:@"00000000-0000-1000-8000-000000000000"];
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
    switch (environment) {
        case LSProductionEnvironment:
            return [LSApplicationDataDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqllite", LSLayerAppID(environment)]];
            break;
        case LSDevelopmentEnvironment:
            return [LSApplicationDataDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqllite", LSLayerAppID(environment)]];
            break;
        case LSTestEnvironment:
            return nil;
            break;
        default:
            break;
    }
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

