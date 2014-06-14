//
//  LYRTestUtilities.m
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRTestUtilities.h"
#import "LYRCertificate.h"
#import "LYRTestControlClient.h"
#import "LYRSPDYURLSessionProtocol.h"
#import "LYRTestingContext.h"

NSString *const LYRTestAppKey = @"layer_test";
NSString *const LYRTestBundleIdentifier = @"com.layer.LayerKit.Tests";

extern NSString *const LYRSessionFilename;

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
                             (__bridge id)kSecAttrIssuer: [LYRCertificate issuerData] };
    
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
                             (__bridge id)kSecAttrIssuer: [LYRCertificate issuerData] };
    OSStatus err = SecItemDelete((__bridge CFDictionaryRef)query);
    if(!(err == noErr || err == errSecItemNotFound)) {
        NSLog(@"SecItemDeleteError: %d", (int)err);
        return NO;
    }
    return YES;
}

void LYRTestDeletePersistedSession(void)
{
    NSString *path = [LYRApplicationDataDirectory() stringByAppendingPathComponent:LYRSessionFilename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

NSBundle *LYRTestBundle()
{
    return [NSBundle bundleWithIdentifier:LYRTestBundleIdentifier];
}

LYRTestProvider *LYRSharedTestProvider()
{
    static LYRTestProvider *provider;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LYRTestControlClient *controlClient = [LYRTestControlClient controlClientWithHost:LYRTestHost() port:LYRTestControlPort()];
        provider = [controlClient createProviderWithConfigurationBlock:nil];
    });
    return provider;
}

NSString *LYRTestHost()
{
    return [NSProcessInfo processInfo].environment[@"LAYER_TEST_HOST"] ?: [LYRTestBundle() infoDictionary][@"LAYER_TEST_HOST"];
}

NSUInteger LYRTestControlPort()
{
    return [([NSProcessInfo processInfo].environment[@"LAYER_TEST_CONTROL_PORT"] ?: @(9092)) unsignedIntegerValue];
}

NSUInteger LYRTestSPDYPort()
{
    return [([NSProcessInfo processInfo].environment[@"LAYER_TEST_SPDY_PORT"] ?: @(7072)) unsignedIntegerValue];
}

NSURL *LYRTestHTTPBaseURL()
{
    NSString *baseURLString = ([NSProcessInfo processInfo].environment[@"LAYER_TEST_HTTP_BASE_URL"] ?:
                               [NSString stringWithFormat:@"http://%@:5555", LYRTestHost()]);
    return [NSURL URLWithString:baseURLString];
}

NSURL *LYRTestSPDYBaseURL()
{
    NSString *baseURLString = ([NSProcessInfo processInfo].environment[@"LAYER_TEST_SPDY_BASE_URL"] ?:
                               [NSString stringWithFormat:@"https://%@:%lu", LYRTestHost(), (unsigned long)LYRTestSPDYPort()]);
    return [NSURL URLWithString:baseURLString];
}

void LYRTestCloseSPDYSessions()
{
    [[LYRSPDYURLSessionProtocol sessions] makeObjectsPerformSelector:@selector(close)];
}

void LYRTestCleanKeychain(void)
{
    LYRTestDeleteKeysFromKeychain();
    LYRTestDeleteCertificatesFromKeychain();
    LYRTestDeleteIdentitiesFromKeychain();
}

@interface LYRTestInitializer : NSObject
@end

@implementation LYRTestInitializer

+ (void)load
{
    // Bring the testing context up
    LYRTestCleanKeychain();
    [LYRTestingContext sharedContext];
    
    // Establish a clean Keychain context
    LYRTestCleanKeychain();
    
    // Set logging based on environment variables
    LYRSetLogLevelFromEnvironment();
}

@end
