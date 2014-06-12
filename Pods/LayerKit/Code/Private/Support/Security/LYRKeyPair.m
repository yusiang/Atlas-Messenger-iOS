//
//  LYRKeyPair.m
//  LayerKit
//
//  Created by Blake Watters on 3/25/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import "LYRKeyPair.h"

NSString *const LYRSecurityErrorDomain = @"com.layer.LayerKit.Security";

@interface LYRKeyPair ()
@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, assign, readwrite) SecKeyRef publicKeyRef;
@property (nonatomic, assign, readwrite) SecKeyRef privateKeyRef;
@property (nonatomic, strong, readwrite) NSData *publicKeyData;
@property (nonatomic, strong, readwrite) NSData *privateKeyData;
@property (nonatomic, assign, readwrite) NSUInteger keySizeInBits;
@end

@implementation LYRKeyPair

+ (instancetype)generateKeyPairWithIdentifier:(NSString *)identifier size:(NSUInteger)bits error:(NSError **)error
{
    NSDictionary *keyPairAttributes = @{ (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA, // RSA Key
                                         (__bridge id)kSecAttrKeySizeInBits: @(bits),
                                         (__bridge id)kSecAttrIsPermanent: @(YES), // Store into Keychain
                                         (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAfterFirstUnlock,
                                         (__bridge id)kSecAttrApplicationTag: [identifier dataUsingEncoding:NSUTF8StringEncoding]
                                         };

    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;
    OSStatus status = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttributes, &publicKey, &privateKey);
    if (status == errSecSuccess) {
        NSDictionary *query = @{ (__bridge id)kSecClass: (__bridge id)kSecClassKey,
                                 (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
                                 (__bridge id)kSecReturnData: @(YES),
                                 (__bridge id)kSecReturnAttributes: @(YES),
                                 (__bridge id)kSecReturnRef: @(YES),
                                 (__bridge id)kSecAttrApplicationTag: [identifier dataUsingEncoding:NSUTF8StringEncoding],
                                 (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitAll };
        CFArrayRef queryResults = NULL;
        status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&queryResults);
        if (status == noErr) {
            if (CFArrayGetCount(queryResults) == 2) {
                LYRKeyPair *keyPair = [[self alloc] initWithIdentifier:identifier];
                [keyPair loadKeysFromKeychainResults:(__bridge NSArray *)(queryResults)];
                return keyPair;
            } else {
                status = errSecInternalComponent;
            }
        }
    }
    
    if (error) *error = [NSError errorWithDomain:LYRSecurityErrorDomain code:status userInfo:nil];
    return nil;
}

+ (instancetype)keyPairWithIdentifier:(NSString *)identifier error:(NSError **)error
{
    NSDictionary *query = @{ (__bridge id)kSecClass: (__bridge id)kSecClassKey,
                             (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
                             (__bridge id)kSecReturnRef: @(YES),
                             (__bridge id)kSecReturnData: @(YES),
                             (__bridge id)kSecReturnAttributes: @(YES),
                             (__bridge id)kSecAttrApplicationTag: [identifier dataUsingEncoding:NSUTF8StringEncoding],
                             (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitAll };
    CFArrayRef queryResults = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&queryResults);
    if (status == noErr) {
        if (CFArrayGetCount(queryResults) == 2) {
            LYRKeyPair *keyPair = [[LYRKeyPair alloc] initWithIdentifier:identifier];
            [keyPair loadKeysFromKeychainResults:(__bridge NSArray *)(queryResults)];
            return keyPair;
        } else {
            status = errSecInternalComponent;
        }
    }
    if (error) *error = [NSError errorWithDomain:LYRSecurityErrorDomain code:status userInfo:nil];
    return nil;
}

+ (instancetype)keyPairWithIdentifier:(NSString *)identifier privateKeyData:(NSData *)privateKeyData publicKeyData:(NSData *)publicKeyData size:(NSUInteger)bits
{
    LYRKeyPair *keyPair = [[LYRKeyPair alloc] initWithIdentifier:identifier];
    keyPair.publicKeyData = publicKeyData;
    keyPair.privateKeyData = privateKeyData;
    keyPair.keySizeInBits = bits;
    return keyPair;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Failed to call designated initializer: Call `keyPairWithIdentifier:error:`."
                                 userInfo:nil];
}

- (id)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
    }
    return self;
}

