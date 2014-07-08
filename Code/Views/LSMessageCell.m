//
//  LSMessageCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSMessageCell.h"
#import "LSUIConstants.h"
#import "LSBubbleView.h"

@interface LSMessageCell ()

@property (nonatomic, strong) LSBubbleView *bubbleView;
@property (nonatomic, strong) UILabel *senderLabel;
@property (nonatomic, strong) LSAvatarImageView *avatarImageView;

@end

@implementation LSMessageCell

static CGFloat const LSAvatarImageViewSize = 30.0f;
static CGFloat const LSAvatarImageViewInset = 6.0f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        //Initialize the backing bubble view
        self.bubbleView = [[LSBubbleView alloc] init];
        self.bubbleView.backgroundColor = [UIColor redColor];
        self.bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.bubbleView];
        
        //Initialize the Sender Label
        self.senderLabel = [[UILabel alloc] init];
        self.senderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.senderLabel];
        
        //Initialize the sender Avatar Image View
        self.avatarImageView = [[LSAvatarImageView alloc] init];
        self.avatarImageView.layer.cornerRadius = (LSAvatarImageViewSize / 2);
        self.avatarImageView.clipsToBounds = YES;
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.avatarImageView];
    }
    return self;
}

- (void)setupSenderCellConstraints
{
    [self.avatarImageView setImage:[UIImage imageNamed:@"kevin"]];
    
    //**********Avatar Image Constraints**********//
    //Width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSAvatarImageViewSize]];
    
    //Height
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSAvatarImageViewSize]];

    //Right Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:-LSAvatarImageViewInset]];
    
    //Bottom Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:-LSAvatarImageViewInset]];
    
    
    //**********Bubble Image Constraints**********//
    //Width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:0.75
                                                                  constant:0.0]];
    
    //Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:0.8
                                                                  constant:12]];

    //Right Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:-10]];
    
    //Bottom Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0]];
}

- (void)setupRecipientCellConstraints
{
   [self.avatarImageView setImage:[UIImage imageNamed:@"kevin"]];
    //**********Avatar Image Constraints**********//
    //Width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSAvatarImageViewSize]];
    
    //Height
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSAvatarImageViewSize]];
    
    //Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:LSAvatarImageViewInset]];
    
    //Bottom Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:-LSAvatarImageViewInset]];
    
    
    //**********Bubble Image Constraints**********//
    //Width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:0.75
                                                                  constant:0.0]];
    
    //Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:0.8
                                                                  constant:LSAvatarImageViewInset]];
    
    //Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:10]];
    
    //Bottom Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:-LSAvatarImageViewInset]];
}

- (void)updateWithPresenter:(LSMessageCellPresenter *)presenter
{
    [self.contentView removeConstraints:self.contentView.constraints];

    [self.avatarImageView setImage:[UIImage imageNamed:@"kevin"]];
    
    [self.bubbleView updateViewWithPresenter:presenter];
   
    if ([presenter messageWasSentByAuthenticatedUser]) {
        [self setupSenderCellConstraints];
        if (presenter.shouldShowSenderImage) {
            self.avatarImageView.alpha = 1.0;
            [self.bubbleView displayArrowForSender];
        } else {
            self.avatarImageView.alpha = 0.0;
        }
    } else {
        [self setupRecipientCellConstraints];
        if (presenter.shouldShowSenderImage) {
            self.avatarImageView.alpha = 1.0;
            [self.bubbleView displayArrowForRecipient];
        } else {
            self.avatarImageView.alpha = 0.0;
        }
    }
}


@end
