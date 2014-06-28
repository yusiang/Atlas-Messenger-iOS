//
//  LSConnectionManager.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "LSUser.h"

@interface LSAuthenticationManager : NSObject

@property (nonatomic, readonly) LYRClient *layerClient;
@property (nonatomic, readonly) NSString *authToken;
@property (nonatomic, readonly) NSString *email;

- (id)initWithBaseURL:(NSString *)baseURL layerClient:(LYRClient *)layerClient;

- (void)signUpUser:(LSUser *)user completion:(void(^)(LSUser *user, NSError *error))completion;

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(void(^)(LSUser *user, NSError *error))completion;

- (void)resumeSessionWithCompletion:(void(^)(LSUser *user, NSError *error))completion;

- (void)logoutWithCompletion:(void(^)(BOOL success, NSError *error))completion;

@end
