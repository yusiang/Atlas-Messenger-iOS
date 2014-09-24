//
//  LYRUIConversationViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import <MapKit/MapKit.h>
#import "LYRUIParticipant.h"
#import "LYRUIMessageInputToolbar.h"


@class LYRUIConversationViewController;

@protocol LYRUIConversationViewControllerDataSource <NSObject>

/**
 @abstract Asks the data source for an object conforming to the `LYRUIParticipant` protocol for a given identifier
 @param conversationListViewController The conversation view controller requesting the object
 @param conversation The participant identifier
 */
- (id<LYRUIParticipant>)conversationViewController:(LYRUIConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier;

/**
 @abstract Asks the data source for a string representation of a given date
 @param conversationListViewController The conversation view controller requesting the string
 @param conversation The `NSDate` object to be displayed as a string
 @discussion The date string will be displayed above message cells in section headers. The date represents the `sentAt` date of a message object
 */
- (NSString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date;

/**
 @abstract Asks the data source for a string representation of a given `LYRRecipientStatus`
 @param conversationListViewController The conversation view controller requesting the string
 @param conversation The `LYRRecipientStatus` object to be displayed as a string
 @discussion The date string will be displayed above message cells in section headers. The date represents the `sentAt` date of a message object
 */
- (NSString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus;

@end

@interface LYRUIConversationViewController : UIViewController

/**
 @abstract Creates and returns a new conversation view controller initialized with the given conversation and Layer client.
 @param conversation The conversation object whose messages are to be displayed in the conversation view controller
 @param layerClient The Layer client from which to retrieve the conversations for display.
 @return A new conversation view controller.
 */
+ (instancetype)conversationViewControllerWithConversation:(LYRConversation *)conversation layerClient:(LYRClient *)layerClient;

/**
 @abstract The `LYRUIConversationViewControllerDataSource` class presents an interface allowing
 for the display of information pertaining to specific messages in the conversation view controller
 */
@property (nonatomic, weak) id<LYRUIConversationViewControllerDataSource> dataSource;

/**
 @abstract Boolean value to determine whether or not the conversation view controller permits editing
 */
@property (nonatomic, assign) BOOL allowsEditing;

@end


