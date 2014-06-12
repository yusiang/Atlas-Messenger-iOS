//
//  LYRCryptographer.m
//  LayerKit
//
//  Created by Blake Watters on 4/10/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRCryptographer.h"
#import "LYRCSR.h"
#import "LYRBase64Serialization.h"
#import "LYRClient+Private.h"
#import "LYRJSONHTTPResponseSerializer.h"

@interface LYRCryptographer () <NSURLSessionDelegate>

@property (nonatomic, readwrite) NSString *keyPairIdentifier;
@property (nonatomic, readwrite) NSURL *authorizationBaseURL;
@property (nonatomic, readwrite) LYRKeyPair *keyPair;
@property (nonatomic, readwrite) LYRCertificate *certificate;
@property (nonatomic, assign, readwrite) SecIdentityRef identityRef;

@end

@implementation LYRCryptographer

- (id)initWithKeyPairIdentifier:(NSString *)keyPairIdentififer authorizationBaseURL:(NSURL *)authorizationBaseURL
{
    self = [super init];
    if (self) {
        _keyPairIdentifier = keyPairIdentififer;
        _authorizationBaseURL = authorizationBaseURL;
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Failed to call designated initializer. Call `%@` instead.", NSStringFromSelector(@selector(initWithKeyPairIdentifier:authorizationBaseURL:))]
                                 userInfo:nil];
}

- (void)obtainCryptographicAssets:(void (^)(BOOL success, NSError *error))completion
{
    NSError *error = nil;
    LYRKeyPair *keyPair = [LYRKeyPair generateKeyPairWithIdentifier:self.keyPairIdentifier size:1024 error:&error];
    if (!keyPair) {
        LYRLogError(@"Failed to generate keyPair: %@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(NO, error);
        });
        return;
    }
    LYRCSR *CSR = [LYRCSR CSRWithKeyPair:keyPair];
    NSString *JWSString = [CSR JWSStringRepresentation];
    NSDictionary *requestBody = @{ @"csr": JWSString };
    NSURL *URL = [NSURL URLWithString:@"certificates" relativeToURL:self.authorizationBaseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:LYRHTTPUserAgentString() forHTTPHeaderField:@"User-Agent"];
    NSData *JSONBody = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&error];
    if (!JSONBody) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(NO, error);
        });
        return;
    }
    [request setHTTPBody:JSONBody];
    
    NSURLSession *URLSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:self delegateQueue:nil];
    NSURLSessionDataTask *task = [URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (! response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(NO, error);
            });
            return;
        }
        
        // Process the response
        id responseObject = nil;
        NSError *serializationError = nil;
        BOOL success = [LYRJSONHTTPResponseSerializer responseObject:&responseObject forResponse:(NSHTTPURLResponse *)response data:data error:&serializationError];
        if (success) {
            if (! responseObject) {
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedStringFromTable(@"Invalid response: %@ (%lu)", @"LayerKit", nil), [NSHTTPURLResponse localizedStringForStatusCode:[(NSHTTPURLResponse *)response statusCode]], (unsigned long)[(NSHTTPURLResponse *)response statusCode]],
                                           NSURLErrorFailingURLErrorKey:[response URL],
                                           LYRHTTPErrorFailingURLResponseErrorKey: response,
                                           LYRHTTPErrorFailingURLResponseObjectErrorKey: responseObject
                                           };
                serializationError = [NSError errorWithDomain:LYRHTTPErrorDomain code:LYRHTTPErrorInvalidResponseObject userInfo:userInfo];
            } else {
                NSError *securityError = nil;
                NSData *certificateData = [LYRBase64Serialization dataFromBase64String:responseObject[@"certificate"]];
                LYRCertificate *certificate = [LYRCertificate certificateWithData:certificateData];
                if (certificate) {
                    BOOL success = [certificate saveToKeychain:&securityError];
                    if (!success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) completion(NO, securityError);
                        });
                        return;
                    }
                    SecIdentityRef identityRef = [self loadIdentityWithError:&error];
                    if (! identityRef) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) completion(NO, securityError);
                        });
                        return;
                    }
                    
                    // Keys, certificate and identity are all established
                    self.keyPair = keyPair;
                    self.certificate = certificate;
                    self.identityRef = identityRef;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) completion(YES, nil);
                    });
                    return;
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) completion(NO, securityError);
                    });
                    return;
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(NO, serializationError);
            });
            return;
        }
    }];
    [task resume];
    [URLSession finishTasksAndInvalidate];
}

- (SecIdentityRef)loadIdentityWithError:(NSError **)error
{
    NSDictionary *query = @{ (__bridge id)kSecClass: (__bridge id)kSecClassIdentity,
                             (__bridge id)kSecAttrIssuer: [LYRCertificate issuerData],
                             (__bridge id)kSecReturnRef: @(YES),
                             (__bridge id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPrivate };
    SecIdentityRef identityRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&identityRef);
    if (status == noErr) {
        return identityRef;
    }
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Unable to load cryptographic identity from keychain." };
    if (error) *error = [NSError errorWithDomain:LYRSecurityErrorDomain code:status userInfo:userInfo];
    return NULL;
}

- (BOOL)loadCryptographicAssetsFromKeychain:(NSError **)error
{
    if (self.keyPair || self.certificate || self.identityRef) {
        [NSException raise:NSInternalInconsistencyException format:@"Attempted to load crypto assets from keychain with some already loaded."];
    }
    LYRKeyPair *keyPair = [LYRKeyPair keyPairWithIdentifier:self.keyPairIdentifier error:error];
    if (!keyPair) return NO;
    LYRCertificate *certificate = [LYRCertificate certificateFromKeychainWithError:error];
    if (!certificate) return NO;
    SecIdentityRef identityRef = [self loadIdentityWithError:error];
    if (!identityRef) return NO;
    self.keyPair = keyPair;
    self.certificate = certificate;
    self.identityRef = identityRef;
    
    return YES;
}

- (BOOL)hasCryptographicAssets
{
    return self.keyPair && self.certificate && self.identityRef;
}

@end
