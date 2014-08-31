//
//  LYRUIConversationCollectionViewFlowLayout.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @discussion Lays out cells with the following rules:
 1. Participant avatar decoration views are draw to the left of incoming message cells.
 2. Header accessory views for the participant name are drawn above each incoming message cell.
 3. A date footer is drawn below each message whose next message occurred >= 15 mins
 */
@interface LYRUIConversationCollectionViewFlowLayout : UICollectionViewFlowLayout

@end
