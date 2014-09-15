//
//  LYRUIParticipantPresenting.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRUIParticipant.h"

/**
 @abstract The `LYRUIParticipantPresenting` protocol must be adopted by objects that wish to present Layer
 participants in the user interface.
 */
@protocol LYRUIParticipantPresenting <NSObject>

/**
 @abstract Tells the receiver to present an interface for the given participant.
 @param participant The participant to present.
 */
- (void)presentParticipant:(id<LYRUIParticipant>)participant;

/**
 @abstract Tells the receiver to present a selection indicator
 @param selection indicator to present. 
 @discussion should have display a different interface for both `Highlighted` and `Normal` states
 */
- (void)updateWithSelectionIndicator:(UIControl *)selectionIndicator;

@end
