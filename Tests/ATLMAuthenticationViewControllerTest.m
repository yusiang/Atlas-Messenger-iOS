//
//  ATLMAuthenticationViewControllerTest.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 1/15/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "KIFTestCase.h"
#import <KIF/KIF.h>
#import "KIFSystemTestActor+ViewControllerActions.h"
#import <XCTest/XCTest.h>

#import "ATLMIApplicationController.h"
#import "ATLMTestInterface.h"
#import "ATLAuthenticationViewController.h"
#import "ATLMTestUser.h"

extern NSString *const ATLMFirstNameRowPlaceholderText;
extern NSString *const ATLMLastNameRowPlaceholderText;
extern NSString *const ATLMEmailRowPlaceholderText;
extern NSString *const ATLMPasswordRowPlaceholderText;
extern NSString *const ATLMConfirmationRowPlaceholderText;
extern NSString *const ATLMLoginButtonText;
extern NSString *const ATLMRegisterButtonText;
extern NSString *const ATLConversationListViewControllerTitle;
extern NSString *const ATLConversationTableViewTitle;

@interface ATLMAuthenticationViewControllerTest : KIFTestCase

@property (nonatomic) ATLAuthenticationViewController *authenticationViewController;
@property (nonatomic) ATLMTestInterface *testInterface;

@end

@implementation ATLMAuthenticationViewControllerTest

- (void)setUp
{
    [super setUp];
    ATLMIApplicationController *applicationController =  [(ATLMAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [ATLMTestInterface testInterfaceWithApplicationController:applicationController];
    self.authenticationViewController = (ATLAuthenticationViewController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
}

- (void)tearDown {
    
    [self.authenticationViewController resetState];
    [self.testInterface logoutIfNeeded];
    [super tearDown];
}

- (void)testToVerifyLoginUI
{
     [tester waitForViewWithAccessibilityLabel:ATLMEmailRowPlaceholderText];
     [tester waitForViewWithAccessibilityLabel:ATLMPasswordRowPlaceholderText];
     [tester waitForViewWithAccessibilityLabel:ATLMLoginButtonText];
     [tester waitForViewWithAccessibilityLabel:ATLMRegisterButtonText];
}

- (void)testToVerifyIncompleteLoginFunctionality
{
    [tester enterText:@"fakeEmail@layer.com" intoViewWithAccessibilityLabel:ATLMEmailRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:ATLMLoginButtonText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    [tester clearTextFromViewWithAccessibilityLabel:ATLMEmailRowPlaceholderText];
 
    [tester enterText:@"fakePassword" intoViewWithAccessibilityLabel:ATLMPasswordRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:ATLMLoginButtonText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
}

- (void)testToVerifyInvalidLoginCredentials
{
    [tester enterText:@"fakeEmail@layer.com" intoViewWithAccessibilityLabel:ATLMEmailRowPlaceholderText];
    [tester enterText:@"fakePassword" intoViewWithAccessibilityLabel:ATLMPasswordRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:ATLMLoginButtonText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
}

- (void)testToVerifyValidLoginFunctionality
{
    ATLMTestUser *testUser = [self.testInterface registerTestUser:[ATLMTestUser testUserWithNumber:2]];
    [tester enterText:testUser.email intoViewWithAccessibilityLabel:ATLMEmailRowPlaceholderText];
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:ATLMPasswordRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:ATLMLoginButtonText];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester waitForViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
}

- (void)testToVerifyRegistrationUI
{
    [tester tapViewWithAccessibilityLabel:ATLMRegisterButtonText];
    
    [tester waitForViewWithAccessibilityLabel:ATLMFirstNameRowPlaceholderText];
    [tester waitForViewWithAccessibilityLabel:ATLMLastNameRowPlaceholderText];
    [tester waitForViewWithAccessibilityLabel:ATLMEmailRowPlaceholderText];
    [tester waitForViewWithAccessibilityLabel:ATLMPasswordRowPlaceholderText];
    [tester waitForViewWithAccessibilityLabel:ATLMConfirmationRowPlaceholderText];
    
    [tester waitForViewWithAccessibilityLabel:ATLMRegisterButtonText];
    [tester waitForViewWithAccessibilityLabel:ATLMLoginButtonText];
}

- (void)testToVerifyIncompleteRegistrationFunctionality
{
    [tester tapViewWithAccessibilityLabel:ATLMRegisterButtonText];
    
    ATLMTestUser *testUser = [ATLMTestUser testUserWithNumber:0];
    [tester enterText:testUser.firstName intoViewWithAccessibilityLabel:ATLMFirstNameRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:ATLMRegisterButtonText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    [tester enterText:testUser.lastName intoViewWithAccessibilityLabel:ATLMLastNameRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:ATLMRegisterButtonText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    [tester enterText:testUser.email intoViewWithAccessibilityLabel:ATLMEmailRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:ATLMRegisterButtonText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:ATLMPasswordRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:ATLMRegisterButtonText];
    [tester waitForViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    [tester enterText:testUser.passwordConfirmation intoViewWithAccessibilityLabel:ATLMConfirmationRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:ATLMRegisterButtonText];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Unexpected Error"];
    [tester waitForViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
}

- (void)testToVerifyValidRegistrationFunctionality
{
    [tester tapViewWithAccessibilityLabel:ATLMRegisterButtonText];
    
    ATLMTestUser *testUser = [ATLMTestUser testUserWithNumber:0];
    [tester enterText:testUser.firstName intoViewWithAccessibilityLabel:ATLMFirstNameRowPlaceholderText];
    [tester enterText:testUser.lastName intoViewWithAccessibilityLabel:ATLMLastNameRowPlaceholderText];
    [tester enterText:testUser.email intoViewWithAccessibilityLabel:ATLMEmailRowPlaceholderText];
    [tester enterText:testUser.password intoViewWithAccessibilityLabel:ATLMPasswordRowPlaceholderText];
    [tester enterText:testUser.passwordConfirmation intoViewWithAccessibilityLabel:ATLMConfirmationRowPlaceholderText];
    [tester tapViewWithAccessibilityLabel:ATLMRegisterButtonText];
    [tester waitForViewWithAccessibilityLabel:ATLConversationListViewControllerTitle];
}

@end
