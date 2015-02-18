//
//  ATLMLayerClient.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 11/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ATLMLayerClient.h"

@implementation ATLMLayerClient

- (NSUInteger)countOfUnreadMessages
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    LYRPredicate *unreadPred =[LYRPredicate predicateWithProperty:@"isUnread" operator:LYRPredicateOperatorIsEqualTo value:@(YES)];
    LYRPredicate *userPred = [LYRPredicate predicateWithProperty:@"sentByUserID" operator:LYRPredicateOperatorIsNotEqualTo value:self.authenticatedUserID];
    query.predicate = [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd subpredicates:@[unreadPred, userPred]];
    return [self countForQuery:query error:nil];
}

- (NSUInteger)countOfMessages
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    return [self countForQuery:query error:nil];
}

- (NSUInteger)countOfConversations
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    return [self countForQuery:query error:nil];
}

- (LYRMessage *)messageForIdentifier:(NSURL *)identifier
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:identifier];
    query.limit = 1;
    return [self executeQuery:query error:nil].firstObject;
}

- (LYRConversation *)conversationForIdentifier:(NSURL *)identifier
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:identifier];
    query.limit = 1;
    return [self executeQuery:query error:nil].firstObject;
}

- (LYRConversation *)conversationForParticipants:(NSSet *)participants
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"participants" operator:LYRPredicateOperatorIsEqualTo value:participants];
    query.limit = 1;
    return [self executeQuery:query error:nil].firstObject;
}

@end
