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

@protocol LYRContactCellPresenter <NSObject>

/**
 *  The name of the currently displayed contact. This string will be truncated if it is longer than X characters
 *
 *  @return string object representing the name of the contact.
 */
- (NSString *)nameText;

/**
 *  Optional subtitle text for the currently displayed contact. Potential use cases for this are email address or phone number
 *
 *  @return string object representing the subtitle text
 */

- (NSString *)subtitleText;

/**
 *  Optional image representing the currently displayed contact. Image size is 40px x 40px
 *
 *  @return image object representing the contact
 */
- (UIImage *)avatarImage;

@end
