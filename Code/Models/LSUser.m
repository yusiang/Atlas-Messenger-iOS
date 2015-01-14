//
//  LYRSampleParticipant.m
//  LYRSampleData
//
//  Created by Kevin Coleman on 6/4/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSUser.h"
#import "LSErrors.h"

@implementation LSUser

+ (instancetype)userFromDictionaryRepresentation:(NSDictionary *)representation
{
    LSUser *user = [LSUser new];
    user.userID = representation[@"id"];
    user.firstName = representation[@"first_name"];
    user.lastName = representation[@"last_name"];
    user.email = representation[@"email"];
    user.password = representation[@"password"];
    
    return user;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.userID = [decoder decodeObjectForKey:NSStringFromSelector(@selector(userID))];
    self.firstName = [decoder decodeObjectForKey:NSStringFromSelector(@selector(firstName))];
    self.lastName = [decoder decodeObjectForKey:NSStringFromSelector(@selector(lastName))];
    self.email = [decoder decodeObjectForKey:NSStringFromSelector(@selector(email))];
    self.password = [decoder decodeObjectForKey:NSStringFromSelector(@selector(password))];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.userID forKey:NSStringFromSelector(@selector(userID))];
    [encoder encodeObject:self.firstName forKey:NSStringFromSelector(@selector(firstName))];
    [encoder encodeObject:self.lastName forKey:NSStringFromSelector(@selector(lastName))];
    [encoder encodeObject:self.email forKey:NSStringFromSelector(@selector(email))];
    [encoder encodeObject:self.password forKey:NSStringFromSelector(@selector(password))];
}

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (NSString *)participantIdentifier
{
    return self.userID;
}

- (UIImage *)avatarImage
{
    return nil;
}

- (BOOL)validate:(NSError *__autoreleasing *)error
{
    if (!self.email.length) {
        if (error) *error = [NSError errorWithDomain:LSErrorDomain code:LSInvalidEmailAddress userInfo:@{ NSLocalizedDescriptionKey: @"Please enter an email to register" }];
        return NO;
    }
    
    if (!self.firstName.length) {
        if (error) *error = [NSError errorWithDomain:LSErrorDomain code:LSInvalidFirstName userInfo:@{ NSLocalizedDescriptionKey: @"Please enter your first name to register" }];
        return NO;
    }
    
    if (!self.lastName.length) {
        if (error) *error = [NSError errorWithDomain:LSErrorDomain code:LSInvalidLastName userInfo:@{ NSLocalizedDescriptionKey: @"Please enter your last name to register" }];
        return NO;
    }
    
    if (!self.password.length || !self.passwordConfirmation.length || ![self.password isEqualToString:self.passwordConfirmation]) {
        if (error) *error = [NSError errorWithDomain:LSErrorDomain code:LSInvalidPassword userInfo:@{ NSLocalizedDescriptionKey: @"Please enter matching passwords to register" }];
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash
{
    return self.userID.hash;
}

- (BOOL)isEqual:(id)object
{
    if (!object) return NO;
    if (![object isKindOfClass:[LSUser class]]) return NO;
    LSUser *otherUser = (LSUser *)object;
    return [self.userID isEqualToString:otherUser.userID];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p userID=%@, firstName=%@, lastName=%@, email=%@, password=%@>",
            [self class], self, self.userID, self.firstName, self.lastName, self.email, self.password];
}

@end
