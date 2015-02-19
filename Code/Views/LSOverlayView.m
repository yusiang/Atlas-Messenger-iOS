//
//  LSOverlayView.m
//  QRCodeTest
//
//  Created by Kevin Coleman on 2/15/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import "LSOverlayView.h"
#import <Atlas/Atlas.h> 

@interface LSOverlayView ()

@property (nonatomic) UILabel *instructionsLabel;
@property (nonatomic) UIImageView *logoImage;

@end

@implementation LSOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setupOverlayMaskWithFrame:frame];
        
        self.instructionsLabel = [[UILabel alloc] init];
        self.instructionsLabel.numberOfLines = 3;
        self.instructionsLabel.text = @"POINT THE DEVICE\n TOWARDS YOUR SCREEN\n AND SCAN THE CODE";
        self.instructionsLabel.textAlignment = NSTextAlignmentCenter;
        self.instructionsLabel.font = [UIFont systemFontOfSize:18];
        self.instructionsLabel.textColor = [UIColor whiteColor];
        [self.instructionsLabel sizeToFit];
        self.instructionsLabel.center = CGPointMake(self.center.x, 460);
        [self addSubview:self.instructionsLabel];
        
        self.logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        self.logoImage.center = CGPointMake(self.center.x, 520);
        [self addSubview:self.logoImage];
    }
    return self;
}

- (void)setupOverlayMaskWithFrame:(CGRect)frame
{
    CGFloat size = 240;
    CGFloat originX = (frame.size.width / 2) - (size / 2);
    CGFloat originY = (frame.size.height / 2) - (size / 2);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) cornerRadius:0];
    UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(originX, originY, size, size) cornerRadius:10];
    [path appendPath:cutoutPath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = 0.6;
    [self.layer addSublayer:fillLayer];
    
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.path =[UIBezierPath bezierPathWithRoundedRect:CGRectMake(originX - 1, originY - 1, size + 2, size + 2) cornerRadius:10].CGPath;
    borderLayer.cornerRadius = 10;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = [UIColor whiteColor].CGColor;
    borderLayer.lineDashPattern = @[@6, @6];
    [self.layer addSublayer:borderLayer];
}

@end
