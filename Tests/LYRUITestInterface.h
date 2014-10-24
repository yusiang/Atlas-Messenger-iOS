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
#import <KIF/KIF.h>
#import "KIFSystemTestActor+ViewControllerActions.h"

@interface LYRUITestInterface : NSObject

+ (instancetype)testInterfaceWithApplicationController:(LSApplicationController *)applicationController;

//-------------------------------
// Authentication Methods
//-------------------------------

- (LSUser *)registerUser:(LSUser *)newUser;

- (NSString *)authenticateWithEmail:(NSString *)email password:(NSString *)password;

- (NSString *)registerAndAuthenticateUser:(LSUser *)user;

- (void)logout;

//-------------------------------
// Participant Management Methods
//-------------------------------

- (void)registerTestUsers;

- (void)loadContacts;

- (NSSet *)fetchContacts;

- (void)deleteContacts;

@property (nonatomic) LSUser *testUser0;
@property (nonatomic) LSUser *testUser1;
@property (nonatomic) LSUser *testUser2;
@property (nonatomic) LSUser *testUser3;
@property (nonatomic) LSUser *testUser4;

- (LSUser *)randomUser;

//-------------------------------
// Accessibility Label Methods
//-------------------------------

- (NSString *)conversationLabelForParticipants:(NSSet *)participantIDs;

- (NSString *)selectionIndicatorAccessibilityLabelForUser:(LSUser *)testUser;

@property (nonatomic) LSApplicationController *applicationController;

@end
