//
//  LSAlertView.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 SBW: Typically these kinds of classes are a design smell. Error messges for validation failures should be
 emitted from the model layer. Typically with a well designed `NSError` implementation you can use the 
 `localizedDescription` as the value for the alert message and just go with a generic title.
 */
@interface LSAlertView : NSObject

+ (void)missingEmailAlert;

+ (void)matchingPasswordAlert;

+ (void)missingPasswordAlert;

+ (void)invalidLoginCredentials;

+ (void)existingUsernameAlert;

@end
