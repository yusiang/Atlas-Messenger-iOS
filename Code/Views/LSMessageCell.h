//
//  LSMessageCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LSAvatarImageView.h"
#import "LSMessageCellPresenter.h"

@class LSMessageCell;

@protocol LSMessageCellDelegate <NSObject>

- (void)messageCell:(LSMessageCell *)cell deleteMessage:(LYRMessage *)message;

@end

@interface LSMessageCell : UICollectionViewCell 

@property (nonatomic, weak) id<LSMessageCellDelegate>delegate;

- (void)updateWithPresenter:(LSMessageCellPresenter *)presenter;

@end
