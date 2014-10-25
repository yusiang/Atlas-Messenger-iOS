//
//  LSLocalNotificationUtilities.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSLocalNotificationUtilities.h"

@interface LSLocalNotificationUtilities ()

@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) NSMutableArray *notifications;

@end

@implementation LSLocalNotificationUtilities

static NSString *const LSNotificationIdentifier = @"identifier";

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
    NSMutableArray *messageChanges = [self processLayerChangeNotification:notification];
    if (messageChanges.count > 0) {
        [self processMessageChanges:messageChanges];
    }
}

- (NSMutableArray *)processLayerChangeNotification:(NSNotification *)notification
{
    NSMutableArray *messageArray = [[NSMutableArray alloc] init];
    NSArray *changes = [notification.userInfo objectForKey:LYRClientObjectChangesUserInfoKey];
    for (NSDictionary *change in changes) {
        if ([[change objectForKey:LYRObjectChangeObjectKey]isKindOfClass:[LYRMessage class]]) {
            [messageArray addObject:change];
        }
    }
    return messageArray;
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

- (void)initLocalNotificationForMessage:(LYRMessage *)message
{
    LYRMessagePart *messagePart = [message.parts objectAtIndex:0];
    NSString *alertString = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = alertString;
    localNotification.userInfo = @{LSNotificationIdentifier : [message.identifier absoluteString]};
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    [self.notifications addObject:localNotification];
}

- (void)removeLocalNotificationForMessage:(LYRMessage *)message
{
    for (UILocalNotification *notification in self.notifications) {
        NSString *identifier = [notification.userInfo objectForKey:LSNotificationIdentifier];
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
