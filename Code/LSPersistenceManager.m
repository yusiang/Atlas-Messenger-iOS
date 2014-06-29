//
//  LSPersistenceManager.m
//  LayerSample
//
//  Created by Blake Watters on 6/28/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSPersistenceManager.h"

#define LSMustBeImplementedBySubclass() @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Must be implemented by concrete subclass." userInfo:nil]

@interface LSInMemoryPersistenceManager : LSPersistenceManager

@property (nonatomic) NSMutableSet *users;
@property (nonatomic) LSSession *session;

@end

@interface LSOnDiskPersistenceManager : LSPersistenceManager

@property (nonatomic, readonly) NSString *path;

- (id)initWithPath:(NSString *)path;

@end

@implementation LSPersistenceManager

+ (instancetype)persistenceManagerWithInMemoryStore
{
    return [LSInMemoryPersistenceManager new];
}

+ (instancetype)persistenceManagerWithStoreAtPath:(NSString *)path
{
    return [[LSOnDiskPersistenceManager alloc] initWithPath:path];
}

- (id)init
{
    if ([self isMemberOfClass:[LSPersistenceManager class]]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
    } else {
        return [super init];
    }
}

- (BOOL)persistUsers:(NSSet *)users error:(NSError **)error
{
    LSMustBeImplementedBySubclass();
}

- (NSSet *)persistedUsersWithError:(NSError **)error
{
    LSMustBeImplementedBySubclass();
}

- (void)deleteAllObjects
{
    LSMustBeImplementedBySubclass();
}

- (BOOL)persistSession:(LSSession *)session error:(NSError **)error
{
    LSMustBeImplementedBySubclass();
}

- (LSSession *)persistedSessionWithError:(NSError **)error
{
    LSMustBeImplementedBySubclass();
}

@end

@implementation LSInMemoryPersistenceManager

- (id)init
{
    self = [super init];
    if (self) {
        _users = [NSMutableSet set];
    }
    return self;
}

- (BOOL)persistUsers:(NSSet *)users error:(NSError **)error
{
    NSParameterAssert(users);
    [self.users unionSet:users];
    return YES;
}

- (NSSet *)persistedUsersWithError:(NSError **)error
{
    return self.users;
}

- (BOOL)persistSession:(LSSession *)session error:(NSError **)error
{
    self.session = session;
    return YES;
}

- (LSSession *)persistedSessionWithError:(NSError **)error
{
    return self.session;
}

- (void)deleteAllObjects
{
    [self.users removeAllObjects];
    self.session = nil;
}

@end

@implementation LSOnDiskPersistenceManager

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _path = path;
    }
    return self;
}

- (BOOL)ensureStoreExists:(NSError **)error
{
    // TODO: Make sure we have a directory at the store path and can write to it.
    return YES;
}

- (void)deleteAllObjects
{
    // TODO: Remove all files within our store directory
}

@end
