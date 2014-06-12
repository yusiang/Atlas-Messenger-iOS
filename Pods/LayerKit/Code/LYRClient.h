//
//  LYRClient.h
//  LayerKit
//
//  Created by Klemen Verdnik on 7/23/13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRConversation.h"
#import "LYRMessage.h"
#import "LYRMessagePart.h"

@class LYRClient;

extern NSString *const LYRClientDidAuthenticateNotification;
extern NSString *const LYRClientAuthenticatedUserIDUserInfoKey;
extern NSString *const LYRClientDidDeauthenticateNotification;

#pragma mark - Client Delegate

/**
 The `LYRClientDelegate` protocol provides a method for notifying the adopting delegate about information changes.
 */

@protocol LYRClientDelegate <NSObject>

@required

/**
 @abstract Tells the delegate that the server has issued an authentication challenge to the client and a new Identity Token must be submitted.
 @discussion At any time during the lifecycle of a Layer client session the server may issue an authentication challenge and require that
    the client confirm its identity. When such a challenge is encountered, the client will immediately become deauthenticated and will no
    longer be able to interact with communication services until reauthenticated. The nonce value issued with the challenge must be submitted
    to the remote identity provider in order to obtain a new Identity Token.
 @see LayerClient#authenticateWithIdentityToken:completion:
 @param client The client that received the authentication challenge.
 @param nonce The nonce value associated with the challenge.
 */
