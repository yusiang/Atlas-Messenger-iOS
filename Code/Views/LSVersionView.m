//
//  LSVersionView.m
//  LayerSample
//
//  Created by Zac White on 7/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSVersionView.h"
#import "LSUIConstants.h"

@interface LSVersionView ()

@property (strong, nonatomic) UILabel *topLabel;
@property (strong, nonatomic) UILabel *bottomLabel;

@end

@implementation LSVersionView

- (void)LSVersionView_setup
{
    self.backgroundColor = [UIColor clearColor];

    self.topLabel = [[UILabel alloc] init];
    self.topLabel.font = LSBoldFont(12.0);
    self.topLabel.textColor = LSGrayColor();
    self.topLabel.textAlignment = NSTextAlignmentCenter;

    self.bottomLabel = [[UILabel alloc] init];
    self.bottomLabel.font = LSMediumFont(11.0);
    self.bottomLabel.textColor = LSGrayColor();
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;

    [self addSubview:self.topLabel];
    [self addSubview:self.bottomLabel];
}

static const CGFloat LSVersionViewXPadding = 5.0f;
static const CGFloat LSVersionViewYPadding = 5.0f;

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect topLabelFrame, bottomLabelFrame;
    CGRect insetBounds = CGRectInset(self.bounds, LSVersionViewXPadding, LSVersionViewYPadding);
    CGRectDivide(insetBounds, &topLabelFrame, &bottomLabelFrame, (int)(insetBounds.size.height / 2.0), CGRectMinYEdge);
    self.topLabel.frame = topLabelFrame;
    self.bottomLabel.frame = bottomLabelFrame;
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;

    [self LSVersionView_setup];

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super initWithCoder:aDecoder])) return nil;

    [self LSVersionView_setup];

    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize topSize = [self.topLabel sizeThatFits:size];
    CGSize bottomSize = [self.bottomLabel sizeThatFits:size];

    return CGSizeMake(MAX(topSize.width, bottomSize.width) + 2 * LSVersionViewXPadding, topSize.height + bottomSize.height + 2 * LSVersionViewYPadding);
}

@end
