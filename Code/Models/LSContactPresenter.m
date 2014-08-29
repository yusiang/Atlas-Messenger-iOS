//
//  LSContactPresenter.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/26/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSContactPresenter.h"

@interface LSContactPresenter ()

@property (nonatomic, strong) LSUser *contact;

@end

@implementation LSContactPresenter

+ (instancetype)presenterWithContact:(LSUser *)contact
{
    return [[self alloc] initWithContact:contact];
}

- (id)initWithContact:(LSUser *)contact
{
    self = [super init];
    if (self) {
        
        _contact = contact;
  
    }
    return self;
}

- (NSString *)primaryContactText
{
    return @"Kevin Coleman";
}

- (NSString *)secondaryContactText
{
    return @"iOS @ Layer";
}

- (NSSet *)contactPhoneNumbers
{
    return [NSSet setWithObject:@"(425)445-6042"];
}

- (NSSet *)contactEmailAddresses
{
    return  [NSSet setWithObject:@"kevin@layer.com"];
}

- (UIImage *)contactImage
{
    return nil;
}

- (NSSet *)contactActionItems
{
    return [NSSet setWithObjects:@"Send Message", @"Delete Contact", nil];
}


@end