- (void)layerClient:(LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce;

@optional
/**
 @abstract Tells the delegate that a client has successfully authenticated with Layer.
 @param client The client that has authenticated successfully.
 @param userID The user identifier in Identity Provider from which the Identity Token was obtained. Typically the primary key, username, or email
    of the user that was authenticated.
 */
- (void)layerClient:(LYRClient *)client didAuthenticateAsUserID:(NSString *)userID;

/**
 @abstract Tells the delegate that a client has been deauthenticated.
 @discussion The client may become deauthenticated either by an explicit call to `deauthenticateWithCompletion:` or by encountering an authentication challenge.
 @param client The client that was deauthenticated.
 */
- (void)layerClientDidDeauthenticate:(LYRClient *)client;

@end


#pragma mark - Client

/**
 The Layer client runs as a singleton inside the application and is accessible through the `sharedClient` method. All the methods are accessible as methods on the `sharedClient` object.
 Before starting the `sharedClient`, make sure you specify your app key. If you don't have an app key yet you can create one on Layer's administration pages http://layer.com/admin.
 */

@interface LYRClient : NSObject

+ (instancetype)clientWithAppID:(NSUUID *)appID;

/**
 @abstract The object that acts as the delegate of the receiving client.
 */
@property (nonatomic, weak) id <LYRClientDelegate> delegate;

/**
 @abstract The app key.
 */
@property (nonatomic, copy, readonly) NSUUID *appID;

/**
 @abstract Signals the receiver to establish a network connection and sync all the data.
 */
- (void)startWithCompletion:(void (^)(BOOL success, NSError *error))completion;

/**
 @abstract Signals the receiver to end the established network connection.
 */
- (void)stop;

///--------------------------
/// @name User Authentication
///--------------------------

/**
 @abstract Returns a Boolean value that indicates if the client is authenticated with Layer.
 @discussion A client is considered authenticated if it has previously established identity via the submission of an identity token
    and the token has not yet expired. The Layer server may at any time issue an authentication challenge and deauthenticate the client.
 */
@property (nonatomic, readonly) BOOL isAuthenticated;

/**
 @abstract Requests an authentication nonce from Layer.
 @discussion Authenticating a Layer client requires that an Identity Token be obtained from a remote backend application that has been designated to act as an
 Identity Provider on behalf of your application. When requesting an Identity Token from a provider, you are required to provide a nonce value that will be included
 in the cryptographically signed data that comprises the Identity Token. This method asynchronously requests such a nonce value from Layer.
 @warning Nonce values can be issued by Layer at any time in the form of an authentication challenge. You must be prepared to handle server issued nonces as well as those
 explicitly requested by a call to `requestAuthenticationNonceWithCompletion:`.
 @param completion A block to be called upon completion of the asynchronous request for a nonce. The block takes two parameters: the nonce value that was obtained (or `nil`
 in the case of failure) and an error object that upon failure describes the nature of the failure.
 @see LYRClientDelegate#layerClient:didReceiveAuthenticationChallengeWithNonce:
 */
- (void)requestAuthenticationNonceWithCompletion:(void (^)(NSString *nonce, NSError *error))completion;

/**
 @abstract Authenticates the client by submitting an Identity Token to Layer for evaluation.
 @discussion Authenticating a Layer client requires the submission of an Identity Token from a remote backend application that has been designated to act as an
    Identity Provider on behalf of your application. The Identity Token is a JSON Web Signature (JWS) string that encodes a cryptographically signed set of claims
    about the identity of a Layer client. An Identity Token must be obtained from your provider via an application defined mechanism (most commonly a JSON over HTTP
    request). Once an Identity Token has been obtained, it must be submitted to Layer via this method in ordr to authenticate the client and begin utilizing communication 
    services. Upon successful authentication, the client remains in an authenticated state until explicitly deauthenticated by a call to `deauthenticateWithCompletion:` or
    via a server-issued authentication challenge.
 @param identityToken A string object encoding a JSON Web Signature that asserts a set of claims about the identity of the client. Must be obtained from a remote identity
    provider and include a nonce value that was previously obtained by a call to `requestAuthenticationNonceWithCompletion:` or via a server initiated authentication challenge.
 @param completion A block to be called upon completion of the asynchronous request for authentication. The block takes two parameters: a string encoding the remote user ID that
    was authenticated (or `nil` if authentication was unsuccessful) and an error object that upon failure describes the nature of the failure.
 @see http://tools.ietf.org/html/draft-ietf-jose-json-web-signature-25
 */
- (void)authenticateWithIdentityToken:(NSString *)identityToken completion:(void (^)(NSString *authenticatedUserID, NSError *error))completion;

/**
 @abstract Deauthenticates the client, disposing of any previously established user identity and disallowing access to the Layer communication services until a new identity is established.
 @param completion An optional block to be executed upon completion of the deauthentication request.
 */
- (void)deauthenticate;

#pragma mark - User

/**
 @abstract Triggers the device token update action.
 @param deviceToken An `NSData` object containing the device token.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A Boolean value that determines whether the action was successful.
 @discussion The device token is expected to be an `NSData` object returned by the method application:didRegisterForRemoteNotificationsWithDeviceToken:. The device token is cached locally and is sent to Layer cloud automatically when the connection is established.
 */
- (BOOL)updateDeviceToken:(NSData *)deviceToken error:(NSError **)error;

#pragma mark - Messaging

///----------------
/// @name Messaging
///----------------

/**
 @abstract Returns a conversation with a given identifier and set of participants.
 @discussion This method provides a flexible mechanism for retrieving or creating conversations. If the `identifier`
 given is `nil`, then an attempt is made to find an existing conversation for the given participants or else a new
 conversation is created. If both the `identifier` and `participants` are non-nil, then an existing conversation is
 returned that matches the identifier and participants or, if no such conversation is found, a new conversation is created. If
 an existing conversation is found for the given identifier but it has a different set of participants, then `nil` is returned.
 @param identifier A unique identifier for the conversation or `nil` if the system should generate one.
 @param participants The set of participants within the conversation.
 @return A conversation with the given identifier and participants or `nil`.
 @raises NSInvalidArgumentException Raised if both the `identifier` and `participants` are `nil`.
 */
- (LYRConversation *)conversationWithIdentifier:(NSString *)identifier participants:(NSArray *)participants;

/**
 @abstract Creates and returns a new message with the given conversation and set of message parts.
 @param conversation The conversation that the message is a part of. Cannot be `nil`.
 @param messageParts An array of `LYRMessagePart` objects specifying the content of the message. Cannot be `nil` or empty.
 @return A new message that is ready to be sent.
 @raises NSInvalidArgumentException Raised if `conversation` is `nil` or `messageParts` is empty.
 */
- (LYRMessage *)messageWithConversation:(LYRConversation *)conversation parts:(NSArray *)messageParts;

/**
 @abstract Creates and returns a new message in reply to a given message with a set of message parts.
 @param message The message that is being replied to, thus implying the conversation. Cannot be `nil`.
 @param messageParts An array of `LYRMessagePart` objects specifying the content of the message. Cannot be `nil` or empty.
 @return A new message that is ready to be sent.
 @raises NSInvalidArgumentException Raised if `conversation` is `nil` or `messageParts` is empty.
 */
- (LYRMessage *)messageInReplyToMessage:(LYRMessage *)message withParts:(NSArray *)messageParts;

/**
 @abstract Sends the specified message.
 @discussion The message is enqueued for delivery during the next synchronization after basic local validation of the message state is performed. Validation
 that may be performed includes checking that the maximum number of participants has not been execeeded and that parts of the message do not have an aggregate
 size in excess of the maximum for a message.
 @param message The message to be sent. Cannot be `nil`.
 @param error A pointer to an error object that, upon failure, will be set to an error describing why the message could not be sent.
 @return A Boolean value indicating if the message passed validation and was enqueued for delivery.
 @raises NSInvalidArgumentException Raised if `message` is `nil`.
 */
- (BOOL)sendMessage:(LYRMessage *)message error:(NSError **)error;


/**
 @abstract Returns an existing conversation with a given identifier or `nil` if none could be found.
 @param identifier The identifier for an existing conversation.
 @returns The conversation with the given identifier or `nil` if none could be found.
 */
//- (LYRConversation *)existingConversationWithIdentifier:(NSString *)identifier;

///--------------------------------------------
/// @name Retrieving Conversations & Messages
///--------------------------------------------

/**
 @abstract Retrieves a collection of conversation objects from the persistent store for the given list of conversation identifiers.
 @discussion The list of conversations returned will be parallel to the list of identifiers given. This means that the conversation objects
 will be returned in the order that the identifier appears in the input array and any identifiers for which there is not a corresponding object
 will have an `LYRNullConversation` entry. These null placeholder objects stand-in for a missing conversation in the result set.
 @param conversationIdentifiers The list of conversation identifiers for which to retrieve the corresponding set of conversation objects. Passing `nil`
 will return all conversations.
 @return An ordered set of conversations objects for the given array of identifiers.
 */
- (NSOrderedSet *)conversationsForIdentifiers:(NSArray *)conversationIdentifiers;

/**
 @abstract Retrieves a collection of message objects from the persistent store for the given list of message identifiers.
 @discussion The list of messages returned will be parallel to the list of identifiers given. This means that the message objects
 will be returned in the order that the identifier appears in the input array and any identifiers for which there is not a corresponding object
 will have an `LYRNullMessage` entry. These null placeholder objects stand-in for a missing conversation in the result set.
 @param messageIdentifiers The list of message identifiers for which to retrieve the corresponding set of message objects. Passing `nil`
 will return all messages.
 @return An ordered set of conversations objects for the given array of identifiers.
 */
- (NSOrderedSet *)messagesForIdentifiers:(NSArray *)messageIdentifiers;

/**
 @abstract Returns the collection of messages in a given conversation.
 @param conversation The conversation to retrieve the set of messages for.
 @return An ordered set of message for the given conversation.
 */
- (NSOrderedSet *)messagesForConversation:(LYRConversation *)conversation;

@end
