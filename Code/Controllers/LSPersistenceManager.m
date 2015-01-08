//
//  LSPersistenceManager.m
//  LayerSample
//
//  Created by Blake Watters on 6/28/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSPersistenceManager.h"

#define LSMustBeImplementedBySubclass() @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Must be implemented by concrete subclass." userInfo:nil]

@interface LSPersistenceManager ()

@property (nonatomic) NSSet *users;
@property (nonatomic) LSSession *session;

@end

@interface LSInMemoryPersistenceManager : LSPersistenceManager

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

- (BOOL)deleteAllObjects:(NSError **)error
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

- (void)performUserSearchWithString:(NSString *)searchString completion:(void(^)(NSArray *users, NSError *error))completion
{
    LSMustBeImplementedBySubclass();
}

- (NSSet *)usersForIdentifiers:(NSSet *)identifiers
{
    LSMustBeImplementedBySubclass();
}

- (NSPredicate *)predicateForUsersWithSearchString:(NSString *)searchString
{
    NSString *escapedSearchString = [NSRegularExpression escapedPatternForString:searchString];
    NSString *searchPattern = [NSString stringWithFormat:@".*\\b%@.*", escapedSearchString];
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"fullName MATCHES[cd] %@", searchPattern];
    return searchPredicate;
}

@end

@implementation LSInMemoryPersistenceManager

- (BOOL)persistUsers:(NSSet *)users error:(NSError **)error
{
    NSParameterAssert(users);
    self.users = users;
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

- (BOOL)deleteAllObjects:(NSError **)error
{
    self.users = nil;
    self.session = nil;
    return YES;
}

- (void)performUserSearchWithString:(NSString *)searchString completion:(void(^)(NSArray *users, NSError *error))completion
{
    NSPredicate *searchPredicate = [self predicateForUsersWithSearchString:searchString];
    completion([self.users filteredSetUsingPredicate:searchPredicate].allObjects, nil);
}

- (NSSet *)usersForIdentifiers:(NSSet *)identifiers
{
    NSMutableSet *users = [[NSMutableSet alloc] init];
    
    for (NSString *userIdentifier in identifiers) {
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(userID like[cd] %@)", [NSString stringWithFormat:@"*%@*", userIdentifier]];
        NSSet * set = [self.users filteredSetUsingPredicate:searchPredicate];
        if ([set allObjects].count > 0) {
            [users addObject:[[set allObjects] firstObject]];
        }
    }
    return [NSSet setWithSet:users];
}

@end

@implementation LSOnDiskPersistenceManager

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _path = path;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDirectory;
        if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (!isDirectory) {
                [NSException raise:NSInternalInconsistencyException format:@"Failed to initialize persistent store at '%@': specified path is a regular file.", path];
            }
        } else {
            NSError *error;
            BOOL success = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
            if (!success) {
                [NSException raise:NSInternalInconsistencyException format:@"Failed creating persistent store at '%@': %@", path, error];
            }
        }
    }
    return self;
}

- (BOOL)persistUsers:(NSSet *)users error:(NSError **)error
{
    NSString *path = [self.path stringByAppendingPathComponent:@"Users.plist"];
    self.users = users;
    return [NSKeyedArchiver archiveRootObject:users toFile:path];
}

- (NSSet *)persistedUsersWithError:(NSError **)error
{
    if (self.users) {
        return self.users;
    }
    
    NSString *path = [self.path stringByAppendingPathComponent:@"Users.plist"];
    NSSet *users = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    self.users = users;
    return users;
}

- (BOOL)deleteAllObjects:(NSError **)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *subpaths = [fileManager contentsOfDirectoryAtPath:self.path error:error];
    if (!subpaths) {
        return NO;
    }
    
    for (NSString *subpath in subpaths) {
        if ([[subpath pathExtension] isEqualToString:@"plist"]) {
            if (![fileManager removeItemAtPath:[self.path stringByAppendingPathComponent:subpath] error:error]) {
                return NO;
            }
        }
    }
    
    self.users = nil;
    self.session = nil;
    
    return YES;
}

- (BOOL)persistSession:(LSSession *)session error:(NSError **)error
{
    NSString *path = [self.path stringByAppendingPathComponent:@"Session.plist"];
    self.session = session;
    return [NSKeyedArchiver archiveRootObject:session toFile:path];
}

- (LSSession *)persistedSessionWithError:(NSError **)error
{
    if (self.session) {
        return self.session;
    }
    
    NSString *path = [self.path stringByAppendingPathComponent:@"Session.plist"];
    LSSession *session = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    self.session = session;
    
    return session;
}

- (void)performUserSearchWithString:(NSString *)searchString completion:(void (^)(NSArray *users, NSError *error))completion
{
    NSError *error;
    NSSet *users = [self persistedUsersWithError:&error];
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, nil);
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSPredicate *searchPredicate = [self predicateForUsersWithSearchString:searchString];
            completion([users filteredSetUsingPredicate:searchPredicate].allObjects, nil);
        });
    }
}

- (NSSet *)usersForIdentifiers:(NSSet *)identifiers;
{
    NSSet *users;
    NSError *error;
    NSSet *allUsers = [self persistedUsersWithError:&error];
    if (error) {
        return nil;
    } else {
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF.userID IN %@", identifiers];
        users = [allUsers filteredSetUsingPredicate:searchPredicate];
    }
    return users;
}

@end
