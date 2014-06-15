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
    NSString *lastUserID = [defaults objectForKey:@"lastUserID"];
    for (int i = [lastUserID doubleValue]; i > -1; i--) {
        NSDictionary *userInfo = [defaults objectForKey:[NSString stringWithFormat:@"%d", i]];
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

+ (BOOL)storeFullName:(NSString *)fullName email:(NSString *)email password:(NSString *)password andConfirmation:(NSString *)confirmation
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastUserID = [defaults objectForKey:@"lastUserID"];
    
    if ([self checkForExistingEmail:email withUserID:lastUserID]) {
        return FALSE;
    }
    
    NSString *userID;
    
    if (lastUserID) {
        int number = [lastUserID intValue];
        userID = [NSString stringWithFormat:@"%d", (number + 1)];
    } else {
        userID = [NSString stringWithFormat:@"%d", 0];
    }
    
    NSDictionary *userInfo = @{@"fullName" : fullName,
                               @"email" : email,
                               @"password" : password,
                               @"confirmation" : confirmation,
                               @"userID" : userID};
    
    [defaults setObject:userInfo forKey:userID];
    [defaults setObject:userID forKey:@"lastUserID"];
    [self setLoggedInUserInfo:userInfo];
    [defaults synchronize];
    
    return TRUE;
}

+ (BOOL)checkForExistingEmail:(NSString *)email withUserID:(NSString *)userID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (int i = [userID doubleValue] ; i > -1; i--) {
        NSString *existingEmail = [defaults valueForKeyPath:[NSString stringWithFormat:@"%@.email", userID]];
        if ([existingEmail isEqualToString:email]) {
            return TRUE;
        }
    }
    return FALSE;
}

+(BOOL)verifyEmail:(NSString *)email andPassword:(NSString *)password
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lasterUserID = [defaults objectForKey:@"lastUserID"];
    for (int i = [lasterUserID doubleValue]; i > -1; i--) {
        NSString *existingEmail = [defaults valueForKeyPath:[NSString stringWithFormat:@"%@.email", [NSString stringWithFormat:@"%d", i]]];
        if ([existingEmail isEqualToString:email]) {
            NSString *existingPassword = [defaults valueForKeyPath:[NSString stringWithFormat:@"%@.password", [NSString stringWithFormat:@"%d", i]]];
            if ([existingPassword isEqualToString:password]) {
                [self setLoggedInUserInfo:[defaults valueForKey:[NSString stringWithFormat:@"%d", i]]];
                return TRUE;
            }
        }
    }
    return false;
}

+ (void)setLoggedInUserInfo:(NSDictionary *)userInfo
{
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
