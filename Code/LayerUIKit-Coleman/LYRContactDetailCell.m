//
//  LYRContactDetailCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRContactDetailCell.h"
#import "LSUIConstants.h"

@interface LYRContactDetailCell ()

@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *detailContent;

@end
@implementation LYRContactDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       
        self.detailLabel = [[UILabel alloc] init];
        self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.detailLabel.font = [UIFont systemFontOfSize:14];
        self.detailLabel.textColor = LSGrayColor();
        [self.contentView addSubview:self.detailLabel];
        
        self.detailContent = [[UILabel alloc] init];
        self.detailContent.translatesAutoresizingMaskIntoConstraints = NO;
        self.detailContent.font = [UIFont systemFontOfSize:14];
        self.detailContent.textColor = LSBlueColor();
        [self.contentView addSubview:self.detailContent];
    }
    
    return self;
}

- (void)updateWithContentType:(LYRContactCellContentType)contentType content:(NSString *)content;
{
    switch (contentType) {
        case LYRContactCellContentTypeEmail:
            self.detailLabel.text = @"Email:";
            self.detailContent.text = content;
            break;
        case LYRContactCellContentTypePhone:
            self.detailLabel.text = @"Phone:";
            self.detailContent.text = content;
            break;
        default:
            break;
    }
    [self.detailLabel sizeToFit];
    [self.detailContent sizeToFit];
}

- (void)updateConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:20]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailContent
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailContent
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
