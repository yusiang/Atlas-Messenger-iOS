//
//  LYRBase64Serialization.h
//  LayerKit
//
//  Created by Blake Watters on 3/28/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The `LYRBase64Serialization` class provides an interface for handling data in Base64 encoding.
 */
@interface LYRBase64Serialization : NSObject

/**
 Decodes the data encoded in a Base64 encoded string.
 
 @param encodedString A string in Base64 encoding that is to be decoded.
 @return The data encoded in the input string or `nil` if it could not be decoded.
 */
+ (NSData *)dataFromBase64String:(NSString *)encodedString;

/**
 Encodes given input data into a Base64 encoded string.
 
 @param data The data to be encoded into Base64 encoding.
 @return A Base64 encoded string containing encoding the input data.
 */
+ (NSString *)base64StringFromData:(NSData *)data;

///--------------------------------------------------------------
/// @name Encoding & Decoding Base64 URL Encoding without Padding
///--------------------------------------------------------------

/**
 Decodes the data encoded in a Base64 URL encoded string without padding.
 
 @param encodedString A string in Base64 encoding that is to be decoded.
 @return The data encoded in the input string or `nil` if it could not be decoded.
 */
+ (NSData *)dataFromBase64URLEncodedStringWithoutPadding:(NSString *)encodedString;

/**
 Encodes given input data into a Base64 URL encoded string without padding.
 
 @param data The data to be encoded into Base64 encoding.
 @return A Base64 encoded string containing encoding the input data.
 */
+ (NSString *)base64URLEncodedStringWithoutPaddingFromData:(NSData *)data;


@end
