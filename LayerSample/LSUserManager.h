//
//  LSUserManager.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/14/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSUserManager : NSObject

//Registers a new users and saves their information to NSUserDefaults
+(BOOL)registerWithFullName:(NSString *)fullName email:(NSString *)email password:(NSString *)password andConfirmation:(NSString *)confirmation;

//Checks if a user exists in NSUserDefaults nad logs them in yes
+(BOOL)loginWithEmail:(NSString *)email andPassword:(NSString *)password;

//Returns an array of all contacts in NSUserDefaults
+(NSArray *)fetchContacts;

//Returns the userID for the currently logged in user
+(NSString *)loggedInUserID;

//Returns a dictionary of userInfo for a userID
+(NSDictionary *)userInfoForUserID:(NSString *)userID;

+(void)logout;

@end
