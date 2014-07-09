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
static CGFloat const LSAvatarImageViewBottomMargin = -2.0f;

static CGFloat const LSBubbleViewWidthMultiplier = 0.75f;
static CGFloat const LSBubbleViewVerticalMargin = 10.0f;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
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

- (void)updateWithPresenter:(LSMessageCellPresenter *)presenter
{
    [self.contentView removeConstraints:self.contentView.constraints];
    [self.avatarImageView setImage:[UIImage imageNamed:@"kevin"]];
    [self.bubbleView updateViewWithPresenter:presenter];
    
    if ([presenter messageWasSentByAuthenticatedUser]) {
        [self updateCellForSenderWithPresenter:presenter];
    } else {
        [self updateCellForRecipientWithPresenter:presenter];
    }
}

- (void)updateCellForSenderWithPresenter:(LSMessageCellPresenter *)presenter
{
    [self setupSenderCellConstraintsWithPresenter:presenter];
    if (presenter.shouldShowSenderImage) {
        self.avatarImageView.alpha = 1.0;
        [self.bubbleView displayArrowForSender];
    } else {
        self.avatarImageView.alpha = 0.0;
    }
}

- (void)updateCellForRecipientWithPresenter:(LSMessageCellPresenter *)presenter
{
    [self setupRecipientCellConstraintsWithPresenter:presenter];
    if (presenter.shouldShowSenderImage) {
        self.avatarImageView.alpha = 1.0;
        [self.bubbleView displayArrowForRecipient];
    } else {
        self.avatarImageView.alpha = 0.0;
    }
}

- (void)setupSenderCellConstraintsWithPresenter:(LSMessageCellPresenter *)presenter
{
    //Place Holder
    [self.avatarImageView setImage:[UIImage imageNamed:@"kevin"]];
    
    //**********Avatar Image Constraints**********//
    // Width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSAvatarImageViewSize]];
    
    // Height
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSAvatarImageViewSize]];

    // Right Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:-LSAvatarImageViewInset]];
    
    // Bottom Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:LSAvatarImageViewBottomMargin]];
    
    
    //**********Bubble Image Constraints**********//
    LYRMessagePart *messagePart = [presenter.message.parts objectAtIndex:[presenter indexForPart]];
    // Width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:0
                                                                  constant:[self bubbleWidthForMessagePart:messagePart]]];
    
    // Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:0]];

    // Right Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:-LSBubbleViewVerticalMargin]];
    
    // Bottom Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0]];
}

- (void)setupRecipientCellConstraintsWithPresenter:(LSMessageCellPresenter *)presenter
{
   [self.avatarImageView setImage:[UIImage imageNamed:@"kevin"]];
    
    //**********Avatar Image Constraints**********//
    // Width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSAvatarImageViewSize]];
    
    // Height
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSAvatarImageViewSize]];
    
    // Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:LSAvatarImageViewInset]];
    
    // Bottom Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:LSAvatarImageViewBottomMargin]];
    
    
    //**********Bubble Image Constraints**********//
    LYRMessagePart *messagePart = [presenter.message.parts objectAtIndex:[presenter indexForPart]];
    // Width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:[self bubbleWidthForMessagePart:messagePart]]];
    
    // Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:0.8
                                                                  constant:0]];
    
    // Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:LSBubbleViewVerticalMargin]];
    
    // Bottom Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0]];
}

- (CGFloat)bubbleWidthForMessagePart:(LYRMessagePart *)messagePart
{
    if ([messagePart.MIMEType isEqualToString:LYRMIMETypeTextPlain]) {
        NSString *string = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
        NSDictionary *attributes = @{NSFontAttributeName :LSMediumFont(14)};
        CGSize stringSize = [string sizeWithAttributes:attributes];
        CGFloat width = stringSize.width + 20;
        if (self.contentView.frame.size.width * LSBubbleViewWidthMultiplier > width) {
           return width;
        }
    }
    return self.contentView.frame.size.width * LSBubbleViewWidthMultiplier;
}

@end
