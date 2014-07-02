//
//  LSUIConstants.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/17/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSUIConstants.h"


UIColor *LSBlueColor()
{
    return [UIColor colorWithRed:36.0f/255.0f green:166.0f/255.0f blue:225.0f/255.0f alpha:1.0];
}

UIColor *LSGrayColor()
{
    return [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0];
}

UIColor *LSLighGrayColor()
{
    return [UIColor colorWithRed:36.0f/255.0f green:166.0f/255.0f blue:225.0f/255.0f alpha:1.0];
}

NSString *LSMediumFont()
{
    return @"Avenir-Medium";
}

NSString *LSBoldFont()
{
    return @"Avenir-Medium";
}

NSString *LSHeavyFont()
{
    return @"Avenir-Medium";
}


@implementation LSUIConstants

+ (UIColor *)layerBlueColor
{
    return [UIColor colorWithRed:36.0f/255.0f green:166.0f/255.0f blue:225.0f/255.0f alpha:1.0];
}

+ (UIColor *)veryLightGrayColor
{
    return [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0];
}

+ (UIColor *)layerGrayColor
{
    return [UIColor colorWithRed:36.0f/255.0f green:166.0f/255.0f blue:225.0f/255.0f alpha:1.0];
}

+ (NSString *)layerMediumFont
{
    return @"Avenir-Medium";
}

+ (NSString *)layerBoldFont
{
    return @"Avenir-Medium";
}

+ (NSString *)layerHeavyFont
{
    return @"Avenir-Medium";
}

@end
