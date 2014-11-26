//
//  LSLayerInterface.m
//  LayerSample
//
//  Created by Kevin Coleman on 11/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSLayerInterface.h"

@interface LSLayerInterface ()

@property (nonatomic) LYRClient *layerClient;

@end

@implementation LSLayerInterface

- (NSUInteger)countOfUnreadMessages
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    LYRPredicate *unreadPred =[LYRPredicate predicateWithProperty:@"isUnread" operator:LYRPredicateOperatorIsEqualTo value:@(YES)];
    LYRPredicate *userPred = [LYRPredicate predicateWithProperty:@"sendByUserId" operator:LYRPredicateOperatorIsNotEqualTo value:self.layerClient.authenticatedUserID];
    query.predicate = [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd subpredicates:@[unreadPred, userPred]];
    query.resultType = LYRQueryResultTypeCount;
    return [self.layerClient countForQuery:query error:nil];
}

- (NSUInteger)countOfMessages
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    return [self.layerClient countForQuery:query error:nil];
}

- (NSUInteger)countOfConversations
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    return [self.layerClient countForQuery:query error:nil];
}

- (LYRMessage *)messageForIdentifier:(NSURL *)identifier
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:identifier];
    return [[self.layerClient executeQuery:query error:nil] lastObject];
}

- (LYRConversation *)conversationForIdentifier:(NSURL *)identifier
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:identifier];
    return [[self.layerClient executeQuery:query error:nil] firstObject];
}

- (LYRConversation *)conversationForParticipants:(NSSet *)participants
{
    NSMutableSet *set = [participants copy];
    [set addObject:self.layerClient.authenticatedUserID];
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"participants" operator:LYRPredicateOperatorIsEqualTo value:set];
    return [[self.layerClient executeQuery:query error:nil] lastObject];
}

@end
