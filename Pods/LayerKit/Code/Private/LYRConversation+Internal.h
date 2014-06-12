//
//  LYRConversation+Internal.h
//  LayerKit
//
//  Created by Klemen Verdnik on 5/13/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRConversation.h"

@interface LYRConversation ()

@property (nonatomic) LYRSequence databaseIdentifier;
@property (nonatomic) LYRSequence streamDatabaseIdentifier;
@property (nonatomic) NSUUID *identifier;
@property (nonatomic) NSSet *participants;
@property (nonatomic) NSDictionary *metadata;

+ (id)conversationWithIdentifier:(NSUUID *)identifier participants:(NSSet *)participants;

@end