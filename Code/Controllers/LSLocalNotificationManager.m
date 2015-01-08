//
//  LSLocalNotificationManager.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSLocalNotificationManager.h"

NSString *const LSNotificationClassTypeKey = @"class";
NSString *const LSNotificationClassTypeConversation = @"conversation";
NSString *const LSNotificationClassTypeMessage = @"message";
NSString *const LSNotificationIdentifierKey = @"identifier";

@interface LSLocalNotificationManager ()

@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) NSMutableArray *notifications;

@end

@implementation LSLocalNotificationManager

+ (instancetype)initWithLayerClient:(LYRClient *)layerClient
{
    return [[self alloc] initWithLayerClient:layerClient];
}

- (id)initWithLayerClient:(LYRClient *)layerClient
{
    self = [super init];
    if (self) {
        _layerClient = layerClient;
        _shouldListenForChanges = NO;
        _notifications = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setShouldListenForChanges:(BOOL)shouldListenForChanges
{
    if (shouldListenForChanges) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveLayerObjectsDidChangeNotification:)
                                                     name:LYRClientObjectsDidChangeNotification
                                                   object:self.layerClient];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    _shouldListenForChanges = shouldListenForChanges;
}

- (void)didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification;
{
  [self processLayerChangeNotification:notification];
}

- (void)processLayerChangeNotification:(NSNotification *)notification
{
    NSMutableArray *messageChanges = [[NSMutableArray alloc] init];
    NSMutableArray *conversationChanges = [[NSMutableArray alloc] init];
    NSArray *changes = notification.userInfo[LYRClientObjectChangesUserInfoKey];
    for (NSDictionary *change in changes) {
        if ([change[LYRObjectChangeObjectKey] isKindOfClass:[LYRMessage class]]) {
            [messageChanges addObject:change];
        } else {
            [conversationChanges addObject:change];
        }
    }
    if (messageChanges.count > 0) {
        [self processMessageChanges:messageChanges];
    }
    if (conversationChanges.count > 0) {
        [self processConversationChanges:conversationChanges];
    }
}

- (void)processConversationChanges:(NSMutableArray *)conversationChanges
{
    for (NSDictionary *conversationChange in conversationChanges) {
        LYRConversation *conversation = conversationChange[LYRObjectChangeObjectKey];
        LYRObjectChangeType changeType = [conversationChange[LYRObjectChangeTypeKey] integerValue];
        switch (changeType) {
            case LYRObjectChangeTypeCreate:
                [self presentLocalNotificationForConversation:conversation];
                break;

            default:
                break;
        }
    }
}

- (void)processMessageChanges:(NSMutableArray *)messageChanges
{
    for (NSDictionary *messageChange in messageChanges) {
        LYRMessage *message = messageChange[LYRObjectChangeObjectKey];
        LYRObjectChangeType changeType = [messageChange[LYRObjectChangeTypeKey] integerValue];
        switch (changeType) {
            case LYRObjectChangeTypeCreate:
                [self presentLocalNotificationForMessage:message];
                break;
                
            case LYRObjectChangeTypeUpdate:
                if ([messageChange[LYRObjectChangePropertyKey] isEqualToString:@"recipientStatusByUserID"]) {
                    NSDictionary *recipientStatusByUserID = messageChange[LYRObjectChangeNewValueKey];
                    LYRRecipientStatus recipientStatus = [recipientStatusByUserID[self.layerClient.authenticatedUserID] integerValue];
                    if (recipientStatus == LYRRecipientStatusRead) {
                        [self removeLocalNotificationForMessage:message];
                    }
                }
                break;

            case LYRObjectChangeTypeDelete:
                [self removeLocalNotificationForMessage:message];
                break;
                
            default:
                break;
        }
    }
}

- (void)presentLocalNotificationForConversation:(LYRConversation *)conversation
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"You have a new Layer conversation. Tap to open.";
    localNotification.userInfo = @{LSNotificationClassTypeKey: LSNotificationClassTypeConversation,
                                   LSNotificationIdentifierKey: conversation.identifier.absoluteString};
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    [self.notifications addObject:localNotification];
}

- (void)presentLocalNotificationForMessage:(LYRMessage *)message
{
    LYRMessagePart *messagePart = message.parts.firstObject;
    NSString *alertString = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = alertString;
    localNotification.userInfo = @{LSNotificationClassTypeKey: LSNotificationClassTypeMessage,
                                   LSNotificationIdentifierKey: message.identifier.absoluteString};
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    [self.notifications addObject:localNotification];
}

- (void)removeLocalNotificationForMessage:(LYRMessage *)message
{
    for (UILocalNotification *notification in self.notifications) {
        NSString *identifier = notification.userInfo[LSNotificationIdentifierKey];
        if ([identifier isEqualToString:message.identifier.absoluteString]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
