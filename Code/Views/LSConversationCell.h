//
//  LSConversationViewCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRConversation.h"
#import "LSLayerController.h"
#import "LYRMessage.h"

@interface LSConversationCell : UICollectionViewCell

// SBW: There should not be any reason for a cell to know about the layer controller...
- (void) updateCellWithConversation:(LYRConversation *)conversation andLayerController:(LSLayerController *)controller;

@end
