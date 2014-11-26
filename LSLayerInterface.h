//
//  LSLayerInterface.h
//  LayerSample
//
//  Created by Kevin Coleman on 11/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

@interface LSLayerInterface : NSObject

- (NSUInteger)countOfUnreadMessages;

- (NSUInteger)countOfMessages;

- (NSUInteger)countOfConversations;

- (LYRMessage *)messageForIdentifier:(NSURL *)identifier;

- (LYRConversation *)conversationForIdentifier:(NSURL *)identifier;

- (LYRConversation *)conversationForParticipants:(NSSet *)participants;

@end

