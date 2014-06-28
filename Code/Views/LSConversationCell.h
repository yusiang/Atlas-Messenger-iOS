//
//  LSConversationViewCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LSUser.h"

@interface LSConversationCell : UICollectionViewCell

- (void)updateWithConversation:(LYRConversation *)conversation messages:(NSOrderedSet *)messages;

@end
