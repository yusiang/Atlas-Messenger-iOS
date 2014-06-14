//
//  LYRTestControlClient.m
//  LayerKit
//
//  Created by Blake Watters on 4/8/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRTestControlClient.h"
#import "LYRBase64Serialization.h"

#import "TSocketClient.h"
#import "TFramedTransport.h"
#import "TBinaryProtocol.h"
#import "TCompactProtocol.h"
#import "ctrl.h"
#import "LYRUUIDData.h"

#import "LYRTestProvider.h"

// Defined in LYRTestUtilities.h
extern NSString *LYRTestHost();
extern NSUInteger LYRTestControlPort();

NSString *LYRPublicKeyDataWithPKC1Wrapping(NSData *publicKeyData);

@interface LYRTestProvider ()
- (id)initWithAccount:(LYRTAccount *)account keyPair:(LYRKeyPair *)keyPair publicKey:(LYRTPublicKey *)publicKey apps:(NSArray *)apps;
@end

@implementation LYRTestControlClient

+ (instancetype)controlClientWithHost:(NSString *)hostname port:(NSUInteger)port
{
    return [[LYRTestControlClient alloc] initWithHostname:(hostname ?: LYRTestHost()) port:(port ?: LYRTestControlPort())];
}

- (id)initWithHostname:(NSString *)hostname port:(NSUInteger)port
{
    self = [self init];
    if (self) {
        _hostname = hostname;
        _port = port;
        
        TSocketClient *binaryClient = [[TSocketClient alloc] initWithHostname:hostname port:(int)port];
        TFramedTransport *framedTransport = [[TFramedTransport alloc] initWithTransport:binaryClient];
        TBinaryProtocol *binaryProtocol = [[TBinaryProtocol alloc] initWithTransport:framedTransport strictRead:NO strictWrite:YES];
        _thriftClient = [[LYRTCtrlClient alloc] initWithProtocol:binaryProtocol];
    }
    return self;
}

- (LYRTAccount *)createAccountWithConfigurationBlock:(void (^)(LYRTAccount *account))configurationBlock
{
    LYRTAccount *account = [LYRTAccount new];
    account.first_name = [[NSUUID UUID] UUIDString];
    account.last_name = [[NSUUID UUID] UUIDString];
    account.email = [NSString stringWithFormat:@"%@@Testing.LayerKit.layer.com", [[NSUUID UUID] UUIDString]];
    account.password = @"password";
    if (configurationBlock) configurationBlock(account);
    return [self.thriftClient createAccount:account];
}

- (LYRTPublicKey *)addPublicKeyOfKeyPair:(LYRKeyPair *)keyPair toAccount:(LYRTAccount *)account
{
    NSParameterAssert(account);
    NSParameterAssert(keyPair);
    
    LYRTPublicKey *publicKey = [LYRTPublicKey new];
    publicKey.provider_id = account.provider_id;
    publicKey.public_key = [LYRPublicKeyDataWithPKC1Wrapping(keyPair.publicKeyData) dataUsingEncoding:NSUTF8StringEncoding];
    publicKey.deleted = NO;
    publicKey.disabled = NO;
    return [self.thriftClient addPublicKey:publicKey];
}

- (LYRTestProvider *)createProviderWithConfigurationBlock:(void (^)(LYRTAccount *account))configurationBlock
{
    LYRTAccount *account = [self createAccountWithConfigurationBlock:configurationBlock];
    if (!account) return nil;
    
    // Provision a public key
    NSError *error = nil;
    LYRKeyPair *keyPair = [LYRKeyPair generateKeyPairWithIdentifier:[[NSUUID UUID] UUIDString] size:1024 error:&error];
    LYRTPublicKey *publicKey = [self addPublicKeyOfKeyPair:keyPair toAccount:account];
    if (!publicKey) return nil;
    
    // Get the apps
    NSArray *apps = [self.thriftClient getAppsFromAccount:account.id];
    
    return [[LYRTestProvider alloc] initWithAccount:account keyPair:keyPair publicKey:publicKey apps:apps];
}

- (void)revokeSession:(LYRSession *)session
{
    NSParameterAssert(session);
    [self.thriftClient revokeSession:LYRDataFromUUID(session.appID) user_id:LYRDataFromUUID(session.layerUserID)];
}

@end
