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

- (void)deleteAllObjects;

@end
