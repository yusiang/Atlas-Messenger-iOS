//
//  LSNotificationObserver.h
//  LayerSample
//
//  Created by Kevin Coleman on 7/11/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRClient.h"


typedef NS_ENUM(NSInteger, LYRObjectChangeType) {
	LYRObjectChangeTypeCreate,
	LYRObjectChangeTypeUpdate,
	LYRObjectChangeTypeDelete
};

@class LSNotificationObserver;

@protocol LSNotificationObserverDelegate <NSObject>

@optional

- (void)notificationObserver:(LSNotificationObserver *)observert didCreateConversation:(LYRConversation *)conversation;
- (void)notificationObserver:(LSNotificationObserver *)observert didUpdateConversation:(LYRConversation *)conversation;
- (void)notificationObserver:(LSNotificationObserver *)observert didDeleteConversation:(LYRConversation *)conversation;

- (void)notificationObserver:(LSNotificationObserver *)observert didCreateMessage:(LYRMessage *)message;
- (void)notificationObserver:(LSNotificationObserver *)observert didUpdateMessage:(LYRMessage *)message;
- (void)notificationObserver:(LSNotificationObserver *)observert didDeleteMessage:(LYRMessage *)message;

@end

@interface LSNotificationObserver : NSObject

@property (nonatomic, weak) id<LSNotificationObserverDelegate>delegate;

- (id) initWithClient:(LYRClient *)layerClient;

@end
