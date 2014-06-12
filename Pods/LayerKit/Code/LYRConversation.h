//
//  LYRConversation.h
//  LayerKit
//
//  Created by Klemen Verdnik on 06/05/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @abstract The `LYRConversation` class models a conversations between two or more participants within Layer. A conversation is an
 on-going stream of messages (modeled by the `LYRMessage` class) synchronized among all participants.
 */
@interface LYRConversation : NSObject

/**
 @abstract A unique identifier assigned to every conversation by Layer. `nil` value indicates, that the conversation hasn't been posted to the server yet.
 */
@property (nonatomic, readonly) NSUUID *identifier;
/**
 @abstract The set of user identifiers's specifying who is participating in the conversation modeled by the receiver.
 @discussion Layer conversations are addressed using the user identifiers of the host application. These user ID's are transmitted to
 Layer as part of the Identity Token during authentication. User ID's are commonly modeled as the primary key, email address, or username
 of a given user withinin the backend application acting as the identity provider for the Layer-enabled mobile application.
 */
@property (nonatomic, readonly) NSSet *participants;

/**
 @abstract A dictionary of metadata about the conversation synchronized among all participants.
 @discussion The metadata is a free-form structure for embedding synchronized data about the conversation that is
 to be shared among the participants. For example, a conversation may have a topic that is assigned by the participants represented
 as a string value within the metadata dictionary.
 */
@property (nonatomic, readonly) NSDictionary *metadata;

/**
 @abstract A dictionary of private, user-specific information about the conversation.
 @discussion The user info is a free-form structure for embedding data about the conversation that is synchronized between all the devices
 of the authenticated user, but is not shared with any other participants. For example, an applicatication may wish to designate certain
 conversations as being favorites of the current user or all the user to annotate the conversation with contextual notes for future reference.
 */
@property (nonatomic, readonly) NSDictionary *userInfo;

/**
 @abstract The date and time that the conversation was created.
 */
@property (nonatomic, readonly) NSDate *createdAt;

@end

@interface LYRNullConversation : LYRConversation
@end