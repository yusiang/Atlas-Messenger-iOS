//
//  LSLayerController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

@interface LSLayerController : NSObject <LYRClientDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) LYRClient *client;

- (void)initializeLayerClientWithCompletion:(void (^)(NSError *error))completion;

- (void)authenticateLayerClientWithCompletion:(void (^)(NSError * error))completion;

@end
