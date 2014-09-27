//
//  LYRUIConversationCollectionViewFlowLayout.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


/*
 * KFC - This class is not currently in use. It's performance is garbage and needs to be update. 
 */

/// The default resistance factor that determines the bounce of the collection. Default is 900.0f.
#define kScrollResistanceFactorDefault 900.0f;

/**
 @discussion Lays out cells with the following rules:
 1. Participant avatar decoration views are draw to the left of incoming message cells.
 2. Header accessory views for the participant name are drawn above each incoming message cell.
 3. A date footer is drawn below each message whose next message occurred >= 15 mins
 */
@interface LYRUIConversationCollectionViewFlowLayout : UICollectionViewFlowLayout <UICollectionViewDelegateFlowLayout>

/// The scrolling resistance factor determines how much bounce / resistance the collection has. A higher number is less bouncy, a lower number is more bouncy. The default is 900.0f.
@property (nonatomic, assign) CGFloat scrollResistanceFactor;

/// The dynamic animator used to animate the collection's bounce
@property (nonatomic, readonly) UIDynamicAnimator *dynamicAnimator;

@property (nonatomic) NSOrderedSet *messages;

@end
