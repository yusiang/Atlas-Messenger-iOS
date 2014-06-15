//
//  LSMessageCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSMessageCell.h"

@interface LSMessageCell ()

@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UITextView *messageText;
@property (nonatomic, strong) UILabel *senderLabel;
@property (nonatomic, strong) LSAvatarImageView *avatarImageView;

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

- (void)updateCellWithMessage:(LYRMessage *)message andLayerController:(LSLayerController *)controller
{
    LYRMessagePart *part = [message.parts firstObject];
    [self addAvatarImage];
    [self addBubbleView];
    [self addMessageText:[NSString stringWithUTF8String:[part.data bytes]]];
    [self addSenderLabelForID:message.sentByUserID];
}

- (void)addAvatarImage
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

- (void)addMessageText:(NSString *)text
{
    if (!self.messageText) {
        self.messageText = [[UITextView alloc] init];
    }
    [self addSubview:self.messageText];
}

- (void)addSenderLabelForID:(NSString *)senderID
{
    if (!self.senderLabel) {
        self.senderLabel = [[UILabel alloc] init];
    }
    [self addSubview:self.senderLabel];
}

@end
