//
//  LYRClient.h
//  LayerKit
//
//  Created by Klemen Verdnik on 7/23/13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

#import "LYRClient.h"
#import "LYRTransportManager.h"
#import "LYRCryptographer.h"
#import "LYRSynchronizationDataSource.h"
#import "LYRSynchronizationManager.h"

#define ifCompletion(c, x)        c ? c(x)       : nil
#define ifCompletion2(c, x, y)    c ? c(x, y)    : nil
#define ifCompletion3(c, x, y, z) c ? c(x, y, z) : nil
#define ifCompletion4(c, x, y, z, w) c ? c(x, y, z, w) : nil

NSString *LYRApplicationDataDirectory(void);

/**
 The filename to which session info is written into the application data directory.
 */
NSString *const LYRSessionFilename;

extern NSString *const LYRClientErrorDomain;
typedef NS_ENUM(NSUInteger, LYRClientError) {
    // Client Errors
    LYRClientErrorAlreadyConnected        = 6000,
    
    // Crypto Configuration Errors
    LYRClientErrorKeyPairNotFound         = 7000,
    LYRClientErrorCertificateNotFound     = 7001,
    LYRClientErrorIdentityNotFound        = 7002,
    
    // Authentication
    LYRClientErrorFailedToPersistSession  = 7003,
};

@class LYRTSession;

@interface LYRClient ()

// Designated initializer
- (id)initWithBaseURL:(NSURL *)baseURL appID:(NSUUID *)appID;

@property (nonatomic, copy) NSURL *baseURL;

@property (nonatomic) LYRTransportManager *transportManager;
@property (nonatomic, readonly) LYRCryptographer *cryptographer;
@property (nonatomic) LYRSession *session;
@property (nonatomic) LYRSynchronizationDataSource *persistenceManager;
@property (nonatomic) LYRSynchronizationManager *synchronizationManager;

@property (nonatomic, copy) void (^startCompletion)(BOOL success, NSError *error);

@property (nonatomic) NSString *pushToken;

- (void)clearAuthenticationStateAndNotify:(BOOL)notify;

@end
