//
//  LSLayerClient.m
//  LayerSample
//
//  Created by Kevin Coleman on 11/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSLayerClient.h"

@implementation LSLayerClient

- (NSUInteger)countOfUnreadMessages
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    LYRPredicate *unreadPred =[LYRPredicate predicateWithProperty:@"isUnread" operator:LYRPredicateOperatorIsEqualTo value:@(YES)];
    LYRPredicate *userPred = [LYRPredicate predicateWithProperty:@"sentByUserID" operator:LYRPredicateOperatorIsNotEqualTo value:self.authenticatedUserID];
    query.predicate = [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd subpredicates:@[unreadPred, userPred]];
    query.resultType = LYRQueryResultTypeCount;
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
