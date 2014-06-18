//
//  LSAvatarImageView.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// SBW: Why do you need a string on an image view?
@interface LSAvatarImageView : UIImageView

@property (nonatomic, strong) NSString *senderName;

@end
