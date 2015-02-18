//
//  ATLTestInterface.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 9/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "ATLMApplicationController.h"
#import "ATLMLayerContentFactory.h"
#import "ATLMAppDelegate.h"
#import "ATLMTestUser.h"

// Testing Imports
#import <OCMock/OCMock.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import "LYRCountDownLatch.h"
#import "KIFTestCase.h"
#import <KIF/KIF.h>
#import "KIFSystemTestActor+ViewControllerActions.h"
#import "ATLMUtilities.h"

@interface ATLMTestInterface : NSObject

+ (instancetype)testInterfaceWithApplicationController:(ATLMApplicationController *)applicationController;

@property (nonatomic) ATLMApplicationController *applicationController;

@property (nonatomic) ATLMEnvironment testEnvironment;

@property ATLMLayerContentFactory *contentFactory;

//-------------------------------------
// Layer Client Authentication Methods
//-------------------------------------

- (LYRClient *)authenticateLayerClient:(LYRClient *)layerClient withTestUser:(ATLMTestUser *)testUser;

//-------------------------------
// Authentication Methods
//-------------------------------

- (ATLMTestUser *)registerAndAuthenticateTestUser:(ATLMTestUser *)testUser;

- (ATLMTestUser *)registerTestUser:(ATLMTestUser *)testUser;

- (NSString *)authenticateTestUser:(ATLMTestUser *)testUser;

- (void)logoutIfNeeded;

//-------------------------------
// Participant Management Methods
//-------------------------------

- (void)loadContacts;

- (NSSet *)fetchContacts;

- (void)deleteContacts;

- (ATLMUser *)randomUser;

- (ATLMUser *)userForIdentifier:(NSString *)identifier;

//-------------------------------
// Accessibility Label Methods
//-------------------------------

- (NSString *)conversationLabelForParticipants:(NSSet *)participantIDs;

- (NSString *)selectionIndicatorAccessibilityLabelForUser:(ATLMUser *)testUser;

@end
