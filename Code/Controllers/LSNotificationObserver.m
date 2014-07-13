//
//  LSNotificationObserver.m
//  LayerSample
//
//  Created by Kevin Coleman on 7/11/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSNotificationObserver.h"

@implementation LSNotificationObserver

- (id)initWithClient:(LYRClient *)layerClient conversation:(LYRConversation *)conversation
{
    self = [super init];
    if (self) {
        
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
    
    NSArray *changes = [notification.userInfo objectForKey:LYRClientObjectChangesUserInfoKey];
    for (NSDictionary *change in changes) {
        
        if ([[change objectForKey:LYRObjectChangeObjectKey] isKindOfClass:[LYRConversation class]]) {
            [self handleConversationUpdate:change];
        }
        
        if ([[change objectForKey:LYRObjectChangeObjectKey]isKindOfClass:[LYRMessage class]]) {
            [self handleMessageUpdate:change];
        }
    }
    [self.delegate observerDidChangeContent:self];
}

- (void)handleConversationUpdate:(NSDictionary *)conversationUpdate
{
    if (![conversationUpdate objectForKey:@"property"]) {
        LYRConversation *conversation = [conversationUpdate objectForKey:LYRObjectChangeObjectKey];
        LYRObjectChangeType changeType = (LYRObjectChangeType)[[conversationUpdate objectForKey:LYRObjectChangeTypeKey] integerValue];
        [self.delegate observer:self didChangeObject:conversation atIndex:0 forChangeType:changeType newIndexPath:0];
    }

}

- (void)handleMessageUpdate:(NSDictionary *)messageUpdate
{
    if (![messageUpdate objectForKey:@"property"]) {
        LYRMessage *message = [messageUpdate objectForKey:LYRObjectChangeObjectKey];
        LYRObjectChangeType changeType = (LYRObjectChangeType)[[messageUpdate objectForKey:LYRObjectChangeTypeKey] integerValue];
        [self.delegate observer:self didChangeObject:message atIndex:0 forChangeType:changeType newIndexPath:0];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
