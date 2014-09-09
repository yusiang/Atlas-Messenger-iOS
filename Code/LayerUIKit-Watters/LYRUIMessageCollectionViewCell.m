//
//  LYRUIMessageCollectionViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIMessageCollectionViewCell.h"
#import "LYRUIUtilities.h"

@interface LYRUIMessageCollectionViewCell ()

@property (nonatomic) CGFloat LYRUIBubbleViewWidth;

@end

@implementation LYRUIMessageCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.bubbleView = [[LYRUIMessageBubbleView alloc] init];
        self.bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.bubbleView];
        
        self.avatarImage = [[UIImageView alloc] init];
        self.avatarImage.backgroundColor = [UIColor redColor];
        self.avatarImage.layer.cornerRadius = 12;
        self.avatarImage.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.avatarImage];
        
    }
    return self;
}

- (void)presentMessage:(LYRMessagePart *)messagePart fromParticipant:(id<LYRUIParticipant>)participant
{
    if ([messagePart.MIMEType isEqualToString:LYRMIMETypeTextPlain]) {
        NSString *text = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
        [self.bubbleView updateWithText:text];
        self.LYRUIBubbleViewWidth = LYRUITextPlainSize(text, LSMediumFont(12)).width + 28;
    } else if ([messagePart.MIMEType isEqualToString:LYRMIMETypeImageJPEG] || [messagePart.MIMEType isEqualToString:LYRMIMETypeImagePNG]) {
        UIImage *image = [UIImage imageWithData:messagePart.data];
        [self.bubbleView updateWithImage:image];
        self.LYRUIBubbleViewWidth = LYRUIImageSize(image, self.frame).width;
    } else if ([messagePart.MIMEType isEqualToString:LYRMIMETypeLocation]) {
        //
    }
}

- (void)updateConstraints
{
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImage
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:24]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImage
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:24]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImage
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:self.LYRUIBubbleViewWidth]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bubbleView.bubbleContentView.textColor = self.messageTextColor;
    self.bubbleView.bubbleContentView.font = self.messageTextFont;
}

@end
