//
//  LYRMessage+internal.h
//  LayerKit
//
//  Created by Klemen Verdnik on 5/13/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRMessage.h"

@interface LYRMessage ()

@property (nonatomic, readwrite) LYRConversation *conversation;
@property (nonatomic, readwrite) NSArray *parts;
@property (nonatomic, readwrite) NSDictionary *metadata;
@property (nonatomic, readwrite) NSDictionary *userInfo;
@property (nonatomic, readwrite) NSDate *createdAt;
@property (nonatomic, readwrite) NSDate *sentAt;
@property (nonatomic, readwrite) NSDate *receivedAt;
@property (nonatomic, readwrite) NSDate *deletedAt;
@property (nonatomic, readwrite) NSString *sentByUserID;
@property (nonatomic, readwrite) NSDictionary *recipientStatesByUserID;
@property (nonatomic) LYRSequence seq;
@property (nonatomic) LYRSequence eventDatabaseIdentifier;
@property (nonatomic) LYRSequence databaseIdentifier;
- (id)initWithDatabaseIdentifier:(LYRSequence)databaseIdentifier;
+ (id)messageWithDatabaseIdentifier:(LYRSequence)databaseIdentifier;

@end
