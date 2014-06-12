//
//  LYRThriftHTTPResponseSerializer.h
//  
//
//  Created by Klemen Verdnik on 5/30/14.
//
//

#import "LYRHTTPResponseSerializer.h"

/**
 The `LYRThriftHTTPResponseSerializer` provides an interface for easily and thoroughly processing an HTTP
 response returned by the Layer backend HTTP API. It fully validates the response MIME Type and status
 code and provides support for deserializing server returned errors into `NSError` representations.
 
 Please see the `LYRHTTPErrorCode` enum for a reference of the error codes one can expect to encounter
 when working with the serializer.
 */
@interface LYRThriftHTTPResponseSerializer : LYRHTTPResponseSerializer

/**
 Deserializes a given response and body data into a Foundation object representation or constructs an `NSError`
 detailing why deserialization was not possible.
 
 @param responseObject A pointer to an object that, upon success, is set to a Foundation object representation of the response data.
 @param thriftResponseClass A Thrift auto-generated object's class reference
 @param response The HTTP response associated with the response data.
 @param data The data associated with the given response. Expected to be in JSON format for deserialization to succeed.
 @param error A pointer to an error object that, upon failure, is set to an `NSError` object representation the nature of the failure.
 */
+ (BOOL)responseObject:(id *)responseObject
			   ofClass:(Class)thriftResponseClass
           forResponse:(NSHTTPURLResponse *)response
                  data:(NSData *)data
                 error:(NSError *__autoreleasing *)error;

@end
