//
//  LSHTTPResponseSerializer.h
//  LayerSample
//
//  Created by Blake Watters on 6/28/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const LSHTTPResponseErrorDomain;

typedef NS_ENUM(NSUInteger, LSHTTPResponseError) {
    LSHTTPResponseErrorInvalidContentType,
    LSHTTPResponseErrorUnexpectedStatusCode,
    LSHTTPResponseErrorClientError,
    LSHTTPResponseErrorServerError
};

/**
 @abstract The `LSHTTPResponseSerializer` provides a simple interface for deserialzing HTTP responses created in teh `LSAPIManager`.
 */
@interface LSHTTPResponseSerializer : NSObject

/**
 @abstract Deserializes and HTTP response
 @param object A reference to an object that will contain the deserialized response data.
 @param data The serialized HTTP response data received from an operation’s request.
 @param response The HTTP response object received from an operation’s request.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @retrun A boolean value indicating if the operation was successful
 */
+ (BOOL)responseObject:(id *)object withData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError **)error;

@end
