//
//  LSContactHeaderCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRContactHeaderCell.h"

@interface LYRContactHeaderCell ()

@property (nonatomic, strong) UIImageView *contactImageView;
@property (nonatomic, strong) UILabel *contactPrimaryText;
@property (nonatomic, strong) UILabel *contactSecondaryText;

@end

@implementation LYRContactHeaderCell

static CGFloat const LYRContactImageViewDiameter = 60.0f;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contactImageView = [[UIImageView alloc] init];
        self.contactImageView.backgroundColor = [UIColor lightGrayColor];
        self.contactImageView.layer.cornerRadius = LYRContactImageViewDiameter / 2;
        self.contactImageView.clipsToBounds = TRUE;
        self.contactImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.contactImageView];
        
        self.contactPrimaryText = [[UILabel alloc] init];
        self.contactPrimaryText.font = [UIFont systemFontOfSize:14];
        self.contactPrimaryText.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.contactPrimaryText];
        
        self.contactSecondaryText = [[UILabel alloc] init];
        self.contactSecondaryText.font = [UIFont systemFontOfSize:12];
        self.contactSecondaryText.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.contactSecondaryText];

    }
    return self;
}

- (void)updateWithPresenter:(id<LYRContactPresenter>)presenter
{
    self.contactImageView.image = [presenter contactImage];
    
    self.contactPrimaryText.text = [presenter primaryContactText];
    [self.contactPrimaryText sizeToFit];
    
    self.contactSecondaryText.text = [presenter secondaryContactText];
    [self.contactSecondaryText sizeToFit];
    
    [self updateConstraints];
}

- (void)updateConstraints
{
    //**********Center X**********//
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contactImageView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0]];
    
    //**********Center Y**********//
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contactImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:-20]];
    
    //**********Width**********//
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contactImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LYRContactImageViewDiameter]];
    
    //**********Height**********//
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contactImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LYRContactImageViewDiameter]];
    
    //**********Height**********//
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contactPrimaryText
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contactImageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:16]];
    
    //**********Height**********//
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contactPrimaryText
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0]];
    
    //**********Height**********//
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contactSecondaryText
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contactPrimaryText
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:10]];
    
    //**********Height**********//
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contactSecondaryText
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0]];
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:FALSE animated:animated];

    // Configure the view for the selected state
}

@end
