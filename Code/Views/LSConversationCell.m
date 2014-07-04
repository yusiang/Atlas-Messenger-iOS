//
//  LSConversationViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationCell.h"
#import "LSAvatarImageView.h"
#import "LSUIConstants.h"
#import "LSUser.h"

@interface LSConversationCell ()

@property (nonatomic) LSAvatarImageView *avatarImageView;
@property (nonatomic) UILabel *senderName;
@property (nonatomic) UITextView *lastMessageText;
@property (nonatomic) UILabel *date;
@property (nonatomic) UIView *seperatorLine;
@property (nonatomic) LSConversationCellPresenter *presenter;

@end

@implementation LSConversationCell

@synthesize avatarImageView = _avatarImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)updateWithPresenter:(LSConversationCellPresenter *)presenter
{
    self.presenter = presenter;
    [self addAvatarImage];
    [self addLastMessageText];
    [self addConversationLabel];
    [self addDateLabel];
}

- (void)addAvatarImage
{
    if (!self.avatarImageView) {
        self.avatarImageView = [[LSAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
    }
    self.avatarImageView.center = CGPointMake(36, 30);
    [self.avatarImageView setImage:[UIImage imageNamed:@"kevin"]];
    [self addSubview:self.avatarImageView];
}

- (void)addConversationLabel
{
    if(!self.senderName) {
        self.senderName = [[UILabel alloc] initWithFrame:CGRectMake(70, 8, 200, 24)];
        [self addSubview:self.senderName];
    }
    [self.senderName setFont:LSBoldFont(16)];
    [self.senderName setTextColor:[UIColor darkGrayColor]];
    self.senderName.text = [self.presenter conversationLabel];
    self.accessibilityLabel = self.senderName.text;
    self.senderName.userInteractionEnabled = FALSE;
}

- (void)addLastMessageText
{
    LYRMessage *message = self.presenter.message;
    LYRMessagePart *part = [message.parts firstObject];
    
    if (!self.lastMessageText) {
        self.lastMessageText = [[UITextView alloc] initWithFrame:CGRectMake(70, 26, 240, 50)];
        [self addSubview:self.lastMessageText];
    }
    
    if(part)  {
        self.lastMessageText.text = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
        [self.lastMessageText setFont:LSMediumFont(12)];
        [self.lastMessageText setTextColor:[UIColor grayColor]];
    }
    self.lastMessageText.editable = FALSE;
    self.lastMessageText.scrollEnabled = FALSE;
    self.lastMessageText.userInteractionEnabled = FALSE;
}

- (void)addDateLabel
{
    LYRMessage *message = self.presenter.message;
    NSDate *date = [message sentAt];
    
    if(!self.date) {
        self.date = [[UILabel alloc] initWithFrame:CGRectMake(270, 8, 40, 20)];
        [self addSubview:self.date];
    }
    [self.date setFont:LSMediumFont(12)];
    [self.date setTextColor:[UIColor darkGrayColor]];
   
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"HH:mm"];
    self.date.text = [formatter stringFromDate:date];
}

@end
