//
//  LSUIConstants.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/17/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSUIConstants : NSObject

+ (UIColor *)layerBlueColor;

+ (UIColor *)layerGrayColor;

// SBW: The font names should be NSString constants and these methods can return `UIFont` instances
+ (NSString *)layerMediumFont;

+ (NSString *)layerBoldFont;

+ (NSString *)layerHeavyFont;

@end
