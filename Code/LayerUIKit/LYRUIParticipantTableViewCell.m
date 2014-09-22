//
//  LYRUIParticipantTableViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIParticipantTableViewCell.h"
#import "LYRUIConstants.h"
#import "LYRUISelectionIndicator.h"

@interface LYRUIParticipantTableViewCell ()

@property (nonatomic, strong) UIControl *selectionIndicator;
@property (nonatomic) BOOL isSelected;

@end

@implementation LYRUIParticipantTableViewCell

static CGFloat const LSSelectionIndicatorSize = 30;
static CGFloat const LSSelectionIndicatorRightMargin = -20;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.selectionIndicator = [LYRUISelectionIndicator initWithDiameter:LSSelectionIndicatorSize];
        self.selectionIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.selectionIndicator];
    }
    
    return self;
}

- (void)presentParticipant:(id<LYRUIParticipant>)participant
{
    self.textLabel.text = [participant fullName];
    self.accessibilityLabel = [participant fullName];
    [self updateConstraints];
}

- (void)updateWithSelectionIndicator:(UIControl *)selectionIndicator
{

}

- (void)shouldShowSelectionIndicator:(BOOL)shouldShowSelectionIndicator
{
    if (shouldShowSelectionIndicator) {
        self.selectionIndicator.alpha = 0.0;
    } else {
        self.selectionIndicator.alpha = 1.0;
    }
}

- (void)updateConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionIndicator
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSSelectionIndicatorSize]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionIndicator
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSSelectionIndicatorSize]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionIndicator
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionIndicator
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:LSSelectionIndicatorRightMargin]];
    
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self.selectionIndicator setHighlighted:selected];
    
    if (self.selectionIndicator.highlighted) {
        self.selectionIndicator.accessibilityLabel = [NSString stringWithFormat:@"%@ selected", self.accessibilityLabel];
    } else {
        self.selectionIndicator.accessibilityLabel = @"";
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Configure UI Appearance Proxy
    self.textLabel.font = self.titleFont;
    self.textLabel.textColor = self.titleColor;
}

@end
