//
//  LSMessageCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRSampleMessage.h"
#import "LSAvatarImageView.h"
#import "LYRMessage.h"
#import "LSLayerController.h"

@interface LSMessageCell : UICollectionViewCell

// SBW: This should not know about the layer controller...
- (void)updateCellWithMessage:(LYRMessage *)message andLayerController:(LSLayerController *)controller;

@end
