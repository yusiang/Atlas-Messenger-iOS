//
//  ATLMUtilities.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 7/1/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
