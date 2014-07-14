//
//  LSNotificationObserver.m
//  LayerSample
//
//  Created by Kevin Coleman on 7/11/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSNotificationObserver.h"

@interface LSNotificationObserver ()

@property (nonatomic) LYRConversation *conversation;

@end

@implementation LSNotificationObserver

- (id)initWithClient:(LYRClient *)layerClient conversation:(LYRConversation *)conversation
{
    self = [super init];
    if (self) {
        
        _conversation = conversation;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerObjectsDidChangeNotification:) name:LYRClientObjectsDidChangeNotification object:layerClient];
        
    }
    return self;
}

- (id) init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}

- (void) didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification;
{
    NSLog(@"Received notification: %@", notification);
    [self.delegate observerWillChangeContent:self];
    
    NSMutableArray *conversationArray = [[NSMutableArray alloc] init];
    NSMutableArray *messageArray = [[NSMutableArray alloc] init];
    
    NSArray *changes = [notification.userInfo objectForKey:LYRClientObjectChangesUserInfoKey];
    for (NSDictionary *change in changes) {
        
        if ([[change objectForKey:LYRObjectChangeObjectKey] isKindOfClass:[LYRConversation class]]) {
            [conversationArray addObject:change];
        }
        
        if ([[change objectForKey:LYRObjectChangeObjectKey]isKindOfClass:[LYRMessage class]]) {
            [messageArray addObject:change];
        }
    }
    
    [self processConversationChanges:conversationArray];
    [self processMessageChanges:messageArray];
    
    [self.delegate observerDidChangeContent:self];
}

- (void) processConversationChanges:(NSMutableArray *)conversationChanges
{
    NSMutableArray *conversations = [[NSMutableArray alloc] init];
    for (NSDictionary *conversationUpdate in conversationChanges) {
        if (![conversationUpdate objectForKey:@"property"]) {
            LYRConversation *conversation = [conversationUpdate objectForKey:LYRObjectChangeObjectKey];
            LYRObjectChangeType updateKey = (LYRObjectChangeType)[[conversationUpdate objectForKey:LYRObjectChangeTypeKey] integerValue];
            switch (updateKey) {
                case LYRObjectChangeTypeCreate:
                    [conversations addObject:conversation];
                    break;
                case LYRObjectChangeTypeUpdate:
                    [self handleConversationUpdate:conversation];
                    break;
                case LYRObjectChangeTypeDelete:
                    [self handleConversationDeletion:conversation];
                    break;
                default:
                    break;
            }
        }
    }

    NSArray *newConversations = [conversations sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastMessageReceivedAt" ascending:YES]]];
    for (int i = 0; i < newConversations.count; i++) {
        [self handleConversationCreatation:[newConversations objectAtIndex:i] atIndex:i];
    }
}

- (void)processMessageChanges:(NSMutableArray *)messageChanges
{
    for (NSDictionary *messageUpdate in messageChanges) {
        if (![messageUpdate objectForKey:@"property"]) {
            LYRMessage *message = [messageUpdate objectForKey:LYRObjectChangeObjectKey];
            LYRObjectChangeType updateKey = (LYRObjectChangeType)[[messageUpdate objectForKey:LYRObjectChangeTypeKey] integerValue];
            switch (updateKey) {
                case LYRObjectChangeTypeCreate:
                    [self handleMessageCreatation:message];
                    break;
                case LYRObjectChangeTypeUpdate:
                    [self handleMessageUpdate:message];
                    break;
                case LYRObjectChangeTypeDelete:
                    [self handleMessageDeletion:message];
                    break;
                default:
                    break;
            }
        }
    }
}

#pragma mark
#pragma mark Conversation Notification Dispatch

- (void)handleConversationCreatation:(LYRConversation *)conversation atIndex:(NSUInteger) index
{
    [self.delegate observer:self didChangeObject:conversation atIndex:0 forChangeType:LYRObjectChangeTypeCreate newIndexPath:index];
}

- (void)handleConversationUpdate:(LYRConversation *)conversation
{
    [self.delegate observer:self didChangeObject:conversation atIndex:0 forChangeType:LYRObjectChangeTypeUpdate newIndexPath:0];
}

- (void)handleConversationDeletion:(LYRConversation *)conversation
{
     [self.delegate observer:self didChangeObject:conversation atIndex:0 forChangeType:LYRObjectChangeTypeDelete newIndexPath:0];
}

#pragma mark
#pragma mark Message Notification Dispatch

- (void)handleMessageCreatation:(LYRMessage *)message
{
    [self.delegate observer:self didChangeObject:message atIndex:0 forChangeType:LYRObjectChangeTypeCreate newIndexPath:0];
}

- (void)handleMessageUpdate:(LYRMessage *)message
{
    [self.delegate observer:self didChangeObject:message atIndex:0 forChangeType:LYRObjectChangeTypeUpdate newIndexPath:0];
}

- (void)handleMessageDeletion:(LYRMessage *)message
{
    [self.delegate observer:self didChangeObject:message atIndex:0 forChangeType:LYRObjectChangeTypeDelete newIndexPath:0];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
