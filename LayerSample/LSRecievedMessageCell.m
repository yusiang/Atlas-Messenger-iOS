//
//  LSRecievedMessageCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSRecievedMessageCell.h"

@implementation LSRecievedMessageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void) setMessageObject:(LYRSampleMessage *)messageObject
{
    [super setMessageObject:messageObject];
    [self configureCell];
}

-(void)configureCell
{
    [super configureCell];
}

- (void) addAvatarImage
{
    [super addAvatarImage];
    [self.avatarImageView setImage:[UIImage imageNamed:@"kevin"]];
    [self.avatarImageView setFrame:CGRectMake(10, self.frame.size.height - 56, 46, 46)];
}

- (void)addBubbleView
{
    [super addBubbleView];
    [self.bubbleView setFrame:CGRectMake(66, 10, 220, self.frame.size.height - 20)];
    self.bubbleView.backgroundColor = [UIColor lightGrayColor];
}

- (void)addMessageText
{
    [super addMessageText];
}

- (void)addSenderLabel
{
    [super addSenderLabel];
}

@end
