//
//  LSRegistrationViewController.h
//  QRCodeTest
//
//  Created by Kevin Coleman on 2/15/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATLMApplicationController.h"

@interface LSRegistrationViewController : UIViewController

@property (nonatomic) NSString *applicationID;

@property (nonatomic) ATLMApplicationController *applicationController;

@end
