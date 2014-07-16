//
//  LSNotificationObserver.m
//  LayerSample
//
//  Created by Kevin Coleman on 7/11/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSNotificationObserver.h"

@interface LSNotificationObserver ()

@property (nonatomic) NSArray *conversations;
@property (nonatomic) LYRConversation *conversation;
@property (nonatomic) LYRClient *layerClient;

@end

@implementation LSNotificationObserver

- (id)initWithClient:(LYRClient *)layerClient conversations:(NSArray *)conversations
{
    self = [super init];
    if (self) {
        _layerClient = layerClient;
        _conversations = conversations;
        
        if (conversations.count == 1) {
            _conversation = [conversations objectAtIndex:0];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerObjectsDidChangeNotification:) name:LYRClientObjectsDidChangeNotification object:layerClient];
        
    }
    return self;
}

- (id) init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}


- (void)setConversations:(NSArray *)conversations
{
    _conversations = conversations;
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
    [self.delegate observer:self didChangeObject:nil atIndex:0 forChangeType:LYRObjectChangeTypeCreate newIndexPath:0];
}

- (void)processMessageChanges:(NSMutableArray *)messageChanges
{
    for (int i = 0; i < messageChanges.count; i++) {
        NSDictionary *messageUpdate = [messageChanges objectAtIndex:i];
        LYRMessage *message = [messageUpdate objectForKey:LYRObjectChangeObjectKey];
        if ([self.conversations containsObject:message.conversation]) {
            LYRObjectChangeType updateKey = (LYRObjectChangeType)[[messageUpdate objectForKey:LYRObjectChangeTypeKey] integerValue];
            switch (updateKey) {
                case LYRObjectChangeTypeCreate:
                    [self handleMessageCreatation:message atIndex:i];
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

- (void)handleConversationCreatation:(LYRConversation *)conversation atIndex:(NSUInteger)index
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

- (void)handleMessageCreatation:(LYRMessage *)message atIndex:(NSUInteger)index
{
    [self.delegate observer:self didChangeObject:message atIndex:0 forChangeType:LYRObjectChangeTypeCreate newIndexPath:index];
}

- (void)handleMessageUpdate:(LYRMessage *)message
{
    NSLog(@"Message index %lu", (unsigned long)message.index);
    [self.delegate observer:self didChangeObject:message atIndex:message.index forChangeType:LYRObjectChangeTypeUpdate newIndexPath:0];
}

- (void)handleMessageDeletion:(LYRMessage *)message
{
    NSLog(@"Message index %lu", (unsigned long)message.index);
    [self.delegate observer:self didChangeObject:message atIndex:message.index forChangeType:LYRObjectChangeTypeUpdate newIndexPath:0];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
