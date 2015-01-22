//
//  LSLocalNotificationManager.h
//  LayerSample
//
//  Created by Kevin Coleman on 10/25/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

extern NSString *const LSNotificationClassTypeKey;
extern NSString *const LSNotificationClassTypeConversation;
extern NSString *const LSNotificationClassTypeMessage;
extern NSString *const LSNotificationIdentifierKey;

@interface LSLocalNotificationManager : NSObject

- (void)notificationForReceiptOfPush;

- (void)notificationForSyncCompletionWithChanges:(NSArray *)changes;

- (void)processLayerChanges:(NSArray *)changes;

@end
