//
//  LSButton.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// SBW: What's up with the shadow API's? I'd probably use a category on UIButton if this stuff is really useful
@interface LSButton : UIButton

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic) double width;
@property (nonatomic) double height;
@property (nonatomic) double centerY;

- (id)initWithText:(NSString *)text;

@end
