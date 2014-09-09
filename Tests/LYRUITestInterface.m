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
        
//        LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
//        [_applicationController.APIManager deleteAllContactsWithCompletion:^(BOOL completion, NSError *error) {
//            expect(completion).to.beTruthy;
//            expect(error).to.beNil;
//            [latch decrementCount];
//        }];
//        [latch waitTilCount:0];
        
    }
    return self;
}

- (NSString *)registerUser:(LSUser *)user
{
    __block NSString *userID;
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.applicationController.APIManager registerUser:user completion:^(LSUser *user, NSError *error) {
        expect(user).toNot.beNil;
        expect(error).to.beNil;
        userID = user.userID;
        [latch decrementCount];
    }];
    [latch waitTilCount:0];
    return userID;
}

- (NSString *)authenticateWithEmail:(NSString *)email password:(NSString *)password
{
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:3 timeoutInterval:10];

    __block NSString *userID;
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
                userID = authenticatedUserID;
                [latch decrementCount];
            }];
        }];
    }];

    [latch waitTilCount:0];
    return userID;
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

- (LSUser *)randomUser
{
    NSError *error;
    NSSet *users = [self.applicationController.persistenceManager persistedUsersWithError:&error];
    expect(users).toNot.beNil;
    expect(error).to.beNil;
    
    int randomNumber = arc4random_uniform((int)users.count);
    LSUser *user = [[users allObjects] objectAtIndex:randomNumber];
    while ([user.userID isEqual:self.applicationController.layerClient.authenticatedUserID]) {
        user = [self randomUser];
    }
    return user;
}

- (void)registerAndAuthenticateUser:(LSUser *)user
{
    [self registerUser:user];
    [self authenticateWithEmail:user.email password:user.password];
    [self loadContacts];
}

- (NSString *)conversationLabelForParticipants:(NSSet *)participantIDs
{
    NSMutableSet *participantIdentifiers = [NSMutableSet setWithSet:participantIDs];
    
    if ([participantIdentifiers containsObject:self.applicationController.layerClient.authenticatedUserID]) {
        [participantIdentifiers removeObject:self.applicationController.layerClient.authenticatedUserID];
    }
    
    if (!participantIdentifiers.count > 0) return @"";
    
    NSSet *participants = [self.applicationController.persistenceManager participantsForIdentifiers:participantIdentifiers];
    
    if (!participants.count > 0) return @"";
    
    LSUser *firstUser = [[participants allObjects] objectAtIndex:0];
    NSString *conversationLabel = firstUser.fullName;
    for (int i = 1; i < [[participants allObjects] count]; i++) {
        LSUser *user = [[participants allObjects] objectAtIndex:i];
        conversationLabel = [NSString stringWithFormat:@"%@, %@", conversationLabel, user.fullName];
    }
    return conversationLabel;
}

- (NSString *)selectionIndicatorAccessibilityLabelForFullName:(NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ selected", fullName];
}


@end
