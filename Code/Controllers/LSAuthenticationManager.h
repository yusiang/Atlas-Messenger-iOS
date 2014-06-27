//
//  LSConnectionManager.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSAuthenticationManager : NSObject <NSURLSessionDelegate>

- (void)requestLayerIdentityTokenWithNonce:(NSString *)nonce completion:(void(^)(NSString *identityToken, NSError *error))completion;

@end
