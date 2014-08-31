//
//  LSContactActionCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRContactActionCell.h"
#import "LSUIConstants.h"

@interface LYRContactActionCell ()

@property (nonatomic, strong) UILabel *actionLabel;

@end

@implementation LYRContactActionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.actionLabel = [[UILabel alloc] init];
        self.actionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.actionLabel.font = [UIFont systemFontOfSize:14];
        self.actionLabel.textColor = LSBlueColor();
        [self.contentView addSubview:self.actionLabel];
        
    }
    return self;
}

- (void)updateConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.actionLabel
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.actionLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0 constant:0]];
    
    [super updateConstraints];
}

- (void)updateWithActionTitle:(NSString *)actionTitle
{
    self.actionLabel.text = actionTitle;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:FALSE animated:animated];
}

@end
