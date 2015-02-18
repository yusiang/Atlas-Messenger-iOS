//
//  ATLTestUser.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "ATLMTestUser.h"

@implementation ATLMTestUser

+ (instancetype)testUserWithNumber:(NSUInteger)number
{
    ATLMTestUser *user = [ATLMTestUser new];
    [user setFirstName:@"Layer"];
    [user setLastName:[NSString stringWithFormat:@"Tester%lu", (unsigned long)number]];
    [user setEmail:[NSString stringWithFormat:@"tester%lu@layer.com", (unsigned long)number]];
    [user setPassword:[NSString stringWithFormat:@"password%lu", (unsigned long)number]];
    [user setPasswordConfirmation:[NSString stringWithFormat:@"password%lu", (unsigned long)number]];
    return user;
}

@end
