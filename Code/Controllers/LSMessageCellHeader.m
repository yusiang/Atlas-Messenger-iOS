//
//  LSMessageCellHeader.m
//  LayerSample
//
//  Created by Kevin Coleman on 7/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSMessageCellHeader.h"
#import "LSUIConstants.h"

@interface LSMessageCellHeader ()

@property (nonatomic) UILabel *label;

@end

@implementation LSMessageCellHeader

- (void)updateWithSenderName:(NSString *)senderName
{
    self.label = [[UILabel alloc] init];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.text = senderName;
    self.label.font = LSMediumFont(12);
    self.label.textColor = LSGrayColor();
    [self.label sizeToFit];
    [self addSubview:self.label];
    [self configureLayoutConstraints];
}

- (void)configureLayoutConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:72]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-6]];
}

@end
