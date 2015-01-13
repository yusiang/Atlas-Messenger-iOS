//
//  LSSettingsHeaderView.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/23/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSSettingsHeaderView.h"
#import "LYRUIAvatarImageView.h"
#import "LYRUIConstants.h" 

@interface LSSettingsHeaderView ()

@property (nonatomic) LSUser *user;
@property (nonatomic) LYRUIAvatarImageView *imageView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *connectionStateLabel;

@end

@implementation LSSettingsHeaderView

static CGFloat const LSAvatarDiameter  = 72;

+ (instancetype)headerViewWithUser:(LSUser *)user
{
    return [[self alloc] initHeaderViewWithUser:user];
}

- (id)initHeaderViewWithUser:(LSUser *)user
{
    self = [super init];
    if (self) {
        _user = user;
        
        self.backgroundColor = [UIColor whiteColor];

        _imageView = [[LYRUIAvatarImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.initialsFont = LYRUILightFont(22);
        _imageView.initialsColor = LYRUIGrayColor();
        _imageView.backgroundColor = LYRUILightGrayColor();
        _imageView.layer.cornerRadius = LSAvatarDiameter / 2;
        [_imageView setInitialsForName:user.fullName];
        [self addSubview:_imageView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.text = user.fullName;
        _nameLabel.font = LYRUILightFont(16);
        _nameLabel.textColor = LYRUIGrayColor();
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_nameLabel];
        
        _connectionStateLabel = [[UILabel alloc] init];
        _connectionStateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _connectionStateLabel.font = LYRUILightFont(14);
        _connectionStateLabel.textColor = LYRUIBlueColor();
        _connectionStateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_connectionStateLabel];
    
        [self setUpAvatarImageViewConstraints];
        [self setUpNameLabelConstraints];
        [self setUpConnectionLabelConstraints];
    }
    return self;
}

- (void)setUpAvatarImageViewConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:LSAvatarDiameter]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:LSAvatarDiameter]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:20]];
}

- (void)setUpNameLabelConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:4]];
}

- (void)setUpConnectionLabelConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStateLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStateLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:20]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStateLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
}

- (void)updateConnectedStateWithString:(NSString *)string
{
    self.connectionStateLabel.text = string;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIView *blackLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 0.5, self.frame.size.width, 0.5)];
    blackLine.backgroundColor = LYRUIGrayColor();
    [self addSubview:blackLine];
}

@end
