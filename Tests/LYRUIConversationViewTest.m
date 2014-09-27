//
//  LYRUIConversationViewTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/16/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LSApplicationController.h"
#import "LYRUITestInterface.h"
#import "LYRUILayerContentFactory.h"
#import "LSAppDelegate.h"
#import "LYRUITestUser.h"
#import "LYRUIConversationViewController.h"

@interface LYRUIConversationViewTest : XCTestCase

@property (nonatomic) LYRUITestInterface *testInterface;
@property (nonatomic) LYRUILayerContentFactory *layerContentFactory;

@end

@implementation LYRUIConversationViewTest

- (void)setUp
{
    [super setUp];
    
    LSApplicationController *applicationController =  [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
    self.testInterface = [LYRUITestInterface testInterfaceWithApplicationController:applicationController];
    self.layerContentFactory = [LYRUILayerContentFactory layerContentFactoryWithLayerClient:applicationController.layerClient];
    [self.testInterface deleteContacts];
}

- (void)tearDown
{
    [self.testInterface deleteContacts];
    [self.testInterface logout];
    
    self.testInterface = nil;
    
    [super tearDown];
}

//
////Send a new message a verify it appears in the view.
//- (void)testToVerifySentMessageAppearsInConversationView
//{
//    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:1]];
//  
//    LSUser *user1 = [self.testInterface randomUser];
//
//    LYRConversation *conversation = [LYRConversation conversationWithParticipants:[NSSet setWithArray:@[user1.userID]]];
//    LYRUIConversationViewController *controller = [LYRUIConversationViewController conversationViewControllerWithConversation:conversation layerClient:self.testInterface.applicationController.layerClient];
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
//    [system presentModalViewController:navigationController configurationBlock:^(id viewController) {
//        [self sendMessageWithText:@"This is a test"];
//    }];
//}
//
////Synchronize a new message and verify it appears in the view.
//- (void)testToVerifyRecievedMessageAppearsInConversationView
//{
//
//}
//
////Receive a transport push for a new message and verify that it appears in the view.
//- (void)testToVerifyTransportPushCausesNewMessageToAppearInView
//{
//    
//}
//
////Add an image to a message and verify that it sends.
//- (void)testToVerifySentImageAppearsInConversationView
//{
//    
//}
//
////Add a video to a message and verify that it sends.
//- (void)testToVerifySentVideoAppearsInConversationView
//{
//    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:1]];
//    
//    LSUser *user1 = [self.testInterface randomUser];
//    
//    LYRConversation *conversation = [LYRConversation conversationWithParticipants:[NSSet setWithArray:@[user1.userID]]];
//    LYRUIConversationViewController *controller = [LYRUIConversationViewController conversationViewControllerWithConversation:conversation layerClient:self.testInterface.applicationController.layerClient];
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
//    [system presentModalViewController:navigationController configurationBlock:^(id viewController) {
//        [self sendPhotoMessage];
//    }];
//}
//
////Verify that the "Send" button is not enabled until there is content (text, audio, or video) in the message composition field.
//- (void)testToVerifyThatSendButtonIsNotEnabledUntilContentIsInput
//{
//    
//}
//
//- (void)sendMessageWithText:(NSString *)messageText
//{
//    [tester enterText:messageText intoViewWithAccessibilityLabel:@"Text Input View"];
//    [tester tapViewWithAccessibilityLabel:@"Send Button"];
//    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Message: %@", messageText]];
//}
//
//- (void)sendPhotoMessage
//{
//    [tester tapViewWithAccessibilityLabel:@"Camera Button"];
//    [tester tapViewWithAccessibilityLabel:@"Choose Existing"];
//    [tester tapViewWithAccessibilityLabel:@"Photo, Landscape, 10:59 AM"];
//    [tester tapViewWithAccessibilityLabel:@"Send Button"];
//    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Message: Photo"]];
//}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
