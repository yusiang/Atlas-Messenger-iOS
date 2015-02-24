//
//  LSQRCodeScannerController.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 2/14/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
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

#import <UIKit/UIKit.h>
#import "ATLMApplicationController.h"

/**
 @abstract Posted when the `ATLMQRScannerController succesfully scans a QR code and receives a valid Layer App ID>
 */
extern NSString *const ATLMDidReceiveLayerAppID;

/** 
 @abstract The `ATLMQRScannerController` presents a user interface for scanning QR codes. When a QR code is succesfully scanned, it is persisted to the `NSUserDefaults` dictionary as the value for the `ATLMLayerApplicationID` key.
 */
@interface ATLMQRScannerController : UIViewController

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) ATLMApplicationController *applicationController;

/**
 @abstract Programmatically pushes an `ATLMRegistrationViewController` on to the current navigation stack.
 */
- (void)presentRegistrationViewController;

@end
