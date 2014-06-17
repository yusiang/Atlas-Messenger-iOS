//
//  LSButton.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSButton.h"
#import "LSUIConstants.h"

@interface LSButton ()

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation LSButton

@synthesize textLabel = _textLabel;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithText:(NSString *)text
{
    self = [super init];
    if (self) {
        [self setText:text];
        [self setAccessibilityLabel:[NSString stringWithFormat:@"%@ Button", text]];
        [self setFont:[UIFont fontWithName:[LSUIConstants layerMediumFont] size:20]];
        [self setBackgroundColor:[LSUIConstants layerBlueColor]];
        [self.layer setCornerRadius:4.0f];
    }
    return self;
}


- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self sizeAndCenterLabel];
}

- (void)setText:(NSString *)text
{
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.text = text;
    self.textLabel.textColor = [UIColor whiteColor];
    self.accessibilityLabel = text;
    [self sizeAndCenterLabel];
    [self addSubview:self.textLabel];
}

- (void)setFont:(UIFont *)font
{
    self.textLabel.font = font;
    [self sizeAndCenterLabel];
}

- (void)setTextColor:(UIColor *)textColor
{
    self.textLabel.textColor = textColor;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = 2;
}

- (void)setCenterY:(double)centerY
{
    self.frame = CGRectMake(self.frame.origin.x, centerY, self.frame.size.width, self.frame.size.height);
}

- (void)sizeAndCenterLabel
{
    [self.textLabel sizeToFit];
    self.textLabel.center = self.center;
}

@end
