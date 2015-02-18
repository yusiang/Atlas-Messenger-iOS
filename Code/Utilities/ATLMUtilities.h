//
//  ATLMUtilities.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 7/1/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "ATLMPersistenceManager.h"

/**
 @abstract `ATLMUtilities` provides convenience functions for app configuration.
 */

typedef NS_ENUM(NSInteger, ATLMEnvironment) {
    ATLMProductionEnvironment,           // Layer production environment w/ prod APNs
    ATLMProductionDebugEnvironment,      // Layer production environment w/ dev APNs
    ATLMStagingEnvironment,              // Layer staging environment w/ prod APNs
    ATLMStagingDebugEnvironment,         // Layer staging environment w/ dev APNs
    ATLMTestEnvironment,                 // Layer test Environment
    ATLMAdHocEnvironment,                // Coleman AdHoc test environment
    ATLMLoadTestEnvironment              // Layer load testing environment
};

/**
 @abstract Posted when the sample app encounters an unknown participant identifier.
 */
extern NSString *const ATLMAppEncounteredUnknownUser;

BOOL ATLMIsRunningTests();

NSURL *ATLMRailsBaseURL();

NSString *ATLMLayerConfigurationURL(ATLMEnvironment);

NSUUID *ATLMLayerAppID(ATLMEnvironment);

NSString *ATLMApplicationDataDirectory();

ATLMPersistenceManager *ATLMPersitenceManager();

void ATLMAlertWithError(NSError *error);
