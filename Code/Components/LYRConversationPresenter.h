//
//  LYRConversationPresenter.h
//  LayerSample
//
//  Created by Zac White on 8/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LYRConversationCellPresenter <NSObject>

- (NSString *)titleText;
- (NSString *)dateText;
- (NSString *)lastMessageText;
- (UIImage *)avatarImage;

@end