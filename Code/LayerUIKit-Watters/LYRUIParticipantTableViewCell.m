//
//  LYRUIParticipantTableViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIParticipantTableViewCell.h"
#import "LSUIConstants.h"
#import "LYRUISelectionIndicator.h"

@interface LYRUIParticipantTableViewCell ()

@property (nonatomic, strong) UIControl *selectionIndicator;
@property (nonatomic) BOOL isSelected;

@end

@implementation LYRUIParticipantTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.textLabel.font = LSMediumFont(14);
        [self setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 0)];
        
        self.selectionIndicator = [LYRUISelectionIndicator initWithDiameter:30];
        self.selectionIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.selectionIndicator];
    }
    return self;
}

- (void)presentParticipant:(id<LYRUIParticipant>)participant
{
    self.textLabel.text = [participant fullName];
}

- (void)updateConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionIndicator attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionIndicator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionIndicator attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20]];
    
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];
    [self.selectionIndicator setHighlighted:selected];
}

@end
