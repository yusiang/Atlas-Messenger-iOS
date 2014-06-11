//
//  LSSentMessageCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSSentMessageCell.h"

@implementation LSSentMessageCell

#define kLayerColor     [UIColor colorWithRed:36.0f/255.0f green:166.0f/255.0f blue:225.0f/255.0f alpha:1.0]

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
    [self.avatarImageView setFrame:CGRectMake(self.frame.size.width - 56, self.frame.size.height - 56, 46, 46)];
}

- (void)addBubbleView
{
    [super addBubbleView];
    [self.bubbleView setFrame:CGRectMake(self.frame.size.width - 66 - 220, 10, 220, self.frame.size.height - 20)];
    self.bubbleView.backgroundColor = kLayerColor;
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
