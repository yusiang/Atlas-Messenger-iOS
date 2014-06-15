//
//  LSUserManager.h
//  LayerSample
//
//  Created by Kevin Coleman on 6/14/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSUserManager : NSObject

+(BOOL)registerWithFullName:(NSString *)fullName email:(NSString *)email password:(NSString *)password andConfirmation:(NSString *)confirmation;

+(BOOL)loginWithEmail:(NSString *)email andPassword:(NSString *)password;

+(NSArray *)fetchContacts;

+(NSString *)loggedInUserID;

+(NSDictionary *)userInfoForUserID:(NSString *)userID;

+(void)logout;

@end
