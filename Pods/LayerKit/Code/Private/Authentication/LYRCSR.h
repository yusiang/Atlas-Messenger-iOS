//
//  LYRCSR.h
//  LayerKit
//
//  Created by Blake Watters on 3/28/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRKeyPair.h"

/**
 The `LYRCSR` class provides an interface for the generation of CSR for use in the initial phase of
 authenticating with the Layer backend.
 */
@interface LYRCSR : NSObject

///-------------------------
/// @name Initializing a CSR
///-------------------------

/**
 Creates and returns a new CSR object for the given key pair.
 
 @param keyPair A key pair object representing the key data to be exchanged with Layer.
 @return A new CSR object, ready for exchange with Layer.
 */
+ (instancetype)CSRWithKeyPair:(LYRKeyPair *)keyPair;

///-------------------------------
/// @name Accessing CSR Components
///-------------------------------

/**
 Returns the CSR header as a dictionary.
 */
@property (nonatomic, readonly) NSDictionary *header;

/**
 Returns the CSR payload as a dictionary.
 */
@property (nonatomic, readonly) NSDictionary *payload;

///-------------------------------
/// @name Accessing the JWS String
///-------------------------------

/**
 Returns the complete JWS string including the Base64 encoded representations of the header,
 payload, and a SHA256 cryptographic signature thereof concatenated into a single string, delimited by periods ('.').
 */
- (NSString *)JWSStringRepresentation;

@end
