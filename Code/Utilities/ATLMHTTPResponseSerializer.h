//
//  ATLMHTTPResponseSerializer.h
//  Atlas Messenger
//
//  Created by Blake Watters on 6/28/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const ATLMHTTPResponseErrorDomain;

typedef NS_ENUM(NSUInteger, ATLMHTTPResponseError) {
    ATLMHTTPResponseErrorInvalidContentType,
    ATLMHTTPResponseErrorUnexpectedStatusCode,
    ATLMHTTPResponseErrorClientError,
    ATLMHTTPResponseErrorServerError
};

/**
 @abstract The `ATLMHTTPResponseSerializer` provides a simple interface for deserializing HTTP responses created in the `ATLMAPIManager`.
 */
@interface ATLMHTTPResponseSerializer : NSObject

/**
 @abstract Deserializes an HTTP response.
 @param object A reference to an object that will contain the deserialized response data.
 @param data The serialized HTTP response data received from an operation's request.
 @param response The HTTP response object received from an operation's request.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A boolean value indicating if the operation was successful.
 */
+ (BOOL)responseObject:(id *)object withData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError **)error;

@end
