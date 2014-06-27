//
//  LSConnectionManager.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: Rename to `LSAuthenticationManager`
@interface LSConnectionManager : NSObject <NSURLSessionDelegate> // TODO: Move `NSURLSessionDelegate` to the class extension

// TODO: initWithBaseURL:

@property (nonatomic, readonly) NSString *authToken;
@property (nonatomic, readonly) NSString *email;

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password completion:(void(^)(BOOL success, NSError *error))completion;
// TODO: Add a login method
// TODO: Add some way to manage resuming an existing session

- (void)requestLayerIdentityTokenWithNonce:(NSString *)nonce completion:(void(^)(NSString *identityToken, NSError *error))completion;

@end
