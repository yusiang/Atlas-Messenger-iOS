//
//  LYRCertificate.h
//  LayerKit
//
//  Created by Blake Watters on 3/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The `LYRCertificate` models a cryptographic certificate issued by Layer
 and persisted into the iOS keychain.
 
 A valid certificate is required to establish a TLS session with Layer.
 */
@interface LYRCertificate : NSObject

///----------------------------
/// @name Accessing Issuer Data
///----------------------------

/**
 Returns the data for certificates issued by Layer.
 
 This issuer data can be used to query the Keychain for Layer issued certificates.
 */
+ (NSData *)issuerData;

///----------------------------------------------
/// @name Loading a Certificate from the Keychain
///----------------------------------------------

/**
 Returns an existing Layer issued client certificate from the Keychain.
 
 This method searches the Keychain for a certificate that was issued by the Layer backend. If such a certificate is found,
 it is loaded and wrapped into an instance of `LYRCertificate` and returned.
 
 @param error A pointer to an error object that, upon failure, describes the nature of the error.
 */
+ (instancetype)certificateFromKeychainWithError:(NSError **)error;

///-------------------------------------------
/// @name Constructing a Certificate from Data
///-------------------------------------------

/**
 @abstract Creates and returns a new certificate with the given data.
 @discussion This method does not persist the certificate.
 @param data A DER encoded data representation of the certificate.
 @return A new certificate object for the given data.
 */
+ (instancetype)certificateWithData:(NSData *)data;

///-----------------------------
/// @name Saving to the Keychain
///-----------------------------

/**
 @abstract Returns a Boolean value that indicates if the certificate modeled by the receiver is in the Keychain.
 @return `YES` if the certificate exists in the Keychain, else `NO`.
 */
- (BOOL)existsInKeychain;

/**
 @abstract Saves the certificate to the Keychain.
 @param error A pointer to an error object that upon failure describes the nature of the error.
 @return A Boolean value indicating if persistence to the Keychain was successful.
 */
- (BOOL)saveToKeychain:(NSError **)error;

///------------------------------------
/// @name Accessing Certificate Details
///------------------------------------

/**
 Returns the Common Name of the certificate.
 */
@property (nonatomic, copy, readonly) NSString *commonName;

/**
 Returns the underlying certificate ref for the certificate.
 */
@property (nonatomic, assign, readonly) SecCertificateRef certificateRef;

/**
 Returns the underlying data for the certificate.
 */
@property (nonatomic, strong, readonly) NSData *certificateData;

@end
