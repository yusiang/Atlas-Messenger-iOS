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

static NSString *const LSUserDirectoryPath = @"users";

#pragma mark
#pragma mark Public Authentication Methods

- (void)registerUser:(LSUser *)user completion:(void (^)(BOOL success, NSError *error))completion
{
<<<<<<< HEAD
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *UUIDs = [defaults objectForKey:@"UUIDs"];
    for (NSString *userID in UUIDs) {
        NSDictionary *userInfo = [defaults objectForKey:userID];
        if(![self checkIfUserInfoIsLoggedInuser:userInfo]) {
            [contacts addObject:userInfo];
        }
=======
    NSError *error;
    BOOL success = NO;
    
    if (!user.fullName) {
        error = [NSError errorWithDomain:@"Registration Error" code:101 userInfo:@{@"description" : @"Please enter your Full Name in order to register"}];
    }
    
    if (!user.email) {
        error = [NSError errorWithDomain:@"Registration Error" code:101 userInfo:@{@"description" : @"Please enter an email in order to register"}];
    }
    
    if (!user.password || !user.confirmation || ![user.password isEqualToString:user.confirmation]) {
        error = [NSError errorWithDomain:@"Registration Error" code:101 userInfo:@{@"description" : @"Please enter matching passwords in order to register"}];
>>>>>>> blake-MSG-187-code-review-feedback
    }

    if ([self userExists:user]) {
        error = [NSError errorWithDomain:@"Registration Error" code:101 userInfo:@{@"description" : @"Email address taken. Please enter another email."}];
    } else {
        NSMutableArray *applicationUsers = [[NSMutableArray alloc] initWithArray:[self allApplicationsUsers]];
        
        NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:user];
        [applicationUsers addObject:userData];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:applicationUsers] forKey:@"users"];
        
        [self setLoggedInUser:user];
        
        success = YES;
    }
    completion(success, error);
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(LSUser *user, NSError *error))completion
{
    NSError *error;
    
    if (!email) {
         error = [NSError errorWithDomain:@"Login Error" code:101 userInfo:@{@"description" : @"Please enter your Email address in order to Login"}];
    }
    
    if (!password) {
        error = [NSError errorWithDomain:@"Login Error" code:101 userInfo:@{@"description" : @"Please enter your password in order to login"}];
    }
    
    LSUser *user = [self userWithEmail:email];
    if (!user) {
        error = [NSError errorWithDomain:@"Login Error" code:101 userInfo:@{@"description" : @"Email does not exist, please register or login with a different email."}];
    }
    
    if (![user.password isEqualToString:password]) {
        error = [NSError errorWithDomain:@"Login Error" code:101 userInfo:@{@"description" : @"Incorrect password, please try again."}];
    }
    
    [self setLoggedInUser:user];
    
    completion (user, error);
}

- (void)logout
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loggedInUser"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark
#pragma mark Public User Methods

- (LSUser *)loggedInUser
{
    NSData *userData = [[NSUserDefaults standardUserDefaults] objectForKey:@"loggedInUser"];
    return [NSKeyedUnarchiver unarchiveObjectWithData:userData];
}

- (NSArray *)contactsForUser:(LSUser *)user
{
    NSMutableArray *userObjects = [[NSMutableArray alloc] init];
    NSArray *users = [self allApplicationsUsers];
    for (NSData *userData in users) {
        LSUser *existingUser = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        NSLog(@"Existing User ID %@", existingUser.identifier);
        NSLog(@"User ID %@", user.identifier);
        if ([existingUser.identifier isEqualToString:user.identifier]) break;
        [userObjects addObject:existingUser];
    }
    
    return [[NSArray alloc] initWithArray:userObjects];
}

- (LSUser *)userWithIdentifier:(NSString *)identifier
{
    NSArray *existingUsers = [self allApplicationsUsers];
    for (NSData *data in existingUsers) {
        LSUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([user.identifier isEqualToString:identifier]) {
            return user;
        }
    }
    return nil;
}


#pragma mark 
#pragma mark Private Implementation Methods

- (NSArray *)allApplicationsUsers
{
<<<<<<< HEAD
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
    NSLog(@"New user Info is %@", userInfo);
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
=======
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults objectForKey:@"users"]) {
        return [[NSArray alloc] init];
    }
    
    NSData *savedArray = [defaults objectForKey:@"users"];
    return [NSKeyedUnarchiver unarchiveObjectWithData:savedArray];
}

- (BOOL)userExists:(LSUser *)user
{
    NSArray *existingUsers = [self allApplicationsUsers];
    for (NSData *data in existingUsers) {
        LSUser *existingUser = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([existingUser.email isEqualToString:user.email]) {
>>>>>>> blake-MSG-187-code-review-feedback
            return TRUE;
        }
    }
    return FALSE;
}


- (LSUser *)userWithEmail:(NSString *)email
{
<<<<<<< HEAD
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
=======
    NSArray *existingUsers = [self allApplicationsUsers];
    for (NSData *data in existingUsers) {
        LSUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([user.email isEqualToString:email]) {
            return user;
        }
    }
    return nil;
>>>>>>> blake-MSG-187-code-review-feedback
}

- (void)setLoggedInUser:(LSUser *)user
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"loggedInUser"]) [defaults removeObjectForKey:@"loggedInUser"];
    
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:user] forKey:@"loggedInUser"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
