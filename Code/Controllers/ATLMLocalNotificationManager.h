//
//  ATLMLocalNotificationManager.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 10/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

extern NSString *const ATLMNotificationClassTypeKey;
extern NSString *const ATLMNotificationClassTypeConversation;
extern NSString *const ATLMNotificationClassTypeMessage;
extern NSString *const ATLMNotificationIdentifierKey;

@interface ATLMLocalNotificationManager : NSObject

- (void)notificationForReceiptOfPush;

- (void)notificationForSyncCompletionWithChanges:(NSArray *)changes;

- (void)processLayerChanges:(NSArray *)changes;

@end
