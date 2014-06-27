//
//  LYRSampleParticipant.h
//  LYRSampleData
//
//  Created by Kevin Coleman on 6/4/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSUser : NSObject <NSCoding>

@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *confirmation;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *authToken;

@end
