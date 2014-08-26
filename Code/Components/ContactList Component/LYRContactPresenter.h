//
//  LYRContactPresenter.h
//  LayerSample
//
//  Created by Zac White on 8/21/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LYRContactAccessoryType) {
    LYRContactAccessoryTypeNone,
    LYRContactAccessoryTypeCheckbox,
    LYRContactAccessoryTypeChevron
};

@protocol LYRContactPresenter <NSObject>

- (NSString *)nameText;
- (NSString *)subtitleText;
- (UIImage *)avatarImage;

- (LYRContactAccessoryType)accessoryType;

@end
