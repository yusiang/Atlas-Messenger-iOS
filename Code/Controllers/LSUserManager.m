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


- (void)persistAuthenticatedEmail:(NSString *)email withInfo:(NSDictionary *)userInfo
{
    LSUser *user = [[LSUser alloc] init];
    user.email = email;
    user.authToken = [userInfo objectForKey:@"authentication_token"];
    user.identifier = [userInfo objectForKey:@"id"];
    [self setLoggedInUser:user];
}

- (void)persistApplicationContacts:(NSDictionary *)contacts
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"users"];
    
    NSMutableArray *applicationUsers = [[NSMutableArray alloc] init];
    
    for (NSDictionary *contact in contacts) {
        LSUser *user = [[LSUser alloc] init];
        user.fullName = [contact objectForKey:@"name"];
        user.email = [contact objectForKey:@"email"];
        
        NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:user];
        [applicationUsers addObject:userData];
    }

    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:applicationUsers] forKey:@"users"];
    [defaults synchronize];
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
            return TRUE;
        }
    }
    return FALSE;
}


- (LSUser *)userWithEmail:(NSString *)email
{
    NSArray *existingUsers = [self allApplicationsUsers];
    for (NSData *data in existingUsers) {
        LSUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([user.email isEqualToString:email]) {
            return user;
        }
    }
    return nil;
}

- (void)setLoggedInUser:(LSUser *)user
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"loggedInUser"]) [defaults removeObjectForKey:@"loggedInUser"];
    
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:user] forKey:@"loggedInUser"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
