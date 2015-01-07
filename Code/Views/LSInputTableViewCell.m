//
//  LSInputTableViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSInputTableViewCell.h"
#import "LYRUIConstants.h"

@interface LSInputTableViewCell ()

@property (nonatomic) UILabel *guideLabel;

@end

@implementation LSInputTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _textField = [[UITextField alloc] init];
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.font = LYRUIMediumFont(16);
        _textField.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_textField];
        
        _guideLabel = [[UILabel alloc] init];
        _guideLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _guideLabel.font = LYRUIMediumFont(14);
        _guideLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_guideLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self setUpConstraints];
    }
    
    return self;
}

- (void)setUpConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.guideLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.guideLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.guideLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:10]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

- (void)setGuideText:(NSString *)guideText
{
    self.guideLabel.text = guideText;
    self.guideLabel.accessibilityLabel = guideText;
    [self.guideLabel sizeToFit];
}

- (void)setPlaceHolderText:(NSString *)placeHolderText
{
    self.textField.accessibilityLabel = placeHolderText;
    self.textField.placeholder = placeHolderText;
}

@end
