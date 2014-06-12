//
//  LYRCryptographer.h
//  LayerKit
//
//  Created by Blake Watters on 4/10/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRKeyPair.h"
#import "LYRCertificate.h"
#import "LYRSession.h"

/**
 @abstract The `LYRCryptographer` class manages cryptographic assets used by LayerKit.
 */
@interface LYRCryptographer : NSObject

- (id)initWithKeyPairIdentifier:(NSString *)keyPairIdentififer authorizationBaseURL:(NSURL *)authorizationBaseURL;

@property (nonatomic, readonly) NSString *keyPairIdentifier;
@property (nonatomic, readonly) NSURL *authorizationBaseURL;

///---------------------------
/// @name Cryptographic Assets
///---------------------------

@property (nonatomic, strong, readonly) LYRKeyPair *keyPair;
@property (nonatomic, strong, readonly) LYRCertificate *certificate;
@property (nonatomic, assign, readonly) SecIdentityRef identityRef;

// YES when all three of the above are present
@property (nonatomic, readonly) BOOL hasCryptographicAssets;

- (BOOL)loadCryptographicAssetsFromKeychain:(NSError **)error;
- (void)obtainCryptographicAssets:(void (^)(BOOL success, NSError *error))completion;

@end
