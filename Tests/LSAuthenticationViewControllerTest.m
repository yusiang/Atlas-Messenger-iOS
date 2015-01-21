//
//  LSAuthenticationViewControllerTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 1/15/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "KIFTestCase.h"
#import <KIF/KIF.h>
#import "KIFSystemTestActor+ViewControllerActions.h"
#import <XCTest/XCTest.h>

#import "LSApplicationController.h"
#import "LSTestInterface.h"
#import "LSAuthenticationViewController.h"
#import "LSTestUser.h"

extern NSString *const LSFirstNameRowPlaceholderText;
extern NSString *const LSLastNameRowPlaceholderText;
extern NSString *const LSEmailRowPlaceholderText;
extern NSString *const LSPasswordRowPlaceholderText;
extern NSString *const LSConfirmationRowPlaceholderText;
extern NSString *const LSLoginButtonText;
extern NSString *const LSRegisterButtonText;
extern NSString *const LYRUIConversationListViewControllerTitle;
extern NSString *const LYRUIConversationTableViewTitle;

@interface LSAuthenticationViewControllerTest : KIFTestCase

@property (nonatomic) LSAuthenticationViewController *authenticationViewController;
@property (nonatomic) LSTestInterface *testInterface;

@end

@implementation LSAuthenticationViewControllerTest

- (void)setUp
{
    [super setUp];
    LSApplicationController *applicationController =  [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [LSTestInterface testInterfaceWithApplicationController:applicationController];
    self.authenticationViewController = (LSAuthenticationViewController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
}

- (void)tearDown {
    
    [self.authenticationViewController resetState];
    [self.testInterface logoutIfNeeded];
    [super tearDown];
}

- (void)testToVerifyLoginUI
{
     [tester waitForViewWithAccessibilityLabel:LSEmailRowPlaceholderText];
     [tester waitForViewWithAccessibilityLabel:LSPasswordRowPlaceholderText];
     [tester waitForViewWithAccessibilityLabel:LSLoginButtonText];
     [tester waitForViewWithAccessibilityLabel:LSRegisterButtonText];
}

- (void)testToVerifyIncompleteLoginFunctionality
{
    [tester enterText:@"fakeEmail@layer.com" intoViewWithAccessibilityLabel:LSEmailRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:LSLoginButtonText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    [tester clearTextFromViewWithAccessibilityLabel:LSEmailRowPlaceholderText];
 
    [tester enterText:@"fakePassword" intoViewWithAccessibilityLabel:LSPasswordRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:LSLoginButtonText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
}

- (void)testToVerifyInvalidLoginCredentials
{
    [tester enterText:@"fakeEmail@layer.com" intoViewWithAccessibilityLabel:LSEmailRowPlaceholderText];
    [tester enterText:@"fakePassword" intoViewWithAccessibilityLabel:LSPasswordRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:LSLoginButtonText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
}

- (void)testToVerifyValidLoginFunctionality
{
    LSTestUser *testUser = [self.testInterface registerTestUser:[LSTestUser testUserWithNumber:2]];
    [tester enterText:testUser.email intoViewWithAccessibilityLabel:LSEmailRowPlaceholderText];
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:LSPasswordRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:LSLoginButtonText];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester waitForViewWithAccessibilityLabel:LYRUIConversationListViewControllerTitle];
}

- (void)testToVerifyRegistrationUI
{
    [tester tapViewWithAccessibilityLabel:LSRegisterButtonText];
    
    [tester waitForViewWithAccessibilityLabel:LSFirstNameRowPlaceholderText];
    [tester waitForViewWithAccessibilityLabel:LSLastNameRowPlaceholderText];
    [tester waitForViewWithAccessibilityLabel:LSEmailRowPlaceholderText];
    [tester waitForViewWithAccessibilityLabel:LSPasswordRowPlaceholderText];
    [tester waitForViewWithAccessibilityLabel:LSConfirmationRowPlaceholderText];
    
    [tester waitForViewWithAccessibilityLabel:LSRegisterButtonText];
    [tester waitForViewWithAccessibilityLabel:LSLoginButtonText];
}

- (void)testToVerifyIncompleteRegistrationFunctionality
{
    [tester tapViewWithAccessibilityLabel:LSRegisterButtonText];
    
    LSTestUser *testUser = [LSTestUser testUserWithNumber:0];
    [tester enterText:testUser.firstName intoViewWithAccessibilityLabel:LSFirstNameRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:LSRegisterButtonText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    [tester enterText:testUser.lastName intoViewWithAccessibilityLabel:LSLastNameRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:LSRegisterButtonText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    [tester enterText:testUser.email intoViewWithAccessibilityLabel:LSEmailRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:LSRegisterButtonText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:LSPasswordRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:LSRegisterButtonText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    [tester enterText:testUser.passwordConfirmation intoViewWithAccessibilityLabel:LSConfirmationRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:LSRegisterButtonText];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester waitForViewWithAccessibilityLabel:LYRUIConversationListViewControllerTitle];
}

- (void)testToVerifyValidRegistrationFunctionality
{
    [tester tapViewWithAccessibilityLabel:LSRegisterButtonText];
    
    LSTestUser *testUser = [LSTestUser testUserWithNumber:0];
    [tester enterText:testUser.firstName intoViewWithAccessibilityLabel:LSFirstNameRowPlaceholderText];
    [tester enterText:testUser.lastName intoViewWithAccessibilityLabel:LSLastNameRowPlaceholderText];
    [tester enterText:testUser.email intoViewWithAccessibilityLabel:LSEmailRowPlaceholderText];
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:LSPasswordRowPlaceholderText];
    [tester enterText:testUser.passwordConfirmation intoViewWithAccessibilityLabel:LSConfirmationRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:LSRegisterButtonText];
    [tester waitForViewWithAccessibilityLabel:LYRUIConversationListViewControllerTitle];
}

@end
