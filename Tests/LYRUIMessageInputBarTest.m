//
//  LYRUIMessageInputBarTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/24/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import "LSApplicationController.h"
#import "LYRUITestInterface.h"
#import "LYRUILayerContentFactory.h"
#import "LSAppDelegate.h"
#import "LYRUITestUser.h"
#import "LYRUIConversationViewController.h"
#import "LYRUIMessageInputToolbar.h"
#import "LYRUIMessageComposeTextView.h"
#import "LYRUIMessageInputToolBarTestViewController.h"

@interface LYRUIMessageInputBarTest : XCTestCase

@property (nonatomic) LYRUITestInterface *testInterface;
@property (nonatomic) LYRUILayerContentFactory *layerContentFactory;
@property (nonatomic) LYRUIMessageInputToolBarTestViewController *viewController;

@end

@implementation LYRUIMessageInputBarTest

static NSString *const LSTextInputViewLabel = @"Text Input View";
static NSString *const LSSendButtonLabel = @"Send Button";
static NSString *const LSCameraButtonLabel = @"Camera Button";

- (void)setUp
{
    [super setUp];
    
    self.viewController = [[LYRUIMessageInputToolBarTestViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    [[[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:navController animated:YES completion:nil];
}

- (void)tearDown
{
    [[[[UIApplication sharedApplication] delegate] window].rootViewController dismissViewControllerAnimated:YES completion:nil];
    [super tearDown];
}

- (void)testToVerifyMessageEnteredIsConsitentWithMessageToBeSent
{
    id delegateMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
    self.viewController.toolBar.inputToolBarDelegate = delegateMock;
    
    __block NSString *testText = @"This is a test";
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSArray *parts = self.viewController.toolBar.messageParts;
        expect(parts.count).to.equal(1);
        expect([parts objectAtIndex:0]).to.equal(testText);
    }] messageInputToolbar:self.viewController.toolBar didTapRightAccessoryButton:[OCMArg any]];
    
    [tester enterText:testText intoViewWithAccessibilityLabel:LSTextInputViewLabel];
    [tester tapViewWithAccessibilityLabel:LSSendButtonLabel];
    [delegateMock verify];
}

- (void)testToVerifyEmptyStringEnteredDoesNotInvokeDelegate
{
    //////////////NOT YET WORKING////////////////////
    
    id protocolMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
    self.viewController.toolBar.delegate = protocolMock;

    [[protocolMock reject] messageInputToolbar:self.viewController.toolBar didTapRightAccessoryButton:[OCMArg any]];
    [protocolMock verify];
    __block NSString *testText = @"This is a test";
    [tester enterText:testText intoViewWithAccessibilityLabel:LSTextInputViewLabel];
    [tester tapViewWithAccessibilityLabel:@"Camera Button"];
}

- (void)testToVerifySendingMessageWithPhoto
{
    id delegateMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
    self.viewController.toolBar.inputToolBarDelegate = delegateMock;
    
    __block NSString *testText = @"This is a test";
    __block UIImage *testImage = [UIImage imageNamed:@"testImage"];
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSArray *parts = self.viewController.toolBar.messageParts;
        expect(parts.count).to.equal(2);
        expect([parts objectAtIndex:0]).to.equal(testText);
        expect([parts objectAtIndex:1]).to.equal(testImage);
    }] messageInputToolbar:self.viewController.toolBar didTapRightAccessoryButton:[OCMArg any]];
    
    [tester enterText:testText intoViewWithAccessibilityLabel:LSTextInputViewLabel];
    [self.viewController.toolBar insertImage:testImage];
    [tester tapViewWithAccessibilityLabel:LSSendButtonLabel];
    [delegateMock verify];
}

- (void)testToVerifySendingMessageWithPhotoWithMessage
{
    id delegateMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
    self.viewController.toolBar.inputToolBarDelegate = delegateMock;
    
    __block NSString *testText = @"This is a test";
    __block NSString *giftText = @"This is a Gift";
    __block UIImage *testImage = [UIImage imageNamed:@"testImage"];
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSArray *parts = self.viewController.toolBar.messageParts;
        expect(parts.count).to.equal(3);
        expect([parts objectAtIndex:0]).to.equal(testText);
        expect([parts objectAtIndex:1]).to.equal(testImage);
        expect([parts objectAtIndex:2]).to.equal(giftText);
    }] messageInputToolbar:self.viewController.toolBar didTapRightAccessoryButton:[OCMArg any]];
    
    [tester enterText:testText intoViewWithAccessibilityLabel:LSTextInputViewLabel];
    [self.viewController.toolBar insertImage:testImage];
    [tester enterText:giftText intoViewWithAccessibilityLabel:LSTextInputViewLabel];
    [tester tapViewWithAccessibilityLabel:LSSendButtonLabel];
    [delegateMock verify];
}

