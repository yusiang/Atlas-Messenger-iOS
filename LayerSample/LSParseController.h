//
//  LSParseController.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <Parse/Parse.h>
#import "LSLayerController.h"

@interface LSParseController : NSObject

//@property (nonatomic, strong) LSLayerController *layerController;

- (id) init;

- (void)initializeParseSDK;

- (void)createParseUserWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(NSError *error))completion;

- (void)logParseUserInWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(NSError *error))completion;

- (void)logOutParseUser;

- (void)requestLayerIdentityTokenWithNonce:(NSString *)nonce;

@end
