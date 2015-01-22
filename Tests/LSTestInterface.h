//
//  LYRUITestInterface.h
//  LayerSample
//
//  Created by Kevin Coleman on 9/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "LSApplicationController.h"
#import "LSLayerContentFactory.h"
#import "LSAppDelegate.h"
#import "LSTestUser.h"

// Testing Imports
#import <OCMock/OCMock.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import "LYRCountDownLatch.h"
#import "KIFTestCase.h"
#import <KIF/KIF.h>
#import "KIFSystemTestActor+ViewControllerActions.h"
#import "LSUtilities.h"

@interface LSTestInterface : NSObject

+ (instancetype)testInterfaceWithApplicationController:(LSApplicationController *)applicationController;

@property (nonatomic) LSApplicationController *applicationController;

@property (nonatomic) LSEnvironment testEnvironment;

@property LSLayerContentFactory *contentFactory;

//-------------------------------------
// Layer Client Authentication Methods
//-------------------------------------

- (LYRClient *)authenticateLayerClient:(LYRClient *)layerClient withTestUser:(LSTestUser *)testUser;

//-------------------------------
// Authentication Methods
//-------------------------------

- (LSTestUser *)registerAndAuthenticateTestUser:(LSTestUser *)testUser;

- (LSTestUser *)registerTestUser:(LSTestUser *)testUser;

- (NSString *)authenticateTestUser:(LSTestUser *)testUser;

- (void)logoutIfNeeded;

//-------------------------------
// Participant Management Methods
//-------------------------------

- (void)loadContacts;

- (NSSet *)fetchContacts;

- (void)deleteContacts;

- (LSUser *)randomUser;

- (LSUser *)userForIdentifier:(NSString *)identifier;

//-------------------------------
// Accessibility Label Methods
//-------------------------------

- (NSString *)conversationLabelForParticipants:(NSSet *)participantIDs;

- (NSString *)selectionIndicatorAccessibilityLabelForUser:(LSUser *)testUser;

@end
