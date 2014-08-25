//
//  LYRConversationCell.m
//  LayerSample
//
//  Created by Zac White on 8/13/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "ZacConversationExample.h"

@interface ZacConversationExample ()

@end

static const CGFloat LYRConversationCellLargePadding = 12.0f;
static const CGFloat LYRConversationCellSmallPadding = 5.0f;
static const CGFloat LYRConversationAvatarImageViewEdge = 45.0f;

@implementation ZacConversationExample

- (void)LYRConversationCell_setup
{
    self.senderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.senderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.senderLabel.font = [UIFont systemFontOfSize:14];
    self.senderLabel.textColor = [UIColor blackColor];

    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.dateLabel.font = [UIFont systemFontOfSize:12];
    self.dateLabel.textColor = [UIColor grayColor];

    self.lastMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.lastMessageLabel.numberOfLines = 0;
    self.lastMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.lastMessageLabel.font = [UIFont systemFontOfSize:14];
    self.lastMessageLabel.textColor = [UIColor darkGrayColor];

    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.avatarImageView.backgroundColor = [UIColor grayColor];
    self.avatarImageView.layer.cornerRadius = CGRectGetWidth(self.avatarImageView.frame) / 2.0;
    self.avatarImageView.clipsToBounds = YES;

    [self.contentView addSubview:self.senderLabel];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.lastMessageLabel];
    [self.contentView addSubview:self.avatarImageView];

    // Apply constraints.
//    [self applyLayoutConstraints];

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;

    [self LYRConversationCell_setup];

    return self;
}

//#pragma mark
//#pragma mark Layout Code
//- (void)applyLayoutConstraints
//{
//    //**********Avatar Constraints**********//
//    // Width
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
//                                                                 attribute:NSLayoutAttributeWidth
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.contentView
//                                                                 attribute:NSLayoutAttributeHeight
//                                                                multiplier:LSAvatarImageViewSizeRatio
//                                                                  constant:0]];
//    
//    // Height
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
//                                                                 attribute:NSLayoutAttributeHeight
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.contentView
//                                                                 attribute:NSLayoutAttributeHeight
//                                                                multiplier:LSAvatarImageViewSizeRatio
//                                                                  constant:0]];
//    
//    // Left Margin
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
//                                                                 attribute:NSLayoutAttributeLeft
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.contentView
//                                                                 attribute:NSLayoutAttributeLeft
//                                                                multiplier:1.0
//                                                                  constant:LSCellHorizontalMargin]];
//    
//    // Center vertically
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
//                                                                 attribute:NSLayoutAttributeCenterY
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.contentView
//                                                                 attribute:NSLayoutAttributeCenterY
//                                                                multiplier:1.0
//                                                                  constant:0]];
//    
//    //**********Sender Label Test Constraints**********//
//    // Left Margin
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.senderLabel
//                                                                 attribute:NSLayoutAttributeLeft
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.avatarImageView
//                                                                 attribute:NSLayoutAttributeRight
//                                                                multiplier:1.0
//                                                                  constant:LSCellHorizontalMargin]];
//    // Right Margin
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.senderLabel
//                                                                 attribute:NSLayoutAttributeRight
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.contentView
//                                                                 attribute:NSLayoutAttributeRight
//                                                                multiplier:1.0
//                                                                  constant:LSCellSenderLabelRightMargin]];
//    // Top Margin
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.senderLabel
//                                                                 attribute:NSLayoutAttributeTop
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.contentView
//                                                                 attribute:NSLayoutAttributeTop
//                                                                multiplier:1.0
//                                                                  constant:LSCellTopMargin]];
//    // Height
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.senderLabel
//                                                                 attribute:NSLayoutAttributeHeight
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.contentView
//                                                                 attribute:NSLayoutAttributeHeight
//                                                                multiplier:0.25
//                                                                  constant:0]];
//    
//    //**********Message Text Constraints**********//
//    //Left Margin
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextView
//                                                                 attribute:NSLayoutAttributeLeft
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.avatarImageView
//                                                                 attribute:NSLayoutAttributeRight
//                                                                multiplier:1.0
//                                                                  constant:LSCellHorizontalMargin]];
//    // Right Margin
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextView
//                                                                 attribute:NSLayoutAttributeRight
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.contentView
//                                                                 attribute:NSLayoutAttributeRight
//                                                                multiplier:1.0
//                                                                  constant:-LSCellHorizontalMargin]];
//    // Top Margin
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextView
//                                                                 attribute:NSLayoutAttributeTop
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.senderLabel
//                                                                 attribute:NSLayoutAttributeBottom
//                                                                multiplier:1.0
//                                                                  constant:0]];
//    // Bottom Margin
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextView
//                                                                 attribute:NSLayoutAttributeBottom
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.contentView
//                                                                 attribute:NSLayoutAttributeBottom
//                                                                multiplier:1.0
//                                                                  constant:-LSCellBottomMargin]];
//    
//    //**********Date Label Constraints**********//
//    // Left Margin
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
//                                                                 attribute:NSLayoutAttributeLeft
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.senderLabel
//                                                                 attribute:NSLayoutAttributeRight
//                                                                multiplier:1.0
//                                                                  constant:LSCellDateLabelLeftMargin]];
//    // Right Margin
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
//                                                                 attribute:NSLayoutAttributeRight
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.contentView
//                                                                 attribute:NSLayoutAttributeRight
//                                                                multiplier:1.0
//                                                                  constant:-10]];
//    // Height
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
//                                                                 attribute:NSLayoutAttributeHeight
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.senderLabel
//                                                                 attribute:NSLayoutAttributeHeight
//                                                                multiplier:1.0
//                                                                  constant:0]];
//    // Top Margin
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
//                                                                 attribute:NSLayoutAttributeTop
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.contentView
//                                                                 attribute:NSLayoutAttributeTop
//                                                                multiplier:1.0
//                                                                  constant:LSCellTopMargin]];
//}
//    
//- (void)updateWithPresenter:(id<LYRConversationPresenter>)presenter
//{
//    self.senderLabel.text = [presenter titleText];
//    self.dateLabel.text = [presenter dateText];
//    self.lastMessageLabel.text = [presenter lastMessageText];
//    self.avatarImageView.image = [presenter avatarImage];
//
//    [self setNeedsUpdateConstraints];
//}

@end
