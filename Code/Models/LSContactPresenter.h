//
//  LSContactPresenter.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRContactPresenter.h"
#import "LSUser.h"

@interface LSContactPresenter : NSObject <LYRContactPresenter>

///-------------------------------
/// @name Initializing a Presenter
///-------------------------------

+ (instancetype)presenterWithContact:(LSUser *)contact;

- (NSString *)primaryContactText;

- (NSString *)secondaryContactText;

- (NSSet *)contactPhoneNumbers;

- (NSSet *)contactEmailAddresses;

- (UIImage *)contactImage;

- (NSSet *)contactActionItems;

@end
