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
        case LYRUINA3Production:
            return @"https://na-3.preview.layer.com/client_configuration.json";
            break;
            
        case LYRUINA3Development:
            return @"https://na-3.preview.layer.com/client_configuration.json";
            break;
            
        case LYRUIDEV1Production:
            return @"https://dev-1.preview.layer.com/client_configuration.json";
            break;
            
        case LYRUIDEV1Development:
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
        case LYRUINA3Production:
            return [[NSUUID alloc] initWithUUIDString:@"4ecc1f16-0c5e-11e4-ac3e-276b00000a10"];
            break;
            
        case LYRUINA3Development:
            return [[NSUUID alloc] initWithUUIDString:@"ce2c45a4-3e97-11e4-9d4c-6a9900000431"];
            break;
            
        case LYRUIDEV1Production:
            return [[NSUUID alloc] initWithUUIDString:@"9ae66b44-1682-11e4-92e4-0b53000001d0"];
            break;
            
        case LYRUIDEV1Development:
            return [[NSUUID alloc] initWithUUIDString:@"78b0f39a-3e97-11e4-9f88-48e000000212"];
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
        case LYRUINA3Production:
            return [LSApplicationDataDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqllite", LSLayerAppID(environment)]];
            break;
            
        case LYRUINA3Development:
            return [LSApplicationDataDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqllite", LSLayerAppID(environment)]];
            break;
            
        case LYRUIDEV1Production:
            return [LSApplicationDataDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqllite", LSLayerAppID(environment)]];
            break;
            
        case LYRUIDEV1Development:
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

