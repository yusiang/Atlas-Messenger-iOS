//
//  LSMessageCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSMessageCell.h"
#import "LSUIConstants.h"

@interface LSMessageCell ()

@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UITextView *messageText;
@property (nonatomic, strong) UILabel *senderLabel;
@property (nonatomic, strong) LSAvatarImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) LSMessageCellPresenter *presenter;

@end

@implementation LSMessageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.autoresizesSubviews = TRUE;
    }
    return self;
}

- (void)updateWithPresenter:(LSMessageCellPresenter *)presenter
{
    self.presenter = presenter;
    [self addBubbleView];
    [self addAvatarImage];
    [self addSenderLabel];
    [self addMessageContent];
    
    if ([presenter messageWasSentByAuthenticatedUser]) {
        [self configureCellForLoggedInUser];
    } else {
        [self configureCellForNonLoggedInUser];
    }
}

- (void)configureCellForLoggedInUser
{
    self.bubbleView.frame = CGRectMake(74, 6, self.frame.size.width - 120, self.frame.size.height - 12);
    self.bubbleView.backgroundColor = LSBlueColor();
    
    self.messageText.frame = CGRectMake(4, 2, self.bubbleView.frame.size.width - 12, self.bubbleView.frame.size.height - 12);
    
    self.imageView.frame = CGRectMake(2, 2, self.bubbleView.frame.size.width - 4, self.bubbleView.frame.size.height - 4);
    
    self.avatarImageView.frame = CGRectMake(self.frame.size.width - 38, self.frame.size.height -42, 32, 32);
}

- (void)configureCellForNonLoggedInUser
{
    self.bubbleView.frame = CGRectMake(42, 6, self.frame.size.width - 120, self.frame.size.height - 12);
    self.bubbleView.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
    
    self.messageText.frame = CGRectMake(4, 2, self.bubbleView.frame.size.width - 12, self.bubbleView.frame.size.height - 12);
    
    self.imageView.frame =  CGRectMake(2, 2, self.bubbleView.frame.size.width - 4, self.bubbleView.frame.size.height - 4);
    
    self.avatarImageView.frame = CGRectMake(6, self.frame.size.height - 42, 32, 32);
}

- (void)addBubbleView
{
    if (!self.bubbleView) {
        self.bubbleView= [[UIView alloc] init];
        self.bubbleView.layer.cornerRadius = 4.0f;
    }
    [self addSubview:self.bubbleView];
}

- (void)addAvatarImage
{
    if (!self.avatarImageView) {
        self.avatarImageView = [[LSAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [self.avatarImageView setImage:[UIImage imageNamed:@"kevin"]];
    }
    [self addSubview:self.avatarImageView];
}

- (void)addSenderLabel
{
    if (!self.senderLabel) {
        self.senderLabel = [[UILabel alloc] init];
    }
    
    [self addSubview:self.senderLabel];
}

- (void) addMessageContent
{
    LYRMessagePart *part = [self.presenter.message.parts objectAtIndex:0];
    if ([part.MIMEType isEqualToString:LYRMIMETypeTextPlain]) {
        [self addTextForMessagePart:part];
    } else if ([part.MIMEType isEqualToString:LYRMIMETypeImagePNG]) {
        [self addPhotoForMessagePart:part];
    }
}

- (void)addTextForMessagePart:(LYRMessagePart *)part
{
    if (self.imageView) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    
    if (!self.messageText) {
        self.messageText = [[UITextView alloc] init];
        self.messageText.textColor = [UIColor whiteColor];
        self.messageText.font = LSMediumFont(14);
        self.messageText.editable = NO;
        self.messageText.userInteractionEnabled = NO;
    }
    NSString *messageText = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
    self.messageText.text = messageText;
    self.messageText.backgroundColor = [UIColor clearColor];
    [self.bubbleView addSubview:self.messageText];

    NSString *label = messageText;
    self.messageText.accessibilityLabel = label;
}

- (void)addPhotoForMessagePart:(LYRMessagePart *)part
{
    if (self.messageText) {
        [self.messageText removeFromSuperview];
        self.messageText = nil;
    }
    
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.layer.cornerRadius = 4;
        [self.bubbleView addSubview:self.imageView];
    }
    
    self.imageView.image = [[UIImage alloc] initWithData:part.data];
    
    NSString *label = [NSString stringWithFormat:@"Photo sent by %@", self.senderLabel.text];
    self.accessibilityLabel = label;
}


@end
