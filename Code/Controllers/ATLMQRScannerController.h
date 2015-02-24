//
//  LSQRCodeScannerController.h
//  LayerSample
//
//  Created by Kevin Coleman on 2/14/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATLMApplicationController.h"

/**
 @abstract Posted when the `ATLMQRScannerController succesfully scans a QR code and receives a valid Layer App ID>
 */
extern NSString *const ATLMDidReceiveLayerAppID;


/** 
 @abstract The `ATLMQRScannerController` presents a user interface for scanning QR codes. 
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
