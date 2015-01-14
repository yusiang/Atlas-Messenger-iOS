//
//  LYRSampleParticipant.h
//  LYRSampleData
//
//  Created by Kevin Coleman on 6/4/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRUIParticipant.h"

@interface LSUser : NSObject <NSCoding, LYRUIParticipant>

+ (instancetype)userFromDictionaryRepresentation:(NSDictionary *)representation;

@property (nonatomic) NSString *userID;
@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic, readonly) NSString *fullName;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *password;
@property (nonatomic) NSString *passwordConfirmation;
@property (nonatomic, readonly) NSString *participantIdentifier;

- (BOOL)validate:(NSError **)error;

@end
