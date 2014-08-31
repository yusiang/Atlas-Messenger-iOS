//
//  LYRUIConversationTableViewCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRUIConversationPresenting.h"

/**
 @abstract The `LYRUIConversationTableViewCell` class provides a lightweight, customizable table
 view cell for presenting Layer conversation objects.
 */
@interface LYRUIConversationTableViewCell : UITableViewCell <LYRUIConversationPresenting>

@property (nonatomic) UIFont *titleFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *titleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIFont *subtitleFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *subtitleColor UI_APPEARANCE_SELECTOR;

@end
