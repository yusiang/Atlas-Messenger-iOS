//
//  LSConversationViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationCell.h"
#import "LSAvatarImageView.h"
#import "LYRSampleMessage.h"
#import "LYRSampleParticipant.h"
#import "LYRSampleMessagePart.h"

@interface LSConversationCell ()

@property (nonatomic, strong) LSAvatarImageView *avatarImageView;
@property (nonatomic, strong) UILabel *senderName;
@property (nonatomic, strong) UITextView *lastMessageText;
@property (nonatomic, strong) UILabel *date;
@property (nonatomic, strong) UIView *seperatorLine;

@end

@implementation LSConversationCell

@synthesize avatarImageView = _avatarImageView;

#define kLayerColor     [UIColor colorWithRed:36.0f/255.0f green:166.0f/255.0f blue:225.0f/255.0f alpha:1.0]
#define kLayerFont      @"Avenir-Medium"

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        self.accessibilityLabel = @"conversationCell";
    }
    return self;
}

- (void)updateCellWithConversation:(LYRConversation *)conversation andLayerController:(LSLayerController *)controller
{
    LYRMessage *message = [[controller.client messagesForConversation:conversation] firstObject];
    LYRMessagePart *part = [message.parts firstObject];
    [self addAvatarImage];
    [self addSenderNameWithID:message.sentByUserID];
    [self addLastMessageText:[NSString stringWithUTF8String:[part.data bytes]]];
    [self addDateLabel:message.sentAt];
    [self addSeperatorLine];
}

//NSLayoutConstraint
- (void)addAvatarImage
{
    if (!self.avatarImageView) {
        self.avatarImageView = [[LSAvatarImageView alloc] initWithFrame:CGRectMake(10, 10, 46, 46)];
    }
    [self.avatarImageView setImage:[UIImage imageNamed:@"kevin"]];
    [self addSubview:self.avatarImageView];
}

- (void)addSenderNameWithID:(NSString *)userID
{
    if(!self.senderName) {
        self.senderName = [[UILabel alloc] initWithFrame:CGRectMake(70, 8, 240, 20)];
        [self addSubview:self.senderName];
    }
    [self.senderName setFont:[UIFont fontWithName:kLayerFont size:14]];
    [self.senderName setTextColor:[UIColor darkGrayColor]];
#warning ADD Name Here for Userr
    self.senderName.text = @"Kevin Coleman";
    self.senderName.userInteractionEnabled = FALSE;
    self.senderName.accessibilityLabel = @"Sender Label";
    
}

- (void)addLastMessageText:(NSString *)text
{
    if (!self.lastMessageText) {
        self.lastMessageText = [[UITextView alloc] initWithFrame:CGRectMake(70, 26, 240, 50)];
        [self addSubview:self.lastMessageText];
    }
    [self.lastMessageText setFont:[UIFont fontWithName:kLayerFont size:12]];
    [self.lastMessageText setTextColor:[UIColor grayColor]];
    self.lastMessageText.editable = FALSE;
    self.lastMessageText.scrollEnabled = FALSE;
    self.lastMessageText.text = text;
    self.lastMessageText.userInteractionEnabled = FALSE;
}

- (void)addDateLabel:(NSDate *)date
{
    if(!self.date) {
        self.date = [[UILabel alloc] initWithFrame:CGRectMake(270, 8, 40, 20)];
        [self addSubview:self.date];
    }
    [self.date setFont:[UIFont fontWithName:kLayerFont size:12]];
    [self.date setTextColor:[UIColor darkGrayColor]];
   
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"HH:mm"];
    self.date.text = [formatter stringFromDate:date];
}

- (void)addSeperatorLine
{
    if(!self.seperatorLine){
        self.seperatorLine = [[UIView alloc] initWithFrame:CGRectMake(70, self.frame.size.height - 1, self.frame.size.width - 70, 1)];
        [self addSubview:self.seperatorLine];
    }
    self.seperatorLine.backgroundColor = [UIColor lightGrayColor];
}
@end

