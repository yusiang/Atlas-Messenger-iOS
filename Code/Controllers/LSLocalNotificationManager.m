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

- (id)init
{
    self = [super init];
    if (self) {
        _notifications = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Public Methods 

- (void)notificationForReceiptOfPush
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"Got a push...Layer processing";
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

- (void)notificationForSyncCompletionWithChanges:(NSArray *)changes
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = [NSString stringWithFormat:@"Finished sync with changes %lu", (unsigned long)changes.count];
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

- (void)processLayerChanges:(NSArray *)changes
{
    NSMutableArray *messageChanges = [[NSMutableArray alloc] init];
    NSMutableArray *conversationChanges = [[NSMutableArray alloc] init];
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
                [self notificationForNewConversation:conversation];
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
                [self notificationForNewMessage:message];
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

- (void)notificationForNewMessage:(LYRMessage *)message
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"You have a new Layer message. Tap to open.";
    localNotification.userInfo = @{LSNotificationClassTypeKey: LSNotificationClassTypeMessage,
                                   LSNotificationIdentifierKey: message.identifier.absoluteString};
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    [self.notifications addObject:localNotification];
}

- (void)notificationForNewConversation:(LYRConversation *)conversation
{
    if (!conversation) return;
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"You have a new Layer conversation. Tap to open.";
    localNotification.userInfo = @{LSNotificationClassTypeKey: LSNotificationClassTypeConversation,
                                   LSNotificationIdentifierKey: conversation.identifier.absoluteString};
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

@end
