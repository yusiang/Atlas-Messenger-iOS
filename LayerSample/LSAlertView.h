//
//  LSAlertView.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSAlertView : NSObject

+ (void)missingEmailAlert;

+ (void)matchingPasswordAlert;

+ (void)missingPasswordAlert;

+ (void)invalidLoginCredentials;

+ (void)existingUsernameAlert;

@end
