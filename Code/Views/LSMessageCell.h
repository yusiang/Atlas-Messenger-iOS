//
//  LSMessageCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LSAvatarImageView.h"

@interface LSMessageCell : UICollectionViewCell

- (void)updateWithMessage:(LYRMessage *)message;

@end
