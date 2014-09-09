//
//  LYRUIMessageCollectionViewCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRUIMessagePresenting.h"
#import "LYRUIMessageBubbleView.h"
#import "LYRUIConstants.h"

@interface LYRUIMessageCollectionViewCell : UICollectionViewCell <LYRUIMessagePresenting>

// TODO: Define the UIAppearance enabled accessors
@property (nonatomic) UIFont *messageTextFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *messageTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *bubbleViewColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) LYRUIMessageBubbleView *bubbleView;

@property (nonatomic, strong) UIImageView *avatarImage;

@end