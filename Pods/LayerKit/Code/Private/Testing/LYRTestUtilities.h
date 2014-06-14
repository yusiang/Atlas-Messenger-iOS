//
//  LYRTestUtilities.h
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRTestProvider.h"

void LYRTestDeleteKeysFromKeychain(void);
BOOL LYRTestDeleteCertificatesFromKeychain(void);
BOOL LYRTestDeleteIdentitiesFromKeychain(void);
void LYRTestDeletePersistedSession(void);

NSBundle *LYRTestBundle();

/**
 Default: @"172.17.8.101" (Vagrant host)
 */
NSString *LYRTestHost();

/**
 Default: 9092
 */
NSUInteger LYRTestControlPort();

/**
 Default: 7072
 */
NSUInteger LYRTestSPDYPort();

/**
 Default: http://localhost:5555
 */
NSURL *LYRTestHTTPBaseURL();

/**
 Default: http://localhost:7072
 */
NSURL *LYRTestSPDYBaseURL();

/**
 @abstract A shared instance of a test provider usable for testing.
 */
LYRTestProvider *LYRSharedTestProvider();

// Defined by LYRClient
NSString *LYRApplicationDataDirectory(void);

/**
 Closes any existing SPDY sessions, forcing a new connection to be opened.
 */
void LYRTestCloseSPDYSessions();

/**
 Cleans the Keychain by deleting all keys, certificates, and identities.
 */
void LYRTestCleanKeychain(void);
