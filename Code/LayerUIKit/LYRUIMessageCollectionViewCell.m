//
//  LYRUIMessageCollectionViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIMessageCollectionViewCell.h"
#import "LYRUIUtilities.h"
#import "LYRUIIncomingMessageCollectionViewCell.h"
#import "LYRUIOutgoingMessageCollectionViewCell.h"

@interface LYRUIMessageCollectionViewCell ()

@property (nonatomic) CGFloat bubbleViewWidth;
@property (nonatomic) CGFloat imageViewDiameter;
@property (nonatomic) NSLayoutConstraint *bubbleViewWidthConstraint;

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
        self.avatarImage.backgroundColor = LSGrayColor();
        self.avatarImage.layer.cornerRadius = 12;
        self.avatarImage.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.avatarImage];
        
        if ([self isKindOfClass:[LYRUIIncomingMessageCollectionViewCell class]]) {
            self.imageViewDiameter = 24;
        } else {
            self.imageViewDiameter = 0;
        }
    }
    return self;
}

- (void)presentMessage:(LYRMessagePart *)messagePart fromParticipant:(id<LYRUIParticipant>)participant
{
    if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeTextPlain]) {
    
        NSString *text = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
        [self.bubbleView updateWithText:text];
        self.accessibilityLabel = [NSString stringWithFormat:@"Message: %@", text];
    
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG] || [messagePart.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG]) {
        
        UIImage *image = [UIImage imageWithData:messagePart.data];
        [self.bubbleView updateWithImage:image];
        self.accessibilityLabel = [NSString stringWithFormat:@"Message: Photo"];
    
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeLocation]) {
        //
    }
}

- (void)updateBubbleViewWidth:(CGFloat)width
{
    if ([[self.contentView constraints] containsObject:self.bubbleViewWidthConstraint]) {
        [self.contentView removeConstraint:self.bubbleViewWidthConstraint];
    }
    
    self.bubbleViewWidth = width + 20; //Adding 16px bubble view horizontal padding
    self.bubbleViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:self.bubbleViewWidth];
    [self.contentView addConstraint:self.bubbleViewWidthConstraint];
}

- (void)updateConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImage
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:self.imageViewDiameter]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImage
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:self.imageViewDiameter]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImage
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0]];
    
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
    [self.bubbleView updateBubbleViewWithFont:self.messageTextFont color:self.messageTextColor];
}


@end
