//
//  LSLocalNotificationUtilities.h
//  LayerSample
//
//  Created by Kevin Coleman on 10/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

@interface LSLocalNotificationUtilities : NSObject

+ (instancetype)initWithLayerClient:(LYRClient *)layerClient;

@property (nonatomic) BOOL shouldListenForChanges;

@end
