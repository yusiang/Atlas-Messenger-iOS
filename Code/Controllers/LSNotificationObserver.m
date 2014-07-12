//
//  LSNotificationObserver.m
//  LayerSample
//
//  Created by Kevin Coleman on 7/11/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSNotificationObserver.h"


@implementation LSNotificationObserver

- (id)initWithClient:(LYRClient *)layerClient
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerObjectsDidChangeNotification:) name:LYRClientObjectsDidChangeNotification object:layerClient];
        
    }
    return self;
}

- (void) didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification;
{
    NSLog(@"Received notification: %@", notification);
    NSArray *changes = [notification.userInfo objectForKey:LYRClientObjectChangesUserInfoKey];
    for (NSDictionary *change in changes) {

        id changedObject = [change objectForKey:LYRObjectChangeObjectKey];
        
        if ([changedObject isKindOfClass:[LYRMessage class]]) {
            [self handleMessageUpdate:change];
        }
        
        if ([changedObject isKindOfClass:[LYRConversation class]]) {
            [self handleConversationUpdate:change];
        }
    }
}

- (void)handleConversationUpdate:(NSDictionary *)conversationUpdate
{
    LYRConversation *conversation = [conversationUpdate objectForKey:LYRObjectChangeObjectKey];
    NSNumber *changeType = [conversationUpdate objectForKey:LYRObjectChangeTypeKey];
    NSInteger change = [changeType integerValue];
    
//    //Create
//    if (change == LYRObjectChangeTypeCreate) {
//        [self.delegate notificationObserver:self didCreateConversation:conversation];
//    }
//    
//    //Update
//    if (change == LYRObjectChangeTypeUpdate) {
//        [self.delegate notificationObserver:self didUpdateConversation:conversation];
//    }
//    
//    //Delete
//    if (change == LYRObjectChangeTypeDelete) {
//        [self.delegate notificationObserver:self didDeleteConversation:conversation];
//    }
}

- (void)handleMessageUpdate:(NSDictionary *)messageUpdate
{
    LYRMessage *message = [messageUpdate objectForKey:LYRObjectChangeObjectKey];
    NSNumber *changeType = [messageUpdate objectForKey:LYRObjectChangeTypeKey];
    NSInteger change = [changeType integerValue];
    
    //Create
    if (change == LYRObjectChangeTypeCreate) {
        [self.delegate notificationObserver:self didCreateMessage:message];
    }
    
    //Update
    if (change == LYRObjectChangeTypeUpdate) {
        [self.delegate notificationObserver:self didUpdateMessage:message];
    }
    
    //Delete
    if (change == LYRObjectChangeTypeDelete) {
        [self.delegate notificationObserver:self didDeleteMessage:message];
    }
}

@end
