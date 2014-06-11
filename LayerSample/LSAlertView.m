//
//  LSAlertView.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSAlertView.h"

@implementation LSAlertView

- (id) init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (void)matchingPasswordAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password Error"
                                                        message:@"Please make sure that your passwords match"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    alertView.accessibilityLabel = @"Alert";
    [alertView show];
}

+ (void)missingPasswordAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password Error"
                                                        message:@"Please Enter a Password"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    alertView.accessibilityLabel = @"Alert";
    [alertView show];
}

@end
