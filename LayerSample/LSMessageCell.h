//
//  LSMessageCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRSampleMessage.h"
#import "LSAvatarImageView.h"

@interface LSMessageCell : UICollectionViewCell

@property (nonatomic, strong) LYRSampleMessage *messageObject;
@property (nonatomic, strong) LSAvatarImageView *avatarImageView;
@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UITextView *messageText;
@property (nonatomic, strong) UILabel *senderLabel;


- (void)configureCell;

- (void) addAvatarImage;

- (void)addBubbleView;

- (void)addMessageText;

- (void)addSenderLabel;


@end
