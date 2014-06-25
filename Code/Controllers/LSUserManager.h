//
//  LSUserManager.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/14/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSUser.h"
/**
 SBW: You are missing a domain model for the User.
 This method also encapsulates global user state which is not good.
 
 I'd propose a totally different API:
 
 - (void)registerUser:(LSUser *)user completion:(void)(^)(BOOL success, NSError *error);
 - (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(void)(^)(LSUser *user, NSError *error);
 - (NSArray *)contactsForUser:(LSUser *)user;
 
 Then you can pass your `LSUser` instance around to model the authentication state. This eliminates the global and makes it trivial
 to maintain multiple views in different states without teardown.
 
 If you implement `NSCoding` on the `LSUser` class then you can serialize it directly instead of mapping fields to user defaults...
 */

@interface LSUserManager : NSObject

//==========Blakes Public API Proposal==========//

- (void)registerUser:(LSUser *)user completion:(void (^)(BOOL success, NSError *error))completion;

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(LSUser *user, NSError *error))completion;

- (void)logout;


- (LSUser *)loggedInUser;

- (NSArray *)contactsForUser:(LSUser *)user;

- (LSUser *)userWithIdentifier:(NSString *)identifier;

@end
