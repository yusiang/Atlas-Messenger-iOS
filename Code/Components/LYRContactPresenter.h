//
//  LYRContactPresenter.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LYRContactPresenter <NSObject>

- (NSString *)primaryContactText;

- (NSString *)secondaryContactText;

- (NSSet *)contactPhoneNumbers;

- (NSSet *)contactEmailAddresses;

- (UIImage *)contactImage;

- (NSSet *)contactActionItems;

@end
