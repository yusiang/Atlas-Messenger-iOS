//
//  LSUIConstants.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/17/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

static NSString *const LSFontMedium = @"Avenir-Medium";
static NSString *const LSFontBold = @"Avenir-Heavy";
static NSString *const LSFontHeavy = @"Avenir-Black";

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

UIFont *LSMediumFont(CGFloat size)
{
    return [UIFont fontWithName:LSFontMedium size:size];
}

UIFont *LSBoldFont(CGFloat size)
{
    return [UIFont fontWithName:LSFontBold size:size];
}

UIFont *LSHeavyFont(CGFloat size)
{
    return [UIFont fontWithName:LSFontHeavy size:size];;
}
