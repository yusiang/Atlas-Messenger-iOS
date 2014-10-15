//
//  LYRUILayerContentFactory.h
//  LayerSample
//
//  Created by Kevin Coleman on 9/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

extern NSString *const LYRUITestMessageText;

@interface LYRUILayerContentFactory : NSObject

+ (instancetype)layerContentFactoryWithLayerClient:(LYRClient *)layerClient;

- (void)conversationsWithParticipants:(NSSet *)participants number:(NSUInteger)number;

@end