/**
 This method requires that the keychain query results include full data for the public and private keys. This includes
 the data, key ref, and attributes.
 */
- (void)loadKeysFromKeychainResults:(NSArray *)keychainResults
{
    for (NSDictionary *keyInfo in keychainResults) {
        /**
         NOTE: Black magic below. The Keychain API is inconsistent about the type for `kSecAttrKeyClassPublic`. The
         constants are defined as strings, but the value you get back for the `kSecAttrKeyClass` is a CFNumber.
         We cast to an object and use the description for comparison to get a reliable result (even if this changes in the future).
         */
        CFTypeRef keyClass = (__bridge CFTypeRef)(keyInfo[(__bridge id)kSecAttrKeyClass]);
        if ([[(__bridge id)keyClass description] isEqual:(__bridge id)kSecAttrKeyClassPublic]) {
            self.publicKeyRef = (__bridge SecKeyRef)(keyInfo[(__bridge id)kSecValueRef]);
            self.publicKeyData = keyInfo[(__bridge id)kSecValueData];
        } else if ([[(__bridge id)keyClass description] isEqual:(__bridge id)kSecAttrKeyClassPrivate]) {
            self.privateKeyRef = (__bridge SecKeyRef)(keyInfo[(__bridge id)kSecValueRef]);
            self.privateKeyData = keyInfo[(__bridge id)kSecValueData];
            self.keySizeInBits = [keyInfo[(__bridge id)kSecAttrKeySizeInBits] unsignedIntegerValue];
        } else {
            [NSException raise:NSInternalInconsistencyException format:@"Invalid key type encountered."];
        }
    }
}

- (BOOL)existsInKeychain
{
    NSDictionary *query = @{ (__bridge id)kSecClass: (__bridge id)kSecClassKey,
                             (__bridge id)kSecValueData: self.privateKeyData,
                             (__bridge id)kSecReturnAttributes: @(YES) };
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    if (status != noErr) return NO;
    
    query = @{ (__bridge id)kSecClass: (__bridge id)kSecClassKey,
               (__bridge id)kSecValueData: self.publicKeyData,
               (__bridge id)kSecReturnAttributes: @(YES) };
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    return (status == noErr);
}

