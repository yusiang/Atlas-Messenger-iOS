//
//  LSAvatarImageView.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSAvatarImageView.h"

@implementation LSAvatarImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = frame.size.width / 2;
        self.clipsToBounds = TRUE;
    }
    return self;
}

- (void)setSenderName:(NSString *)senderName
{
    if (_senderName != senderName) {
        _senderName = senderName;
    }
}

@end
