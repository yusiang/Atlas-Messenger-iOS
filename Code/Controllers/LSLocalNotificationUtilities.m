//
//  LSLocalNotificationUtilities.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSLocalNotificationUtilities.h"

NSString *const LSNotificationClassTypeKey = @"class";
NSString *const LSNotificationClassTypeConversation = @"conversation";
NSString *const LSNotificationClassTypeMessage = @"message";
NSString *const LSNotificationIdentifierKey = @"identifier";

@interface LSLocalNotificationUtilities ()

@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) NSMutableArray *notifications;

@end

@implementation LSLocalNotificationUtilities

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerObjectsDidChangeNotification:)
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
    NSMutableArray *messageArray = [[NSMutableArray alloc] init];
    NSMutableArray *conversationArray = [[NSMutableArray alloc] init];
    NSArray *changes = [notification.userInfo objectForKey:LYRClientObjectChangesUserInfoKey];
    for (NSDictionary *change in changes) {
        if ([[change objectForKey:LYRObjectChangeObjectKey]isKindOfClass:[LYRMessage class]]) {
            [messageArray addObject:change];
        } else {
            [conversationArray addObject:change];
        }
    }
    if (messageArray.count > 0) {
        [self processMessageChanges:messageArray];
    }
    if (conversationArray.count > 0) {
        [self processConversationChanges:conversationArray];
    }
}

- (void)processConversationChanges:(NSMutableArray *)conversationChanges
{
    for (NSDictionary *conversationChange in conversationChanges) {
        LYRConversation *conversation = [conversationChange objectForKey:LYRObjectChangeObjectKey];
        LYRObjectChangeType updateKey = (LYRObjectChangeType)[[conversationChange objectForKey:LYRObjectChangeTypeKey] integerValue];
        switch (updateKey) {
            case LYRObjectChangeTypeCreate:
                [self initLocalNotificationForConversation:conversation];
                break;
            default:
                break;
        }
    }
}

- (void)processMessageChanges:(NSMutableArray *)messageChanges
{
    for (NSDictionary *messageChange in messageChanges) {
        LYRMessage *message = [messageChange objectForKey:LYRObjectChangeObjectKey];
        LYRObjectChangeType updateKey = (LYRObjectChangeType)[[messageChange objectForKey:LYRObjectChangeTypeKey] integerValue];
        switch (updateKey) {
            case LYRObjectChangeTypeCreate:
                [self initLocalNotificationForMessage:message];
                break;
                
            case LYRObjectChangeTypeUpdate:
                if ([[messageChange objectForKey:LYRObjectChangePropertyKey] isEqualToString:@"recipientStatusByUserID"]) {
                    NSDictionary *recipientStates = [messageChange objectForKey:LYRObjectChangeNewValueKey];
                    NSInteger recipientState = [[recipientStates objectForKey:self.layerClient.authenticatedUserID] integerValue];
                    if (recipientState == LYRRecipientStatusRead) {
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

- (void)initLocalNotificationForConversation:(LYRConversation *)conversation
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"You have a new Layer conversation. Tap to open.";
    localNotification.userInfo = @{LSNotificationClassTypeKey : LSNotificationClassTypeConversation,
                                   LSNotificationIdentifierKey : [conversation.identifier absoluteString]};
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    [self.notifications addObject:localNotification];
}

- (void)initLocalNotificationForMessage:(LYRMessage *)message
{
    LYRMessagePart *messagePart = [message.parts objectAtIndex:0];
    NSString *alertString = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = alertString;
    localNotification.userInfo = @{LSNotificationClassTypeKey : LSNotificationClassTypeMessage,
                                   LSNotificationIdentifierKey : [message.identifier absoluteString]};
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    [self.notifications addObject:localNotification];
}

- (void)removeLocalNotificationForMessage:(LYRMessage *)message
{
    for (UILocalNotification *notification in self.notifications) {
        NSString *identifier = [notification.userInfo objectForKey:LSNotificationIdentifierKey];
        if ([identifier isEqualToString:[message.identifier absoluteString]]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
