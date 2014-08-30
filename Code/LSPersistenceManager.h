//
//  LSPersistenceManager.h
//  LayerSample
//
//  Created by Blake Watters on 6/28/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSSession.h"
#import "LSUser.h"

@interface LSPersistenceManager : NSObject

+ (instancetype)persistenceManagerWithInMemoryStore;
+ (instancetype)persistenceManagerWithStoreAtPath:(NSString *)path;

- (BOOL)persistUsers:(NSSet *)users error:(NSError **)error;
- (NSSet *)persistedUsersWithError:(NSError **)error;

- (BOOL)persistSession:(LSSession *)session error:(NSError **)error;
- (LSSession *)persistedSessionWithError:(NSError **)error;

/**
 *  Performs a search for contacts containg the search string in their full name
 *
 *  @param searchString the string object which is being search for
 *  @param completion   the completion block that is called when search is complete.
 */
- (void)performContactSearchWithString:(NSString *)searchString completion:(void(^)(NSSet *contacts, NSError *error))completion;

- (NSSet *)participantsForIdentifiers:(NSSet *)identifiers;

- (BOOL)deleteAllObjects:(NSError **)error;

@end