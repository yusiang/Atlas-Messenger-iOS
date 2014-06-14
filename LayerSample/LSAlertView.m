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

+ (void)missingEmailAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Email"
                                                        message:@"Please enter an email address"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    alertView.accessibilityLabel = @"Alert";
    [alertView show];
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

+(void)invalidLoginCredentials
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Credentials"
                                                        message:@"Please check your login credentials and try again"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    alertView.accessibilityLabel = @"Alert";
    [alertView show];
}

+(void)existingUsernameAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Email Already Exists"
                                                         message:@"Please choose another username and try again"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    alertView.accessibilityLabel = @"Alert";
    [alertView show];
}
@end
