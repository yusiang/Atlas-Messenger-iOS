//
//  LSKeychainUtilities.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NSData *LYRIssuerData();

void LYRTestDeleteKeysFromKeychain();

BOOL LYRTestDeleteCertificatesFromKeychain();

BOOL LYRTestDeleteIdentitiesFromKeychain();

void LYRTestCleanKeychain();