//
//  LYRSampleParticipant.h
//  LYRSampleData
//
//  Created by Kevin Coleman on 6/4/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Atlas/Atlas.h>

/**
 @abstract The `ATLMUser` object models a user within Atlas Messenger. The object also conforms the `ATLParticipant` protocol, enabling `ATLMUser` objects to be used with Atlas UI components.
 */
@interface ATLMUser : NSObject <NSCoding, ATLParticipant>

+ (instancetype)userFromDictionaryRepresentation:(NSDictionary *)representation;

@property (nonatomic) NSString *userID;
@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *fullName;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *password;
@property (nonatomic) NSString *passwordConfirmation;
@property (nonatomic, readonly) NSString *participantIdentifier;

- (BOOL)validate:(NSError **)error;

@end
