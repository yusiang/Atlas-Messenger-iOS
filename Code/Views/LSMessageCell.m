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
#import "LSUtilities.h"

@interface LSMessageCell ()

@property (nonatomic, strong) LSBubbleView *bubbleView;
@property (nonatomic, strong) UILabel *senderLabel;
@property (nonatomic, strong) LYRUIAvatarImageView *avatarImageView;
@property (nonatomic, strong) UIView *arrow;

@end

@implementation LSMessageCell

static CGFloat const LSAvatarImageViewSize = 30.0f;
static CGFloat const LSAvatarImageViewInset = 6.0f;
static CGFloat const LSAvatarImageViewBottomMargin = -2.0f;

static CGFloat const LSBubbleViewWidthMultiplier = 0.75f;
static CGFloat const LSBubbleViewVerticalMargin = 10.0f;

static CGFloat const LSArrowSize = 16.0f;


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
        
        //Initialize the sender Avatar Image View
        self.avatarImageView = [[LYRUIAvatarImageView alloc] init];
        self.avatarImageView.layer.cornerRadius = (LSAvatarImageViewSize / 2);
        self.avatarImageView.clipsToBounds = YES;
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.avatarImageView];
        
        //Initialize the bubble view
        self.arrow = [[UIView alloc] init];
        self.arrow.layer.cornerRadius = 2;
        self.arrow.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.arrow];
        
    }
    return self;
}

- (void)updateWithPresenter:(LSMessageCellPresenter *)presenter
{
    [self.contentView removeConstraints:self.contentView.constraints];
    self.arrow.layer.mask = nil;
    
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
        self.arrow.alpha = 1.0;
    } else {
        self.avatarImageView.alpha = 0.0;
        self.arrow.alpha = 0.0;
    }
}

- (void)updateCellForRecipientWithPresenter:(LSMessageCellPresenter *)presenter
{
    [self setupRecipientCellConstraintsWithPresenter:presenter];
    if (presenter.shouldShowSenderImage) {
        self.avatarImageView.alpha = 1.0;
        self.arrow.alpha = 1.0;
    } else {
        self.avatarImageView.alpha = 0.0;
        self.arrow.alpha = 0.0;
    }
}

- (void)setupSenderCellConstraintsWithPresenter:(LSMessageCellPresenter *)presenter
{
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
    
    //**********Sender Arrow Constraints**********//
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.arrow
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:-LSArrowSize / 2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.arrow
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.arrow
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSArrowSize]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.arrow
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSArrowSize]];

    
    self.arrow.backgroundColor = LSBlueColor();
    [self cutArrowForSenderCell];
}

- (void)setupRecipientCellConstraintsWithPresenter:(LSMessageCellPresenter *)presenter
{
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
    
    //**********Sender Arrow Constraints**********//
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.arrow
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:LSArrowSize / 2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.arrow
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.arrow
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSArrowSize]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.arrow
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSArrowSize]];
    self.arrow.backgroundColor = LSGrayColor();
    [self cutArrowForRecipientCell];
    
}

- (void)cutArrowForSenderCell
{
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:(CGPoint){16, 8}];
    [path addLineToPoint:(CGPoint){8, 2}];
    [path addLineToPoint:(CGPoint){8, 14}];
    //
    CAShapeLayer *mask = [CAShapeLayer new];
    mask.frame = self.arrow.bounds;
    mask.path = path.CGPath;
    self.arrow.layer.mask = mask;
}

- (void)cutArrowForRecipientCell
{
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:(CGPoint){0, 8}];
    [path addLineToPoint:(CGPoint){8, 2}];
    [path addLineToPoint:(CGPoint){8, 14}];
    //
    CAShapeLayer *mask = [CAShapeLayer new];
    mask.frame = self.arrow.bounds;
    mask.path = path.CGPath;
    self.arrow.layer.mask = mask;
}

- (CGFloat)bubbleWidthForMessagePart:(LYRMessagePart *)messagePart
{
    if ([messagePart.MIMEType isEqualToString:MIMETypeTextPlain()]) {
        NSString *string = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
        NSDictionary *attributes = @{NSFontAttributeName :LSMediumFont(14)};
        CGSize stringSize = [string sizeWithAttributes:attributes];
        CGFloat width = stringSize.width + 20;
        if (self.contentView.frame.size.width * LSBubbleViewWidthMultiplier > width) {
           return width;
        }
    }
    
    if ([messagePart.MIMEType isEqualToString:MIMETypeImagePNG()] || [messagePart.MIMEType isEqualToString:MIMETypeImageJPEG()]) {
        UIImage *image = [UIImage imageWithData:messagePart.data];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
        if (imageView.frame.size.height > imageView.frame.size.width) {
            CGFloat ratio = 300 / imageView.frame.size.height;
            return imageView.frame.size.width * ratio;
        } else {
            return self.contentView.frame.size.width * LSBubbleViewWidthMultiplier;
        }
    }
    return self.contentView.frame.size.width * LSBubbleViewWidthMultiplier;
}

@end
