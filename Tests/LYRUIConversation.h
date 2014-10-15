//
//  LYRUIConversation.h
//  LayerSample
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRUIUser.h"

@interface LYRUIConversation : NSObject

@property (nonatomic, strong) NSSet *participants;

@property (nonatomic, strong) NSDate *createdAt;

@property (nonatomic, strong) LYRUIMessage *lastMessage;

- (NSSet *)testConversations;

@end
