//
//  LYRAuthenticationChallenge.h
//  
//
//  Created by Blake Watters on 5/16/14.
//
//

#import <Foundation/Foundation.h>

/**
 @abstract Models an Authentication Challenge encountered during a network interaction with Layer via SPDY or HTTP.
 */
@interface LYRAuthenticationChallenge : NSObject

/**
 @abstract Returns an authentication challenge with the given response or `nil` if the response does not contain a challenge.
 @param response An HTTP response returned by Layer. Cannot be `nil`.
 */
+ (instancetype)authenticationChallengeWithResponse:(NSHTTPURLResponse *)response;

///-------------------------------------
/// @name Accessing Challenge Properties
///-------------------------------------

/**
 @abstract Returns the Authentication Realm.
 */
@property (nonatomic, readonly) NSString *realm;

/**
 @abstract Returns the Layer App ID associated with the challenge.
 */
@property (nonatomic, readonly) NSString *appID;

/**
 @abstract Returns the Authentication Nonce issued with the challenge.
 */
@property (nonatomic, readonly) NSString *nonce;

/**
 @abstract The URL the reuqest was made to when it hit the auth challenge.
 */
@property (nonatomic, readonly) NSURL *URL;

///----------------------------------------
/// @name Returning an Error Representation
///----------------------------------------

/**
 @abstract Returns an error object representation of the receiver.
 @discussion The error returned is in the `LYRTransportError` domain and has an error code of `LYRTransportErrorAuthenticationChallenge`. The
 user info contains the challenge details.
 */
- (NSError *)errorRespresentation;

@end
