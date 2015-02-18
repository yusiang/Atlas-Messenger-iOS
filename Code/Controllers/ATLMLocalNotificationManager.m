//
//  ATLMLocalNotificationManager.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 10/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ATLMLocalNotificationManager.h"

NSString *const ATLMNotificationClassTypeKey = @"class";
NSString *const ATLMNotificationClassTypeConversation = @"conversation";
NSString *const ATLMNotificationClassTypeMessage = @"message";
NSString *const ATLMNotificationIdentifierKey = @"identifier";

@interface ATLMLocalNotificationManager ()

@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) NSMutableArray *notifications;

@end

@implementation ATLMLocalNotificationManager

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
    localNotification.userInfo = @{ATLMNotificationClassTypeKey: ATLMNotificationClassTypeMessage,
                                   ATLMNotificationIdentifierKey: message.identifier.absoluteString};
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    [self.notifications addObject:localNotification];
}

- (void)notificationForNewConversation:(LYRConversation *)conversation
{
    if (!conversation) return;
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"You have a new Layer conversation. Tap to open.";
    localNotification.userInfo = @{ATLMNotificationClassTypeKey: ATLMNotificationClassTypeConversation,
                                   ATLMNotificationIdentifierKey: conversation.identifier.absoluteString};
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    [self.notifications addObject:localNotification];
}

- (void)removeLocalNotificationForMessage:(LYRMessage *)message
{
    for (UILocalNotification *notification in self.notifications) {
        NSString *identifier = notification.userInfo[ATLMNotificationIdentifierKey];
        if ([identifier isEqualToString:message.identifier.absoluteString]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

@end
