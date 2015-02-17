//
//  LSSettingsHeaderView.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/23/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSSettingsHeaderView.h"
#import <Atlas/Atlas.h>

@interface LSSettingsHeaderView ()

@property (nonatomic) LSUser *user;
@property (nonatomic) ATLAvatarImageView *imageView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *connectionStateLabel;
@property (nonatomic) UIView *bottomBorder;

@end

@implementation LSSettingsHeaderView

static CGFloat const LSAvatarDiameter = 72;

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

        _imageView = [[ATLAvatarImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.initialsFont = ATLLightFont(22);
        _imageView.initialsColor = ATLGrayColor();
        _imageView.backgroundColor = ATLLightGrayColor();
        _imageView.layer.cornerRadius = LSAvatarDiameter / 2;
        _imageView.avatarItem = user;
        [self addSubview:_imageView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.text = user.fullName;
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = ATLGrayColor();
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_nameLabel];
        
        _connectionStateLabel = [[UILabel alloc] init];
        _connectionStateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _connectionStateLabel.font = [UIFont systemFontOfSize:14];
        _connectionStateLabel.textColor = ATLBlueColor();
        _connectionStateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_connectionStateLabel];
    
        _bottomBorder = [[UIView alloc] init];
        _bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomBorder.backgroundColor = ATLGrayColor();
        [self addSubview:_bottomBorder];

        [self setUpAvatarImageViewConstraints];
        [self setUpNameLabelConstraints];
        [self setUpConnectionLabelConstraints];
        [self setUpBottomBorderConstraints];
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
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStateLabel
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStateLabel
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:0.0
                                                      constant:20]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStateLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStateLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.nameLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0]];
}

- (void)setUpBottomBorderConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorder
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorder
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:0.5]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorder
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorder
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:0]];
}

- (void)updateConnectedStateWithString:(NSString *)string
{
    self.connectionStateLabel.text = string;
}

@end
