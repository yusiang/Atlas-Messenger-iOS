//
//  LSContactCellPresenter.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRContactCellPresenter.h"
#import "LSUser.h"

@interface LSContactCellPresenter : NSObject <LYRContactCellPresenter>

///-------------------------------
/// @name Initializing a Presenter
///-------------------------------

+ (instancetype)presenterWithUser:(LSUser *)user;

- (NSString *)nameText;

- (NSString *)subtitleText;

- (UIImage *)avatarImage;

- (UIButton *)selectionIndicator;

@end
