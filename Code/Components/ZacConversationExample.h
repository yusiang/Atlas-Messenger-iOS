//
//  LYRConversationCell.h
//  LayerSample
//
//  Created by Zac White on 8/13/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRConversationPresenter.h"

@interface ZacConversationExample : UITableViewCell

@property (strong, nonatomic) UILabel *senderLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *lastMessageLabel;
@property (strong, nonatomic) UIImageView *avatarImageView;

- (void)updateWithPresenter:(id<LYRConversationCellPresenter>)presenter;

@end
