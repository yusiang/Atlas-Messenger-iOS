//
//  LSVersionView.m
//  LayerSample
//
//  Created by Zac White on 7/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSVersionView.h"
#import "LYRUIConstants.h"
#import <LayerKit/LayerKit.h>

@interface LSVersionView ()

@property (nonatomic) UILabel *versionLabel;
@property (nonatomic) UILabel *buildLabel;
@property (nonatomic) UILabel *hostLabel;
@property (nonatomic) UILabel *userLabel;
@property (nonatomic) UILabel *deviceLabel;
@property (nonatomic) UILabel *connectedLabel;

@end

@implementation LSVersionView

- (void)LSVersionView_setup
{
    self.backgroundColor = [UIColor clearColor];

    self.versionLabel = [[UILabel alloc] init];
    self.versionLabel.font = LSBoldFont(12.0);
    self.versionLabel.textColor = [UIColor grayColor];
    self.versionLabel.textAlignment = NSTextAlignmentCenter;

    self.buildLabel = [[UILabel alloc] init];
    self.buildLabel.font = LSMediumFont(11.0);
    self.buildLabel.textColor = [UIColor grayColor];
    self.buildLabel.textAlignment = NSTextAlignmentCenter;
    
    self.hostLabel = [[UILabel alloc] init];
    self.hostLabel.font = LSMediumFont(10.0);
    self.hostLabel.textColor = [UIColor grayColor];
    self.hostLabel.textAlignment = NSTextAlignmentCenter;
    
    self.userLabel = [[UILabel alloc] init];
    self.userLabel.font = LSMediumFont(10.0);
    self.userLabel.textColor = [UIColor grayColor];
    self.userLabel.textAlignment = NSTextAlignmentCenter;
    
    self.deviceLabel = [[UILabel alloc] init];
    self.deviceLabel.font = LSMediumFont(10.0);
    self.deviceLabel.textColor = [UIColor grayColor];
    self.deviceLabel.textAlignment = NSTextAlignmentCenter;
    
    self.connectedLabel = [[UILabel alloc] init];
    self.connectedLabel.font = LSMediumFont(10.0);
    self.connectedLabel.textColor = [UIColor grayColor];
    self.connectedLabel.textAlignment = NSTextAlignmentCenter;

    [self addSubview:self.versionLabel];
    [self addSubview:self.buildLabel];
    [self addSubview:self.hostLabel];
    [self addSubview:self.userLabel];
    [self addSubview:self.deviceLabel];
    [self addSubview:self.connectedLabel];
}

static const CGFloat LSVersionViewXPadding = 5.0f;
static const CGFloat LSVersionViewYPadding = 5.0f;

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect insetBounds = CGRectInset(self.bounds, LSVersionViewXPadding, LSVersionViewYPadding);
    CGFloat height = insetBounds.size.height / 4;
    self.versionLabel.frame = CGRectMake(insetBounds.origin.x, insetBounds.origin.y, insetBounds.size.width, height);
    self.buildLabel.frame = CGRectOffset(self.versionLabel.frame, 0, height);
    self.hostLabel.frame = CGRectOffset(self.buildLabel.frame, 0, height);
    self.userLabel.frame = CGRectOffset(self.hostLabel.frame, 0, height);
    self.deviceLabel.frame = CGRectOffset(self.userLabel.frame, 0, height);
    self.connectedLabel.frame = CGRectOffset(self.deviceLabel.frame, 0, height);
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
    CGSize versionSize = [self.versionLabel sizeThatFits:size];
    CGSize buildSize = [self.buildLabel sizeThatFits:size];
    CGSize hostSize = [self.hostLabel sizeThatFits:size];
    CGSize userSize = [self.userLabel sizeThatFits:size];
    CGSize deviceSize = [self.deviceLabel sizeThatFits:size];
    CGSize connectedSize = [self.connectedLabel sizeThatFits:size];
    return CGSizeMake(MAX(versionSize.width, MAX(buildSize.width, MAX(hostSize.width, MAX(userSize.width, deviceSize.width)))) + 2 * LSVersionViewXPadding,
                      versionSize.height + buildSize.height + hostSize.height + userSize.height + deviceSize.height + connectedSize.height + 2 * LSVersionViewYPadding);
}


@end

