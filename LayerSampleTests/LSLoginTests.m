//
//  LSLoginTests.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/11/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSLoginTests.h"
#import "KIFUITestActor+LSAdditions.h"
#import "LSRegistrationTableViewController.h"
#import "LSLoginTableViewController.h"
#import "LSConversationListViewController.h"
#import "LSConversationViewController.h"
#import "LSHomeViewController.h"
#import "LYRSampleConversation.h"
#import "LYRSampleMessage.h"


@implementation LSLoginTests

- (void)beforeEach
{
    //[tester navigateToLoginPage];
}

- (void)afterEach
{
    //[tester returnToLoggedOutHomeScreen];
}

- (void)testToVerifySendButtonFunctionality
{
    [system presentViewControllerWithClass:[LSConversationViewController class] withinNavigationControllerWithNavigationBarClass:nil toolbarClass:nil configurationBlock:^(id viewController) {
        
    }];
    [tester tapViewWithAccessibilityLabel:@"Compose TextView"];
    [tester waitForViewWithAccessibilityLabel:@"E"];
    [tester enterText:@"This is a test!" intoViewWithAccessibilityLabel:@"Compose TextView"];
    [tester tapViewWithAccessibilityLabel:@"Button"];
}

- (void)testToVerifyTappingOnConversationCellFunctionality
{
    [system presentViewControllerWithClass:[LSConversationListViewController class] withinNavigationControllerWithNavigationBarClass:nil toolbarClass:nil configurationBlock:^(id viewController) {
        
    }];
    [tester tapViewWithAccessibilityLabel:@"Conversation Cell"];
    [tester waitForViewWithAccessibilityLabel:@"Conversation List"];
}

- (void) testNonMatchingPasswordRegistrationError
{
    [system presentViewControllerWithClass:[LSRegistrationTableViewController class] withinNavigationControllerWithNavigationBarClass:nil toolbarClass:nil configurationBlock:^(id viewController) {
        
    }];
    [tester enterText:@"tester@layer.com" intoViewWithAccessibilityLabel:@"Username"];
    [tester enterText:@"password" intoViewWithAccessibilityLabel:@"Password"];
    [tester enterText:@"password1" intoViewWithAccessibilityLabel:@"Confirm"];
    [tester tapViewWithAccessibilityLabel:@"Register"];
}

- (void) testRegistrationFunctionality
{
    [system presentViewControllerWithClass:[LSRegistrationTableViewController class] withinNavigationControllerWithNavigationBarClass:nil toolbarClass:nil configurationBlock:^(id viewController) {
        
    }];
    [tester enterText:@"tester@layer.com" intoViewWithAccessibilityLabel:@"Username"];
    [tester enterText:@"password" intoViewWithAccessibilityLabel:@"Password"];
    [tester enterText:@"password" intoViewWithAccessibilityLabel:@"Confirm"];
    [tester tapViewWithAccessibilityLabel:@"Register"];
    
    [tester waitForViewWithAccessibilityLabel:@"Sender Label"];
}

- (void) testLoginFunctionality
{
    [system presentViewControllerWithClass:[LSLoginTableViewController class] withinNavigationControllerWithNavigationBarClass:nil toolbarClass:nil configurationBlock:^(id viewController) {

    }];
    [tester enterText:@"tester@layer.com" intoViewWithAccessibilityLabel:@"Username"];
    [tester enterText:@"Password" intoViewWithAccessibilityLabel:@"Password"];
    [tester tapViewWithAccessibilityLabel:@"Login"];
    [tester waitForViewWithAccessibilityLabel:@"Sender Label"];
}

- (void)testRegisterButton
{
    [system presentViewControllerWithClass:[LSHomeViewController class] withinNavigationControllerWithNavigationBarClass:nil toolbarClass:nil configurationBlock:^(id viewController) {
        
    }];
    [tester tapViewWithAccessibilityLabel:@"Register"];
    [tester waitForTappableViewWithAccessibilityLabel:@"Username"];
    [tester tapViewWithAccessibilityLabel:@"Back"];
}

- (void)testLoginButton
{
    [system presentViewControllerWithClass:[LSHomeViewController class] withinNavigationControllerWithNavigationBarClass:nil toolbarClass:nil configurationBlock:^(id viewController) {
        
    }];
    [tester tapViewWithAccessibilityLabel:@"Login"];
    [tester waitForTappableViewWithAccessibilityLabel:@"Username"];
    [tester tapViewWithAccessibilityLabel:@"Back"];
}




@end
