//
//  LSAPIManager.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "LSUser.h"
#import "LSPersistenceManager.h"

extern NSString *const LSUserDidAuthenticateNotification;
extern NSString *const LSUserDidDeauthenticateNotification;

/**
 @abstract The `LSAPIManager` class provides authentication with the backend and Layer and an interface for interacting with the JSON API.
 */
@interface LSAPIManager : NSObject

///-----------------------------
/// @name Initializing a Manager
///-----------------------------

+ (instancetype)managerWithBaseURL:(NSURL *)baseURL layerClient:(LYRClient *)layerClient;

/**
 @abstract The current authenticated session or `nil` if not yet authenticated.
 */
@property (nonatomic, readonly) LSSession *authenticatedSession;
@property (nonatomic, readonly) NSURLSessionConfiguration *authenticatedURLSessionConfiguration;

///------------------------------------
/// @name Managing Authentication State
///------------------------------------

/**
 *  Registers a new user with the Layer sample backend rails applicaiton
 *
 *  @param user       The model object representing the user attempting to authenticate
 *  @param completion The completion block that will be called upon completion of the registration operation
 */
- (void)registerUser:(LSUser *)user completion:(void(^)(LSUser *user, NSError *error))completion;

/**
 *  Autheticates an existing users with the Layer sample backend rails applicaiton. This method takes a nonce value that must be obtained from LayerKit. It returns an identity token in the completion block that can be used to authenticate LayerKit
 *
 *  @param email      The email address for the user attempting to authenticate
 *  @param password   The password for the user attempting to authenticate
 *  @param nonce      The nonce obtained from LayerKit
 *  @param completion The completion block that is called upon completion of the authentication operation. Upon succesful authentication, an identityToken will be returned.
 */
- (void)authenticateWithEmail:(NSString *)email password:(NSString *)password nonce:(NSString *)nonce completion:(void(^)(NSString *identityToken, NSError *error))completion;

/**
 *  Resumes a Layer sample app session
 *
 *  @param session The model object for the current session
 *  @param error   A reference to an `NSError` object that will contain error information in case the action was not successful.
 *
 *  @return A Boolean value that indicates if the application has a valid session
 */
- (BOOL)resumeSession:(LSSession *)session error:(NSError **)error;

/**
 *  Deauthenticates the Layer Sample app session
 */
- (void)deauthenticate;

///-------------------------
/// @name Accessing Contacts
///-------------------------

- (void)loadContactsWithCompletion:(void(^)(NSSet *contacts, NSError *error))completion;

///--------------------------
/// @name Delete All Contacts
///--------------------------

- (void)deleteAllContactsWithCompletion:(void(^)(BOOL completion, NSError *error))completion;

@end
