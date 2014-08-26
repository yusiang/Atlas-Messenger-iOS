//
//  LSKeyChainUtilities.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSKeychainUtilities.h"

NSData *LYRIssuerData(void)
{
    static NSString *issuerInBase64 = @"MQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ0FMSUZPUk5JQTEWMBQGA1UEBxMNU0FOIEZSQU5DSVNDTzEOMAwGA1UEChMFTEFZRVIxFjAUBgNVBAsTDVBMQVRGT1JNIFRFQU0xEjAQBgNVBAMTCUxBWUVSLkNPTTEcMBoGCSqGSIb3DQEJARYNZGV2QGxheWVyLmNvbQ==";
    static NSData *layerCertificateIssuer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        layerCertificateIssuer = [[NSData alloc] initWithBase64EncodedString:issuerInBase64 options:0];
    });
    return layerCertificateIssuer;
}

void LYRTestDeleteKeysFromKeychain(void)
{
    NSDictionary *query = @{ (__bridge id)kSecClass: (__bridge id)kSecClassKey,
                             (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA };
    
    OSStatus err = SecItemDelete((__bridge CFDictionaryRef)query);
    if(!(err == noErr || err == errSecItemNotFound)) {
        NSLog(@"SecItemDeleteError: %d", (int)err);
    }
}

BOOL LYRTestDeleteCertificatesFromKeychain(void)
{
    NSDictionary *query = @{ (__bridge id)kSecClass: (__bridge id)kSecClassCertificate,
                             (__bridge id)kSecAttrIssuer: LYRIssuerData() };
    
    OSStatus err = SecItemDelete((__bridge CFDictionaryRef)query);
    if(!(err == noErr || err == errSecItemNotFound)) {
        NSLog(@"SecItemDeleteError: %d", (int)err);
        return NO;
    }
    return YES;
}

BOOL LYRTestDeleteIdentitiesFromKeychain(void)
{
    NSDictionary *query = @{ (__bridge id)kSecClass: (__bridge id)kSecClassIdentity,
                             (__bridge id)kSecAttrIssuer: LYRIssuerData() };
    OSStatus err = SecItemDelete((__bridge CFDictionaryRef)query);
    if(!(err == noErr || err == errSecItemNotFound)) {
        NSLog(@"SecItemDeleteError: %d", (int)err);
        return NO;
    }
    return YES;
}

void LYRTestCleanKeychain(void)
{
    LYRTestDeleteKeysFromKeychain();
    LYRTestDeleteCertificatesFromKeychain();
    LYRTestDeleteIdentitiesFromKeychain();
}