//
//  LYRUITestUser.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUITestUser.h"

@implementation LYRUITestUser

static NSString *const LSTestUser0FirstName = @"Layer";
static NSString *const LSTestUser0LastName = @"Tester0";
static NSString *const LSTestUser0Email = @"tester0@layer.com";
static NSString *const LSTestUser0Password = @"password0";
static NSString *const LSTestUser0Confirmation = @"password0";

static NSString *const LSTestUser1FirstName = @"Layer";
static NSString *const LSTestUser1LastName = @"Tester1";
static NSString *const LSTestUser1Email = @"tester1@layer.com";
static NSString *const LSTestUser1Password = @"password1";
static NSString *const LSTestUser1Confirmation = @"password1";

static NSString *const LSTestUser2FirstName = @"Layer";
static NSString *const LSTestUser2LastName = @"Tester2";
static NSString *const LSTestUser2Email = @"tester2@layer.com";
static NSString *const LSTestUser2Password = @"password2";
static NSString *const LSTestUser2Confirmation = @"password2";

static NSString *const LSTestUser3FirstName = @"Layer";
static NSString *const LSTestUser3LastName = @"Tester3";
static NSString *const LSTestUser3Email = @"tester3@layer.com";
static NSString *const LSTestUser3Password = @"password3";
static NSString *const LSTestUser3Confirmation = @"password3";

static NSString *const LSTestUser4FirstName = @"Layer";
static NSString *const LSTestUser4LastName = @"Tester4";
static NSString *const LSTestUser4Email = @"tester4@layer.com";
static NSString *const LSTestUser4Password = @"password4";
static NSString *const LSTestUser4Confirmation = @"password4";

+(LSUser *)testUserWithNumber:(NSUInteger)number
{
    LSUser *user = [[LSUser alloc] init];
    switch (number) {
        case 0:
            [user setFirstName:LSTestUser0FirstName];
            [user setLastName:LSTestUser0LastName];
            [user setEmail:LSTestUser0Email];
            [user setPassword:LSTestUser0Password];
            [user setPasswordConfirmation:LSTestUser0Confirmation];
            break;
        case 1:
            [user setFirstName:LSTestUser1FirstName];
            [user setLastName:LSTestUser1LastName];
            [user setEmail:LSTestUser1Email];
            [user setPassword:LSTestUser1Password];
            [user setPasswordConfirmation:LSTestUser1Confirmation];
            break;
        case 2:
            [user setFirstName:LSTestUser2FirstName];
            [user setLastName:LSTestUser2LastName];
            [user setEmail:LSTestUser2Email];
            [user setPassword:LSTestUser2Password];;
            [user setPasswordConfirmation:LSTestUser2Confirmation];
            break;
        case 3:
            [user setFirstName:LSTestUser3FirstName];
            [user setLastName:LSTestUser3LastName];
            [user setEmail:LSTestUser3Email];
            [user setPassword:LSTestUser3Password];
            [user setPasswordConfirmation:LSTestUser3Confirmation];
            break;
        case 4:
            [user setFirstName:LSTestUser4FirstName];
            [user setLastName:LSTestUser4LastName];
            [user setEmail:LSTestUser4Email];
            [user setPassword:LSTestUser4Password];
            [user setPasswordConfirmation:LSTestUser4Confirmation];
            break;
        default:
            break;
    }
    return user;
}

@end
