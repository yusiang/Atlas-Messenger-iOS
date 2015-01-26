//
//  LSUtilities.h
//  LayerSample
//
//  Created by Kevin Coleman on 7/1/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "LSPersistenceManager.h"

/**
 @abstract `LSUtilities` provides convenience functions for app configuration.
 */

typedef NS_ENUM(NSInteger, LSEnvironment) {
    LSProductionEnvironment,           // Layer production environment w/ prod APNs
    LSProductionDebugEnvironment,      // Layer production environment w/ dev APNs
    LSStagingEnvironment,              // Layer staging environment w/ prod APNs
    LSStagingDebugEnvironment,         // Layer staging environment w/ dev APNs
    LSTestEnvironment,                 // Layer test Environment
    LSAdHocEnvironment,                // Coleman AdHoc test environment
    LSLoadTestEnvironment              // Layer load testing environment
};

/**
 @abstract Posted when the sample app encounters and unknown participant identifier.
 */
extern NSString *const LSAppEncounteredUnknownUser;

BOOL LSIsRunningTests();

NSURL *LSRailsBaseURL();

NSString *LSLayerConfigurationURL(LSEnvironment);

NSUUID *LSLayerAppID(LSEnvironment);

NSString *LSApplicationDataDirectory();

LSPersistenceManager *LSPersitenceManager();

void LSAlertWithError(NSError *error);
