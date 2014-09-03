//
//  LYRUITestInterface.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUITestInterface.h"

@implementation LYRUITestInterface

+ (instancetype)testInterfaceWithApplicationController:(LSApplicationController *)applicationController
{
    return [[self alloc] initWithApplicationController:applicationController];
}

- (id)initWithApplicationController:(LSApplicationController *)applicationController
{
    self = [super init];
    if (self) {
        
        _applicationController = applicationController;
        
        LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
        [_applicationController.APIManager deleteAllContactsWithCompletion:^(BOOL completion, NSError *error) {
            expect(completion).to.beTruthy;
            expect(error).to.beNil;
            [latch decrementCount];
        }];
        [latch waitTilCount:0];
        
    }
    return self;
}

- (void)registerUser:(LSUser *)user
{
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.applicationController.APIManager registerUser:user completion:^(LSUser *user, NSError *error) {
        expect(user).toNot.beNil;
        expect(error).to.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (void)authenticateWithEmail:(NSString *)email password:(NSString *)password
{
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:3 timeoutInterval:10];

    [self.applicationController.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        expect(nonce).toNot.beNil;
        expect(error).to.beNil;
        [latch decrementCount];
        [self.applicationController.APIManager authenticateWithEmail:email password:password nonce:nonce completion:^(NSString *identityToken, NSError *error) {
            expect(identityToken).toNot.beNil;
            expect(error).to.beNil;
            [latch decrementCount];
            [self.applicationController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                expect(authenticatedUserID).toNot.beNil;
                expect(error).to.beNil;
                [latch decrementCount];
            }];
        }];
    }];
    [latch waitTilCount:0];
}

- (void)logout
{
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.applicationController.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        expect(success).to.beTruthy;
        expect(error).to.beNil;
        [self.applicationController.APIManager deauthenticate];
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (void)loadContacts
{
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.applicationController.APIManager loadContactsWithCompletion:^(NSSet *contacts, NSError *error) {
        expect(contacts).toNot.beNil;
        expect(error).to.beNil;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
}

- (NSSet *)fetchContacts
{
    NSError *error;
    NSSet *persistedUsers = [self.applicationController.persistenceManager persistedUsersWithError:&error];
    expect(error).to.beNil;
    expect(persistedUsers).toNot.beNil;
    return persistedUsers;
}

- (void)deleteContacts
{
    NSError *error;
    BOOL success = [self.applicationController.persistenceManager deleteAllObjects:&error];
    expect(error).to.beNil;
    expect(success).to.beTruthy;
}

@end
