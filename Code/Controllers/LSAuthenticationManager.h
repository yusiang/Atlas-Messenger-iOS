//
//  LSConnectionManager.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSLayerController.h"
#import "LSUser.h"

@interface LSAuthenticationManager : NSObject

@property (nonatomic, strong) LSLayerController *layerController;
@property (nonatomic, readonly) NSString *authToken;
@property (nonatomic, readonly) NSString *email;

- (id)initWithBaseURL:(NSString *)baseURL;

- (void)signUpUser:(LSUser *)user completion:(void(^)(BOOL success, NSError *error))completion;

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(void(^)(BOOL success, NSError *error))completion;

- (void)resumeSessionWithCompletion:(void(^)(BOOL success, NSError *error))completion;

- (void)logoutWithCompletion:(void(^)(BOOL success, NSError *error))completion;

@end
