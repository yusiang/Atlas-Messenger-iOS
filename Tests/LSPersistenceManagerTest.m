//
//  LSPersistenceManagerTest.m
//  LayerSample
//
//  Created by Blake Watters on 6/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import "LSPersistenceManager.h"

static NSString *LSApplicationDataDirectory(void)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
}

static NSString *LSRandomStorePath(void)
{
    return [LSApplicationDataDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
}

@interface LSPersistenceManagerTest : XCTestCase

@end

@implementation LSPersistenceManagerTest

- (void)testRaisesOnAttempToInit
{
    expect(^{ [LSPersistenceManager new]; }).to.raise(NSInternalInconsistencyException);
}

@end

@interface LSInMemoryPersistenceManagerTest : XCTestCase

@end

@implementation LSInMemoryPersistenceManagerTest

@end

@interface LSOnDiskPersistenceManagerTest : XCTestCase

@end

@implementation LSOnDiskPersistenceManagerTest

- (void)testInitializingWithEmptyDirectory
{
    LSPersistenceManager *manager = [LSPersistenceManager persistenceManagerWithStoreAtPath:LSRandomStorePath()];
    expect([manager persistedSessionWithError:nil]).to.beNil();
    expect([manager persistedUsersWithError:nil]).to.beNil();
}

- (void)testSessionPersistence
{
    LSPersistenceManager *manager = [LSPersistenceManager persistenceManagerWithStoreAtPath:LSRandomStorePath()];
    LSUser *user = [LSUser new];
    user.userID = [[NSUUID UUID] UUIDString];
    LSSession *session = [LSSession sessionWithAuthenticationToken:@"12345" user:user];
    
    NSError *error = nil;
    BOOL success = [manager persistSession:session error:&error];
    expect(success).to.beTruthy();
    expect(error).to.beNil();
    
    LSSession *loadedSession = [manager persistedSessionWithError:&error];
    expect(loadedSession).notTo.beNil();
    expect(error).to.beNil();
    expect(loadedSession.user.userID).to.equal(user.userID);
    expect(loadedSession.authenticationToken).to.equal(@"12345");
}

- (void)testLoadingNonExistantSessionFileFailsWithoutError
{
    LSPersistenceManager *manager = [LSPersistenceManager persistenceManagerWithStoreAtPath:LSRandomStorePath()];
    NSError *error = nil;
    LSSession *session = [manager persistedSessionWithError:&error];
    expect(session).to.beNil();
    expect(error).to.beNil();
}

- (void)testUsersPersistence
{
    LSPersistenceManager *manager = [LSPersistenceManager persistenceManagerWithStoreAtPath:LSRandomStorePath()];
    LSUser *user1 = [LSUser new];
    user1.userID = @"12345";
    LSUser *user2 = [LSUser new];
    user2.userID = @"5678";
    NSError *error = nil;
    NSSet *users = [NSSet setWithObjects:user1, user2, nil];
    BOOL success = [manager persistUsers:users error:&error];
    expect(success).to.beTruthy();
    expect(error).to.beNil();
    
    NSSet *loadedUsers = [manager persistedUsersWithError:&error];
    expect(loadedUsers).to.equal(users);
    expect(error).to.beNil();
}

- (void)testLoadingNonExistantUsersFileFailsWithoutError
{
    LSPersistenceManager *manager = [LSPersistenceManager persistenceManagerWithStoreAtPath:LSRandomStorePath()];
    NSError *error = nil;
    NSSet *users = [manager persistedUsersWithError:&error];
    expect(users).to.beNil();
    expect(error).to.beNil();
}

- (void)testRemovingAllObjects
{
    LSPersistenceManager *manager = [LSPersistenceManager persistenceManagerWithStoreAtPath:LSRandomStorePath()];
    LSUser *user = [LSUser new];
    user.userID = [[NSUUID UUID] UUIDString];
    LSSession *session = [LSSession sessionWithAuthenticationToken:@"12345" user:user];
    
    NSError *error = nil;
    BOOL success = [manager persistSession:session error:&error];
    expect(success).to.beTruthy();
    expect(error).to.beNil();
    
    LSUser *user1 = [LSUser new];
    user1.userID = @"12345";
    LSUser *user2 = [LSUser new];
    user2.userID = @"5678";
    NSSet *users = [NSSet setWithObjects:user1, user2, nil];
    success = [manager persistUsers:users error:&error];
    expect(success).to.beTruthy();
    expect(error).to.beNil();
    
    success = [manager deleteAllObjects:&error];
    expect(success).to.beTruthy();
    expect(error).to.beNil();
    
    // Verify the objects are gone
    session = [manager persistedSessionWithError:&error];
    expect(session).to.beNil();
    expect(error).to.beNil();
    
    users = [manager persistedUsersWithError:&error];
    expect(users).to.beNil();
    expect(error).to.beNil();
}

@end
