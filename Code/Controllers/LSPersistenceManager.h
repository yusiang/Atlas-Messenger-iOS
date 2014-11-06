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

/**
 @abstract The `LSPersistenceManager` provides an interface for persiting and querying, session and contact
 data related to the Layer Sample Application
 */
@interface LSPersistenceManager : NSObject

///---------------------------------------
/// @name Designated Initializers
///---------------------------------------

/**
 @abstract Designated initializer when running tests.
 */
+ (instancetype)persistenceManagerWithInMemoryStore;

/**
 @abstract Designated initializer when running the application.
 @param The path to which data should be persisted.
 */
+ (instancetype)persistenceManagerWithStoreAtPath:(NSString *)path;


///---------------------------------------
/// @name Persisting
///---------------------------------------

/**
 @abstract Persists an `NSSet` of `LSUser` objects to the specified path.
 @param users The `NSSet` of `LSUeser objects to be persisted.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A Boolen value indicating if the operation was succesful
 */
- (BOOL)persistUsers:(NSSet *)users error:(NSError **)error;

/**
 @abstract Persists an `LSSession` object for the currently authenticated User.
 @param session The `LSSession` object to be persisted.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A Boolen value indicating if the operation was succesful
 */

- (BOOL)persistSession:(LSSession *)session error:(NSError **)error;


///---------------------------------------
/// @name Fetching
///---------------------------------------

/**
 @abstract Returns the persisted `NSSet` of all `LSUser` objects.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 */
- (NSSet *)persistedUsersWithError:(NSError **)error;

/**
 @abstract Returns the persisted `LSSession` object.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 */
- (LSSession *)persistedSessionWithError:(NSError **)error;

/**
 @abstract Returns an `NSSet` of `LSUser` objects who's `userID` properties match those supplied in an `NSSet` of identifiers.
 @param identifiers An `NSSet` of `NSString` objects representing user identifiers.
 @return An `NSSet` of `LSUser` objects
 */
- (NSSet *)participantsForIdentifiers:(NSSet *)identifiers;

/**
 @abstract Performs a search across the `fullName` property on all persisted `LSUser` objects for the supplied string
 @param searchString The string object for which the search is performed.
 @param completion   The completion block called when search completes.
 */
- (void)performParticipantSearchWithString:(NSString *)searchString completion:(void(^)(NSSet *contacts, NSError *error))completion;


///---------------------------------------
/// @name Deletion
///---------------------------------------

/**
 @abstract Deletes all objects currently persisted in teh persistence manager.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A Boolen value indicating if the operation was succesful.
 */
- (BOOL)deleteAllObjects:(NSError **)error;

@end