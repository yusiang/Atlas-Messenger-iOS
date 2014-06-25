//
//  LSMessageCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSMessageCell.h"
#import "LSUserManager.h"

@interface LSMessageCell ()

@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UITextView *messageText;
@property (nonatomic, strong) UILabel *senderLabel;
@property (nonatomic, strong) LSAvatarImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic) BOOL wasSentByLoggedInUser;

@end

@implementation LSMessageCell

// SBW: Be gone, #define's!
#define kLayerColor     [UIColor colorWithRed:36.0f/255.0f green:166.0f/255.0f blue:225.0f/255.0f alpha:1.0]
#define kLayerFont      @"Avenir-Medium"

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
    [self addBubbleViewForMessage:message];
    [self addAvatarImageForMessage:message];
    [self addSenderLabelForIDForMessage:message];
    
    [self addMessageContentForMessagePart:[message.parts firstObject]];
    
    // TODO: The controller should be telling the cell what to do here... it shouldn't know about the auth model
    LSUserManager *manager = [LSUserManager new];
    if ([message.sentByUserID isEqualToString:[manager loggedInUser].identifier]) {
        [self configureCellForLoggedInUser];
    }else {
        [self configureCellForNonLoggedInUser];
    }
}

- (void)configureCellForLoggedInUser
{
    self.bubbleView.frame = CGRectMake(58, 6, self.frame.size.width - 116, self.frame.size.height - 12);
    self.bubbleView.backgroundColor = kLayerColor;
    
    self.messageText.frame = CGRectMake(4, 2, self.bubbleView.frame.size.width - 12, self.bubbleView.frame.size.height - 12);
    
    self.imageView.frame = CGRectMake(2, 2, self.bubbleView.frame.size.width - 4, self.bubbleView.frame.size.height - 4);
    
    self.avatarImageView.frame = CGRectMake(self.frame.size.width - 52, self.frame.size.height - 52, 46, 46);
}

- (void)configureCellForNonLoggedInUser
{
    self.bubbleView.frame = CGRectMake(42, 6, self.frame.size.width - 116, self.frame.size.height - 12);
    self.bubbleView.backgroundColor = [UIColor blueColor];
    
    self.messageText.frame = CGRectMake(4, 2, self.bubbleView.frame.size.width - 12, self.bubbleView.frame.size.height - 12);
    
    self.imageView.frame =  CGRectMake(2, 2, self.bubbleView.frame.size.width - 4, self.bubbleView.frame.size.height - 4);
    
    self.avatarImageView.frame = CGRectMake(6, self.frame.size.height - 52, 46, 46);
}


- (void)addBubbleViewForMessage:(LYRMessage *)message
{
    if (!self.bubbleView) {
        self.bubbleView= [[UIView alloc] init];
        self.bubbleView.layer.cornerRadius = 4.0f;
    }
    [self addSubview:self.bubbleView];
}

- (void)addAvatarImageForMessage:(LYRMessage *)message
{
    if (!self.avatarImageView) {
        self.avatarImageView = [[LSAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
        [self.avatarImageView setImage:[UIImage imageNamed:@"kevin"]];
    }
    [self addSubview:self.avatarImageView];
}

- (void)addSenderLabelForIDForMessage:(LYRMessage *)message
{
    if (!self.senderLabel) {
        self.senderLabel = [[UILabel alloc] init];
    }
    LSUserManager *manager = [LSUserManager new];
    NSString *senderName = [manager userWithIdentifier:[message sentByUserID]].identifier;
    self.senderLabel.text = senderName;
    [self addSubview:self.senderLabel];
}

- (void) addMessageContentForMessagePart:(LYRMessagePart *)part
{
    if ([part.MIMEType isEqualToString:LYRMIMETypeTextPlain]) {
        [self addTextForMessagePart:part];
    } else if ([part.MIMEType isEqualToString:LYRMIMETypeImagePNG]) {
        [self addPhotoForMessagePart:part];
    }
}

- (void)addTextForMessagePart:(LYRMessagePart *)part
{
    if (!self.messageText) {
        self.messageText = [[UITextView alloc] init];
        self.messageText.textColor = [UIColor whiteColor];
        self.messageText.font = [UIFont fontWithName:kLayerFont size:16];
        self.messageText.editable = FALSE;
    }
    NSString *messageText = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
    self.messageText.text = messageText;
    self.messageText.backgroundColor = [UIColor clearColor];
    [self.bubbleView addSubview:self.messageText];

    NSString *label = [NSString stringWithFormat:@"%@ sent by %@", messageText, self.senderLabel.text];
    self.accessibilityLabel = label;
}

- (void)addPhotoForMessagePart:(LYRMessagePart *)part
{
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
