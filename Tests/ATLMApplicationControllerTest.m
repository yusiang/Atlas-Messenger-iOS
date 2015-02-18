//
//  ATLMApplicationControllerTest.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 1/20/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "KIFTestCase.h"
#import <KIF/KIF.h>
#import "KIFSystemTestActor+ViewControllerActions.h"
#import <XCTest/XCTest.h>

#import "ATLMApplicationController.h"
#import "ATLMTestInterface.h"
#import "ATLMAuthenticationViewController.h"
#import "ATLMTestUser.h"

@interface ATLMApplicationControllerTest : KIFTestCase

@property (nonatomic) ATLMTestInterface *testInterface;
@property (nonatomic) ATLMTestUser *testUser;

@end

@implementation ATLMApplicationControllerTest

- (void)setUp
{
    [super setUp];
    ATLMApplicationController *applicationController =  [(ATLMAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [ATLMTestInterface testInterfaceWithApplicationController:applicationController];
    self.testUser = [ATLMTestUser testUserWithNumber:0];
    [self.testInterface registerAndAuthenticateTestUser:self.testUser];
}

- (void)tearDown
{
    [self.testInterface logoutIfNeeded];
    [super tearDown];
}

- (void)testToVerifyApplicationGlobalResourcesOnInitialization
{
    expect(self.testInterface.applicationController.layerClient).toNot.beNil;
    expect(self.testInterface.applicationController.layerClient).to.beKindOf([LYRClient class]);
    
    expect(self.testInterface.applicationController.APIManager).toNot.beNil;
    expect(self.testInterface.applicationController.APIManager).to.beKindOf([ATLMAPIManager class]);
    
    expect(self.testInterface.applicationController.persistenceManager).toNot.beNil;
    expect(self.testInterface.applicationController.persistenceManager).to.beKindOf([ATLMPersistenceManager class]);
}

- (void)testToVerifyPushTextBooleanAcrossApplicationSessions
{
    expect(self.testInterface.applicationController.shouldSendPushText).to.beFalsy;
    [self.testInterface.applicationController setShouldSendPushText:YES];
    expect(self.testInterface.applicationController.shouldSendPushText).to.beTruthy;
    
    [self.testInterface logoutIfNeeded];
    [self.testInterface authenticateTestUser:self.testUser];
    
    expect(self.testInterface.applicationController.shouldSendPushText).to.beTruthy;
    [self.testInterface.applicationController setShouldSendPushText:NO];
    expect(self.testInterface.applicationController.shouldSendPushText).to.beFalsy;
    
    [self.testInterface logoutIfNeeded];
    [self.testInterface authenticateTestUser:self.testUser];
    expect(self.testInterface.applicationController.shouldSendPushText).to.beFalsy;
}

- (void)testToVerifyPushSoundBooleanAcrossApplicationSessions
{
    expect(self.testInterface.applicationController.shouldSendPushSound).to.beFalsy;
    [self.testInterface.applicationController setShouldSendPushSound:YES];
    expect(self.testInterface.applicationController.shouldSendPushSound).to.beTruthy;
    
    [self.testInterface logoutIfNeeded];
    [self.testInterface authenticateTestUser:self.testUser];
    
    expect(self.testInterface.applicationController.shouldSendPushSound).to.beTruthy;
    [self.testInterface.applicationController setShouldSendPushSound:NO];
    expect(self.testInterface.applicationController.shouldSendPushSound).to.beFalsy;
    
    [self.testInterface logoutIfNeeded];
    [self.testInterface authenticateTestUser:self.testUser];
    expect(self.testInterface.applicationController.shouldSendPushSound).to.beFalsy;
}

- (void)testToVerifyLoaclNotifciationBooleanAcrossApplicationSessions
{
    expect(self.testInterface.applicationController.shouldDisplayLocalNotifications).to.beFalsy;
    [self.testInterface.applicationController setShouldDisplayLocalNotifications:YES];
    expect(self.testInterface.applicationController.shouldDisplayLocalNotifications).to.beTruthy;
    
    [self.testInterface logoutIfNeeded];
    [self.testInterface authenticateTestUser:self.testUser];
    
    expect(self.testInterface.applicationController.shouldDisplayLocalNotifications).to.beTruthy;
    [self.testInterface.applicationController setShouldDisplayLocalNotifications:NO];
    expect(self.testInterface.applicationController.shouldDisplayLocalNotifications).to.beFalsy;
    
    [self.testInterface logoutIfNeeded];
    [self.testInterface authenticateTestUser:self.testUser];
    expect(self.testInterface.applicationController.shouldDisplayLocalNotifications).to.beFalsy;
}

- (void)testToVerifyDebugModeBooleanAcrossApplicationSessions
{
    expect(self.testInterface.applicationController.debugModeEnabled).to.beFalsy;
    [self.testInterface.applicationController setDebugModeEnabled:YES];
    expect(self.testInterface.applicationController.debugModeEnabled).to.beTruthy;
    
    [self.testInterface logoutIfNeeded];
    [self.testInterface authenticateTestUser:self.testUser];
    
    expect(self.testInterface.applicationController.debugModeEnabled).to.beTruthy;
    [self.testInterface.applicationController setDebugModeEnabled:NO];
    expect(self.testInterface.applicationController.debugModeEnabled).to.beFalsy;
    
    [self.testInterface logoutIfNeeded];
    [self.testInterface authenticateTestUser:self.testUser];
    expect(self.testInterface.applicationController.debugModeEnabled).to.beFalsy;
}

@end