- (BOOL)saveToKeychain:(NSError **)error
{
    // Save private key
    NSDictionary *attributes = @{ (__bridge id)kSecClass: (__bridge id)kSecClassKey,
                                  (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
                                  (__bridge id)kSecAttrApplicationTag: [self.identifier dataUsingEncoding:NSUTF8StringEncoding],
                                  (__bridge id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPrivate,
                                  (__bridge id)kSecValueData: self.privateKeyData,
                                  (__bridge id)kSecAttrKeySizeInBits: @(self.keySizeInBits),
                                  (__bridge id)kSecAttrEffectiveKeySize: @(self.keySizeInBits),
                                  (__bridge id)kSecAttrCanDerive: @(YES),
                                  (__bridge id)kSecAttrCanEncrypt: @(YES),
                                  (__bridge id)kSecAttrCanDecrypt: @(YES),
                                  (__bridge id)kSecAttrCanVerify: @(NO),
                                  (__bridge id)kSecAttrCanSign: @(YES),
                                  (__bridge id)kSecAttrCanWrap: @(NO),
                                  (__bridge id)kSecAttrCanUnwrap: @(YES),
                                  (__bridge id)kSecReturnRef: @(YES) };
    SecKeyRef privateKeyRef = NULL;
    OSStatus err = SecItemAdd((__bridge CFDictionaryRef)attributes, (CFTypeRef *)&privateKeyRef);
    if (err != noErr) {
        if (error) *error = [NSError errorWithDomain:LYRSecurityErrorDomain code:err userInfo:nil];
    }
    self.privateKeyRef = privateKeyRef;
    
    // Save public key
    attributes = @{ (__bridge id)kSecClass: (__bridge id)kSecClassKey,
                    (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
                    (__bridge id)kSecAttrApplicationTag: [self.identifier dataUsingEncoding:NSUTF8StringEncoding],
                    (__bridge id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPublic,
                    (__bridge id)kSecValueData: self.publicKeyData,
                    (__bridge id)kSecAttrKeySizeInBits: @(self.keySizeInBits),
                    (__bridge id)kSecAttrEffectiveKeySize: @(self.keySizeInBits),
                    (__bridge id)kSecAttrCanDerive: @(NO),
                    (__bridge id)kSecAttrCanEncrypt: @(NO),
                    (__bridge id)kSecAttrCanDecrypt: @(NO),
                    (__bridge id)kSecAttrCanVerify: @(YES),
                    (__bridge id)kSecAttrCanSign: @(NO),
                    (__bridge id)kSecAttrCanWrap: @(YES),
                    (__bridge id)kSecAttrCanUnwrap: @(NO),
                    (__bridge id)kSecReturnRef: @(YES) };
    SecKeyRef publicKeyRef = NULL;
    err = SecItemAdd((__bridge CFDictionaryRef)attributes, (CFTypeRef *)&publicKeyRef);
    if (err != noErr) {
        if (error) *error = [NSError errorWithDomain:LYRSecurityErrorDomain code:err userInfo:nil];
    }
    self.publicKeyRef = publicKeyRef;
    
    return YES;
}

- (NSData *)dataByEncryptingData:(NSData *)data error:(NSError *__autoreleasing *)error
{
    if (! data) [NSException raise:NSInvalidArgumentException format:@"Cannot encrypt `nil` data."];
    size_t outputLength = MAX([data length], SecKeyGetBlockSize(self.publicKeyRef));
    void *outputBuf = malloc(outputLength);
    OSStatus status = SecKeyEncrypt(self.publicKeyRef, kSecPaddingPKCS1SHA256,
                                    [data bytes], (size_t) [data length],
                                    outputBuf, &outputLength);
    if (status == noErr) {
        return [NSData dataWithBytesNoCopy:outputBuf length:outputLength freeWhenDone:YES];
    }
    free(outputBuf);
    return nil;
}

- (NSData *)dataByDecryptingData:(NSData *)data error:(NSError *__autoreleasing *)error
{
    if (! data) [NSException raise:NSInvalidArgumentException format:@"Cannot decrypt `nil` data."];
    size_t outputLength = MAX([data length], SecKeyGetBlockSize(self.privateKeyRef));
    void *outputBuf = malloc(outputLength);
    OSStatus status = SecKeyDecrypt(self.privateKeyRef, kSecPaddingPKCS1,
                                    [data bytes], (size_t) [data length],
                                    outputBuf, &outputLength);
    if (status == noErr) {
        return [NSData dataWithBytesNoCopy:outputBuf length:outputLength freeWhenDone:YES];
    }
    free(outputBuf);
    return nil;
}

- (NSData *)signatureForData:(NSData *)data error:(NSError *__autoreleasing *)error
{
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (uint32_t)data.length, digest);
    
    size_t signedHashBytesSize = SecKeyGetBlockSize(self.privateKeyRef);
	uint8_t *signedHashBytes = malloc(signedHashBytesSize * sizeof(uint8_t));
	memset((void *)signedHashBytes, 0x0, signedHashBytesSize);
    
    OSStatus err = SecKeyRawSign(self.privateKeyRef, kSecPaddingPKCS1SHA256,
                                 digest, sizeof(digest),
                                 signedHashBytes, &signedHashBytesSize);
    if (err == noErr) {
        return [NSData dataWithBytesNoCopy:signedHashBytes length:signedHashBytesSize freeWhenDone:YES];
    }
    free(signedHashBytes);
    if (error) *error = [NSError errorWithDomain:LYRSecurityErrorDomain code:err userInfo:nil];
    return nil;
}

- (BOOL)verifySignature:(NSData *)signature forData:(NSData *)data error:(NSError *__autoreleasing *)error
{
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (uint32_t)data.length, digest);
    
    size_t signedHashBytesSize = SecKeyGetBlockSize(self.publicKeyRef);
    OSStatus err = SecKeyRawVerify(self.publicKeyRef, kSecPaddingPKCS1SHA256,
                                   digest, sizeof(digest),
                                   (const uint8_t *)[signature bytes], signedHashBytesSize);
    if (err != noErr) {
        if (error) *error = [NSError errorWithDomain:LYRSecurityErrorDomain code:err userInfo:nil];
        return NO;
    }
    return YES;
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) return NO;
    if (![object isKindOfClass:[LYRKeyPair class]]) return NO;
    return ([self.publicKeyData isEqualToData:[(LYRKeyPair *)object publicKeyData]] &&
            [self.privateKeyData isEqualToData:[(LYRKeyPair *)object privateKeyData]]);
}

@end
