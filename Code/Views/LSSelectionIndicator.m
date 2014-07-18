//
//  LSSelectionIndicator.m
//  LayerSample
//
//  Created by Kevin Coleman on 7/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSSelectionIndicator.h"
#import "LSUIConstants.h"

static inline CGFloat LSDegreesToRadians(CGFloat angle)
{
    return (angle) / 180.0 * M_PI;
}

@interface LSSelectionIndicator ()

@property (nonatomic, strong) UIView *cutout;
@property (nonatomic, strong) UIView *checkMark;

@end

@implementation LSSelectionIndicator

+ (instancetype)initWithDiameter:(CGFloat)diameter
{
    return [[self alloc] initWithDiameter:diameter];
}

- (id)initWithDiameter:(CGFloat)diameter
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, diameter, diameter);
        self.layer.cornerRadius = diameter / 2;
        self.backgroundColor = LSGrayColor();
        
        [self initCutout];
        [self initCheckMark];
    }
    return self;
}

- (void)initCutout
{
    self.cutout = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 2, self.frame.size.width - 2)];
    self.cutout.layer.cornerRadius = (self.frame.size.width - 2) / 2;
    self.cutout.center = self.center;
    self.cutout.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.cutout];
}

#define DegreesToRadians(angle) ((angle) / 180.0 * M_PI)
- (void)initCheckMark
{
    self.checkMark = [[UIView alloc] initWithFrame:CGRectMake(6, 8, 16, 10)];
    self.checkMark.backgroundColor = LSBlueColor();
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:(CGPoint){0, 0}];
    [path addLineToPoint:(CGPoint){4, 0}];
    [path addLineToPoint:(CGPoint){4, 6}];
    [path addLineToPoint:(CGPoint){16, 6}];
    [path addLineToPoint:(CGPoint){16, 12}];
    [path addLineToPoint:(CGPoint){0, 12}];
    
    CAShapeLayer *mask = [CAShapeLayer new];
    mask.frame = self.checkMark.bounds;
    mask.path = path.CGPath;
    
    self.checkMark.layer.mask = mask;
    self.checkMark.accessibilityLabel = @"Selected Checkmark";

    [self addSubview:self.checkMark];
    
    self.checkMark.transform = CGAffineTransformMakeRotation(LSDegreesToRadians(-45));
    self.checkMark.alpha = 1.0f;
}

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        [self addSubview:self.checkMark];
    } else {
        [self.checkMark removeFromSuperview];
    }
}
@end
