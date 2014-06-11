//
//  LSMessageCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSMessageCell.h"

@interface LSMessageCell ()

@end

@implementation LSMessageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void) setMessageObject:(LYRSampleMessage *)messageObject
{
    if(_messageObject != messageObject) {
        _messageObject = messageObject;
    }
}

- (void)configureCell
{
    [self addAvatarImage];
    [self addBubbleView];
    [self addMessageText];
    [self addSenderLabel];
}

- (void) addAvatarImage
{
    if (!self.avatarImageView) {
        self.avatarImageView = [[LSAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
    }
    [self addSubview:self.avatarImageView];
}

- (void)addBubbleView
{
    if (!self.bubbleView) {
        self.bubbleView= [[UIView alloc] init];
    }
    self.bubbleView.layer.cornerRadius = 4.0f;
    [self addSubview:self.bubbleView];
}

- (void)addMessageText
{
    if (!self.messageText) {
        self.messageText = [[UITextView alloc] init];
    }
    [self addSubview:self.messageText];
}

- (void)addSenderLabel
{
    if (!self.senderLabel) {
        self.senderLabel = [[UILabel alloc] init];
    }
    [self addSubview:self.senderLabel];
}

@end
