//
//  LYRCertificate.m
//  LayerKit
//
//  Created by Blake Watters on 3/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRCertificate.h"
#import "LYRBase64Serialization.h"

extern NSString *const LYRSecurityErrorDomain;

@implementation LYRCertificate

+ (NSData *)issuerData
{
    static NSString *issuerInBase64 = @"MQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ0FMSUZPUk5JQTEWMBQGA1UEBxMNU0FOIEZSQU5DSVNDTzEOMAwGA1UEChMFTEFZRVIxFjAUBgNVBAsTDVBMQVRGT1JNIFRFQU0xEjAQBgNVBAMTCUxBWUVSLkNPTTEcMBoGCSqGSIb3DQEJARYNZGV2QGxheWVyLmNvbQ==";
    static NSData *layerCertificateIssuer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        layerCertificateIssuer = [LYRBase64Serialization dataFromBase64String:issuerInBase64];
    });
    return layerCertificateIssuer;
}

+ (instancetype)certificateFromKeychainWithError:(NSError **)error
{
    NSDictionary *query = @{ (__bridge id)kSecClass: (__bridge id)kSecClassCertificate,
                             (__bridge id)kSecAttrIssuer: [LYRCertificate issuerData],
                             (__bridge id)kSecReturnRef: @(YES) };
    SecCertificateRef certificateRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&certificateRef);
    if (status == noErr) {
        if (certificateRef) {
            NSData *certData = (__bridge NSData *) SecCertificateCopyData(certificateRef);
            return [[self alloc] initWithCertificateRef:certificateRef data:certData];
        }
    }
    if (error) *error = [NSError errorWithDomain:LYRSecurityErrorDomain code:status userInfo:nil];
    return nil;
}

+ (instancetype)certificateWithData:(NSData *)data
{
    SecCertificateRef certRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)data);
    if (!certRef) return nil;
    
    return [[self alloc] initWithCertificateRef:certRef data:data];
}

- (id)initWithCertificateRef:(SecCertificateRef)certificateRef data:(NSData *)data
{
    self = [super init];
    if (self) {
        _certificateRef = certificateRef;
        _certificateData = data;
        _commonName = (__bridge NSString *) SecCertificateCopySubjectSummary(certificateRef);
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Failed to call designated initialize. Call `certificateFromKeychainWithError:` or `certificateWithData:error:`"
                                 userInfo:nil];
}

- (BOOL)saveToKeychain:(NSError **)error
{
    NSDictionary *attributes = @{ (__bridge id)kSecValueRef: (__bridge id)self.certificateRef,
                                  (__bridge id)kSecClass: (__bridge id)kSecClassCertificate };
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
    if (status != noErr) {
        if (error) *error = [NSError errorWithDomain:LYRSecurityErrorDomain code:status userInfo:nil];
        return NO;
    }
    return YES;
}

- (BOOL)existsInKeychain
{
    NSDictionary *query = @{ (__bridge id)kSecValueData: self.certificateData,
                             (__bridge id)kSecClass: (__bridge id)kSecClassCertificate,
                             (__bridge id)kSecReturnAttributes: @(YES) };
    CFDictionaryRef attributes = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&attributes);
    return (status == noErr);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p cert:%@>", [self class], self, (id)self.certificateRef];
}

@end
