//
//  LSContactCellPresenter.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSContactCellPresenter.h"

@interface LSContactCellPresenter ()

@property (nonatomic, strong) LSUser *user;

@end

@implementation LSContactCellPresenter

+ (instancetype) presenterWithUser:(LSUser *)user
{
    return [[self alloc] initWithUserObject:user];
}

- (id)initWithUserObject:(LSUser *)user
{
    self = [super init];
    if (self) {
        _user = user;
    }
    return self;
}

- (NSString *)nameText
{
    return self.user.fullName;
}

- (NSString *)subtitleText
{
    return @"(425) 445-6042";
}

- (UIImage *)avatarImage
{
    return nil; //[UIImage imageNamed:@"kevin"];
}

- (LYRContactAccessoryType)accessoryType
{
    return LYRContactAccessoryTypeCheckbox;
}

@end
