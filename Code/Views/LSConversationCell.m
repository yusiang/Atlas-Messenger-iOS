//
//  LSConversationViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConversationCell.h"
#import "LSAvatarImageView.h"
#import "LSUser.h"

@interface LSConversationCell ()

@property (nonatomic) LSAvatarImageView *avatarImageView;
@property (nonatomic) UILabel *senderName;
@property (nonatomic) UITextView *lastMessageText;
@property (nonatomic) UILabel *date;
@property (nonatomic) UIView *seperatorLine;

@end

@implementation LSConversationCell

@synthesize avatarImageView = _avatarImageView;

// SBW: Eliminate these
#define kLayerColor     [UIColor colorWithRed:36.0f/255.0f green:166.0f/255.0f blue:225.0f/255.0f alpha:1.0]
#define kLayerFont      @"Avenir-Medium"
#define kLayerFontHeavy @"Avenir-Heavy"

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)updateWithConversation:(LYRConversation *)conversation messages:(NSOrderedSet *)messages
{
    LYRMessage *message = [messages lastObject];
    LYRMessagePart *part = [message.parts firstObject];
    [self addAvatarImage];
    [self addSenderLabelWithParticipants:[conversation.participants allObjects]];
    [self addLastMessageTextWithPart:part];
    [self addDateLabel:message.sentAt];
    [self addSeperatorLine];
}

- (void)addAvatarImage
{
    if (!self.avatarImageView) {
        self.avatarImageView = [[LSAvatarImageView alloc] initWithFrame:CGRectMake(10, 10, 46, 46)];
    }
    [self.avatarImageView setImage:[UIImage imageNamed:@"kevin"]];
    [self addSubview:self.avatarImageView];
}

- (void)addSenderLabelWithParticipants:(NSArray *)participants
{
    if(!self.senderName) {
        self.senderName = [[UILabel alloc] initWithFrame:CGRectMake(70, 8, 240, 20)];
        [self addSubview:self.senderName];
    }
    [self.senderName setFont:[UIFont fontWithName:kLayerFontHeavy size:16]];
    [self.senderName setTextColor:[UIColor darkGrayColor]];
    
    // SBW: The view should not be querying the model directly.
//    NSMutableArray *fullNames = [[NSMutableArray alloc] init];
//    LSUserManager *manager = [[LSUserManager alloc] init];
//    for (NSString *userID in participants) {
//        if (![userID isEqualToString:[manager loggedInUser].identifier]) {
//            NSString *participantName = [manager userWithIdentifier:userID].fullName ?: @"Unknown User";
//            [fullNames addObject:participantName];
//        }
//    }
//    
//    NSArray *sortedFullNames = [fullNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//    NSString *senderLabel = @"";
//    
//    for (NSString *fullName in sortedFullNames) {
//        senderLabel = [senderLabel stringByAppendingString:[NSString stringWithFormat:@"%@, ", fullName]];
//    }
//    self.senderName.text = senderLabel;
//    self.senderName.userInteractionEnabled = FALSE;
//    self.accessibilityLabel = senderLabel;
}

- (void)addLastMessageTextWithPart:(LYRMessagePart *)part
{
    if (!self.lastMessageText) {
        self.lastMessageText = [[UITextView alloc] initWithFrame:CGRectMake(70, 26, 240, 50)];
        [self addSubview:self.lastMessageText];
    }
    
    if(part)  {
        self.lastMessageText.text = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
        [self.lastMessageText setFont:[UIFont fontWithName:kLayerFont size:12]];
        [self.lastMessageText setTextColor:[UIColor grayColor]];
    }
    self.lastMessageText.editable = FALSE;
    self.lastMessageText.scrollEnabled = FALSE;
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
