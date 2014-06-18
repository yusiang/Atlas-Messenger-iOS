//
//  LSUserManager.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/14/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSUserManager.h"
#import "LSAlertView.h"

@implementation LSUserManager

#pragma mark
#pragma mark Public Class Methods

+ (BOOL)registerWithFullName:(NSString *)fullName email:(NSString *)email password:(NSString *)password andConfirmation:(NSString *)confirmation
{
    if ([self verifyFullName:fullName email:email password:password andConfirmation:confirmation]) {
        return TRUE;
    }
    return FALSE;
}

+ (BOOL)loginWithEmail:(NSString *)email andPassword:(NSString *)password
{
    if(![self verifyEmail:email andPassword:password]){
        [LSAlertView invalidLoginCredentials];
        return FALSE;
    }
    return TRUE;
}

+ (NSArray *)fetchContacts
{
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *UUIDs = [defaults objectForKey:@"UUIDs"];
    for (NSString *userID in UUIDs) {
        NSDictionary *userInfo = [defaults objectForKey:userID];
        if(![self checkIfUserInfoIsLoggedInuser:userInfo]) {
            [contacts addObject:userInfo];
        }
    }
    return contacts;
}

+(NSString *)loggedInUserID
{
    NSDictionary *loggedInUserInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"loggedInUser"];
    return [loggedInUserInfo objectForKey:@"userID"];
}

+(NSDictionary *)userInfoForUserID:(NSString *)userID;
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:userID];
}

+ (void)logout
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"loggedInUser"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark
#pragma mark Private Class Methods

//Verifys credentials for a new user. This method handles displaying errors to the user if there are registration issues
+ (BOOL)verifyFullName:(NSString *)fullName email:(NSString *)email password:(NSString *)password andConfirmation:(NSString *)confirmation
{
    if ([email isEqualToString:@""]) {
        [LSAlertView missingEmailAlert];
        return FALSE;
    }
    
    if ([password isEqualToString:@""]|| [confirmation isEqualToString:@""]) {
        [LSAlertView matchingPasswordAlert];
        return FALSE;
    }
    
    if(![password isEqualToString:confirmation]) {
        [LSAlertView matchingPasswordAlert];
        return FALSE;
    }
    if(![self storeFullName:fullName email:email password:password andConfirmation:confirmation]) {
        [LSAlertView existingUsernameAlert];
        return FALSE;
    }
    return TRUE;
}

//Stores credentials for a new user
+ (BOOL)storeFullName:(NSString *)fullName email:(NSString *)email password:(NSString *)password andConfirmation:(NSString *)confirmation
{
    if ([self checkForExistingEmail:email]) return FALSE;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *UUIDs;
    if (![defaults objectForKey:@"UUIDs"]) {
        UUIDs = [[NSMutableArray alloc] init];
    } else {
        UUIDs = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"UUIDs"]];
    }

    NSString *userID = [[NSUUID UUID] UUIDString];
    [UUIDs addObject:userID];
    
    NSDictionary *userInfo = @{@"fullName" : fullName,
                               @"email" : email,
                               @"password" : password,
                               @"confirmation" : confirmation,
                               @"userID" : userID};
    
    [defaults setObject:userInfo forKey:userID];
    [defaults setObject:UUIDs forKey:@"UUIDs"];
    [self setLoggedInUserInfo:userInfo];
    [defaults synchronize];
     NSString *loggedAfter = [[NSUserDefaults standardUserDefaults] objectForKey:@"loggedInUser"] ;
    return TRUE;
}

//Checks to see if an email exists
+ (BOOL)checkForExistingEmail:(NSString *)email
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *UUIDs = [defaults objectForKey:@"UUIDs"];
    for (NSString *userID in UUIDs) {
        NSString *existingEmail = [defaults valueForKeyPath:[NSString stringWithFormat:@"%@.email", userID]];
        if ([existingEmail isEqualToString:email]) {
            return TRUE;
        }
    }
    return FALSE;
}

//Verifies that an email and password match
+(BOOL)verifyEmail:(NSString *)email andPassword:(NSString *)password
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *UUIDs = [defaults objectForKey:@"UUIDs"];
    for (NSString *userID in UUIDs) {
        NSString *existingEmail = [defaults valueForKeyPath:[NSString stringWithFormat:@"%@.email", userID]];
        if ([existingEmail isEqualToString:email]) {
            NSString *existingPassword = [defaults valueForKeyPath:[NSString stringWithFormat:@"%@.password", userID]];
            if ([existingPassword isEqualToString:password]) {
                [self setLoggedInUserInfo:[defaults valueForKey:userID]];
                return TRUE;
            }
        }
    }
    return false;
}

//Sets the logged in user info
+ (void)setLoggedInUserInfo:(NSDictionary *)userInfo
{
    NSString *logged = [[NSUserDefaults standardUserDefaults] objectForKey:@"loggedInUser"];
    [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"loggedInUser"];
}

+ (BOOL)checkIfUserInfoIsLoggedInuser:(NSDictionary *)userInfo
{
    NSDictionary *loggedInUserInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"loggedInUser"];
    NSString *loggedInUserId = [loggedInUserInfo objectForKey:@"userID"];
    
    if ([loggedInUserId isEqualToString:[userInfo objectForKey:@"userID"]]) {
        return TRUE;
    }
    return FALSE;
}
@end
