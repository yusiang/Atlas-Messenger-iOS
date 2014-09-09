//
//  LYRUIMessagePresenting.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRUIParticipant.h"
#import <LayerKit/LayerKit.h>

@protocol LYRUIMessagePresenting <NSObject>

- (void)presentMessage:(LYRMessagePart *)message fromParticipant:(id<LYRUIParticipant>)participant;

@end