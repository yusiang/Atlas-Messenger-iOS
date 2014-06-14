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

-(void) updateCellWithConversation:(LYRConversation *)conversation andLayerController:(LSLayerController *)controller;

@end
