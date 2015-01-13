//
//  LSCenterTextTableViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/24/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSCenterTextTableViewCell.h"

@implementation LSCenterTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.centerTextLabel = [[UILabel alloc] init];
        self.centerTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.centerTextLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.centerTextLabel];
        
        [self setUpConstraints];
    }
    return self;
}

- (void)setUpConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.centerTextLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:10.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.centerTextLabel
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:-10.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.centerTextLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
}

@end
