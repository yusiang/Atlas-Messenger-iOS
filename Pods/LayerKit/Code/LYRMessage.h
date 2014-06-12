//
//  LYRMessage.h
//  LayerKit
//
//  Created by Blake Watters on 5/8/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LYRConversation;

/**
 @abstract `LYRMessageState` is an enumerated value declaring the lifecycle states for a `LYRMessage` object.
 */
typedef NS_ENUM(NSUInteger, LYRMessageState) {
	/// @abstract The state for a new, unsent message.
	LYRMessageStateNew = 1,
	/// @abstract The state for a message that has been sent locally, but is awaiting synchronization.
	LYRMessageStatePending,
	/// @abstract The state for a message that has been sent.
	LYRMessageStateSent,
	/// @abstract The state for a message that has been delivered, but not yet read.
	LYRMessageStateDelivered,
	/// @abstract The state for a message that has been read.
	LYRMessageStateRead,
	/// @abstract The state for a message that has been deleted.
	LYRMessageStateDeleted
};

/**
 @abstract The `LYRMessage` class represents a message within a conversation (modeled by the `LYRConversation` class) between two or
 more participants within Layer.
 */
@interface LYRMessage : NSObject

/**
 @abstract The conversation that the receiver is a part of.
 */
@property (nonatomic, readonly) LYRConversation *conversation;

/**
 @abstract An array of message parts (modeled by the `LYRMessagePart` class) that provide access to the content of the receiver.
 */
@property (nonatomic, readonly) NSArray *parts;

/**
 @abstract A dictionary of metadata about the message synchronized among all participants.
 
 @discussion The metadata is a free-form structure for embedding synchronized data about the conversation that is
 to be shared among the participants. For example, a message might be designated as important by embedding a Boolean value
 within the metadata dictionary.
 */
@property (nonatomic, readonly) NSDictionary *metadata;

/**
 @abstract A dictionary of private, user-specific information about the message.
 
 @discussion The user info is a free-form structure for embedding data about the conversation that is synchronized between all the devices
 of the authenticated user, but is not shared with any other participants. For example, an applicatication may wish to flag a message for
 future follow-up by the user by embedding a Boolean value into the user info dictionary.
 */
@property (nonatomic, readonly) NSDictionary *userInfo;

/**
 @abstract The date and time that the message was originally sent.
 */
@property (nonatomic, readonly) NSDate *sentAt;

/**
 @abstract The date and time that the message was received by the authenticated user or `nil` if the current user sent the message.
 */
@property (nonatomic, readonly) NSDate *receivedAt;

/**
 @abstract The user ID of the user who sent the message.
 */
@property (nonatomic, readonly) NSString *sentByUserID;

///------------------------------
/// @name Accessing Read Receipts
///------------------------------

/**
 @abstract Returns a dictionary keyed the user ID of all participants in the conversation that the message is a part of and whose
 values are an `NSNumber` representation of the message state (`LYRMessageState` value)
 */
@property (nonatomic, readonly) NSDictionary *recipientStatesByUserID;

/**
 @abstract Retrieves the message state for a given participant in the conversation.
 
 @param userID The user ID to retrieve the message state for.
 @return An `LYRMessageState` value specifying the message state for the given participant or `0` if the specified user is not a
 participant in the convrsation.
 */
- (LYRMessageState)stateForUserID:(NSString *)userID;

@end

@interface LYRNullMessage : LYRMessage
@end
