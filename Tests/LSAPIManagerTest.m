//
//  LSAPIManagerTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LSAPIManager.h"
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import "LSTestUser.h"

static NSURL *LSLayerBaseURL(void)
{
    NSString *environmentHost = [NSProcessInfo processInfo].environment[@"LAYER_TEST_HOST"];
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@:7072", environmentHost]];
}

@interface LYRClient ()

- (id)initWithBaseURL:(NSURL *)baseURL appID:(NSUUID *)appID;

@end

@interface LSAPIManagerTest : XCTestCase

@end

@implementation LSAPIManagerTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRaisesOnAttempToInit
{
    expect([LSAPIManager new]).to.raise(NSInternalInconsistencyException);
}

- (void)testInitializingAPIManager
{
    expect([self testManager]).notTo.beNil();
}

- (void)testPublicPropertiesOnInitializations
{
    LSAPIManager *manager = [self testManager];
    expect(manager.authenticatedURLSessionConfiguration).to.beNil();
    expect(manager.authenticatedSession).to.beNil();
}

- (void)testRegistrationsWithInvalidCredentials
{
    
}

- (void)testRegistrationWithExistingEmail
{
    
}

- (void)testRegistrationWithValidCredentials
{
    
}

- (void)testLoginWithInvalidCredentials
{
    
}

- (void)testLoginWithValidCredentials
{
    
}

- (LSAPIManager *)testManager
{
    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-1000-8000-000000000000"];
    LYRClient *layerClient = [[LYRClient alloc] initWithBaseURL:LSLayerBaseURL() appID:appID];
    
    NSURL *url = [NSURL URLWithString:@"http://10.66.0.35:8080/"];
    return [LSAPIManager managerWithBaseURL:url layerClient:layerClient];
    
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