- (void)testToVerifySending2LinesOfTextWith2Photos
{
    id delegateMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
    self.viewController.toolBar.inputToolBarDelegate = delegateMock;
    
    __block NSString *testText = @"This is a test";
    __block NSString *giftText = @"This is a Gift";
    __block UIImage *testImage = [UIImage imageNamed:@"testImage"];
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSArray *parts = self.viewController.toolBar.messageParts;
        expect(parts.count).to.equal(3);
        expect([parts objectAtIndex:0]).to.equal(testText);
        expect([parts objectAtIndex:1]).to.equal(testImage);
        expect([parts objectAtIndex:2]).to.equal(giftText);
        expect([parts objectAtIndex:1]).to.equal(testImage);
    }] messageInputToolbar:self.viewController.toolBar didTapRightAccessoryButton:[OCMArg any]];
    
    [tester enterText:testText intoViewWithAccessibilityLabel:LSTextInputViewLabel];
    [self.viewController.toolBar insertImage:testImage];
    [tester enterText:giftText intoViewWithAccessibilityLabel:LSTextInputViewLabel];
    [self.viewController.toolBar insertImage:testImage];
    [tester tapViewWithAccessibilityLabel:LSSendButtonLabel];
    [delegateMock verify];
}

- (void)testToVerifySending5Photos
{
    id delegateMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
    self.viewController.toolBar.inputToolBarDelegate = delegateMock;

    __block UIImage *testImage = [UIImage imageNamed:@"testImage"];
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSArray *parts = self.viewController.toolBar.messageParts;
        expect(parts.count).to.equal(5);
        expect([parts objectAtIndex:0]).to.equal(testImage);
        expect([parts objectAtIndex:1]).to.equal(testImage);
        expect([parts objectAtIndex:2]).to.equal(testImage);
        expect([parts objectAtIndex:3]).to.equal(testImage);
        expect([parts objectAtIndex:4]).to.equal(testImage);
    }] messageInputToolbar:self.viewController.toolBar didTapRightAccessoryButton:[OCMArg any]];
    
    [self.viewController.toolBar insertImage:testImage];
    [self.viewController.toolBar insertImage:testImage];
    [self.viewController.toolBar insertImage:testImage];
    [self.viewController.toolBar insertImage:testImage];
    [self.viewController.toolBar insertImage:testImage];
    [tester tapViewWithAccessibilityLabel:LSSendButtonLabel];
    [delegateMock verify];
}

- (void)testToVerifyHeightOfInputBarIsCapped
{
    CGFloat toolbarHeight = self.viewController.toolBar.frame.size.height;
    CGFloat toolbarNewHeight;
    self.viewController.toolBar.maxNumberOfLines = 3;
    
    [tester tapViewWithAccessibilityLabel:LSTextInputViewLabel];
    [tester tapViewWithAccessibilityLabel:@"RETURN"];
    toolbarNewHeight = self.viewController.toolBar.frame.size.height;
    expect(toolbarNewHeight).to.beGreaterThan(toolbarHeight);
    toolbarHeight = self.viewController.toolBar.frame.size.height;
    
    [tester tapViewWithAccessibilityLabel:@"RETURN"];
    toolbarNewHeight = self.viewController.toolBar.frame.size.height;
    expect(toolbarNewHeight).to.beGreaterThan(toolbarHeight);
    toolbarHeight = self.viewController.toolBar.frame.size.height;
    
    [tester tapViewWithAccessibilityLabel:@"RETURN"];
    toolbarNewHeight = self.viewController.toolBar.frame.size.height;
    expect(toolbarNewHeight).to.equal(toolbarHeight);
    toolbarHeight = self.viewController.toolBar.frame.size.height;
    
    [tester tapViewWithAccessibilityLabel:@"RETURN"];
    toolbarNewHeight = self.viewController.toolBar.frame.size.height;
    expect(toolbarNewHeight).to.equal(toolbarHeight);
}

- (void)testToVerifySelectingAndRemovingAnImageKeepsFontConsistent
{
    
}

- (void)testToVerifyFontIsConsistentAfterEnteringAnImage
{
    
}


- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}


@end
