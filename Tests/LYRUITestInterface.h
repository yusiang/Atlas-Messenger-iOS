//
//  LYRUITestInterface.h
//  LayerSample
//
//  Created by Kevin Coleman on 9/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSUser.h"
#import "LSApplicationController.h"
#import "LYRCountDownLatch.h"
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>

@interface LYRUITestInterface : NSObject

+ (instancetype)testInterfaceWithApplicationController:(LSApplicationController *)applicationController;

///******************************
/// Authentication Methods
///******************************

- (NSString *)registerUser:(LSUser *)user;

- (NSString *)authenticateWithEmail:(NSString *)email password:(NSString *)password;

- (void)logout;

///********************************
/// Participant Management Methods
///********************************

- (void)loadContacts;

- (NSSet *)fetchContacts;

- (void)deleteContacts;

- (LSUser *)randomUser;

- (LSUser *)registerAndAuthenticateUser:(LSUser *)user;

@property (nonatomic, strong) LSApplicationController *applicationController;

@end
