//
//  LSQRCodeScannerController.h
//  LayerSample
//
//  Created by Kevin Coleman on 2/14/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATLMApplicationController.h"

extern NSString *const ATLMDidReceiveLayerAppID;

@interface ATLMQRScannerController : UIViewController

@property (nonatomic) ATLMApplicationController *applicationController;

- (void)presentRegistrationViewController;

@end
