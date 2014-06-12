//
//  LYRHTTPResponseSerializer.h
//  
//
//  Created by Klemen Verdnik on 5/30/14.
//
//

#import <Foundation/Foundation.h>

///------------------
/// @name HTTP Errors
///------------------

/**
 Error codes returned by the LYRHTTP classes.
 
 Note that LYRHTTP classes may also return errors from other domains (such as the `NSURLErrorDomain`).
 */
typedef NS_ENUM(NSInteger, LYRHTTPErrorCode) {
    /// Indicates that a response with a non-acceptable type was encountered
    LYRHTTPErrorUnprocessableContentType = 8000,
    
    /// Indicates that a response with a status code outside the acceptable status code set encountered
    LYRHTTPErrorUnexpectedStatusCode     = 8001,
    
    /// Indicates that the remote system returned a 4xx status code with a JSON error
    LYRHTTPErrorRemoteSystemRejection    = 8002,
    
    /// Indicates that the remote system returned a 5xx status code with a JSON error
    LYRHTTPErrorRemoteSystemFailure      = 8003,
    
    /// Indicates that the remote system returned a valid response as expected, but it was not able to deserialize it
    LYRHTTPErrorInvalidResponseObject    = 8004
};

/// The domain for HTTP errors
extern NSString *const LYRHTTPErrorDomain;

/// A key into the user info dictionary of an error in the `LYRHTTPErrorDomain` domain for retrieving the `NSURLResponse` associated with the error
extern NSString *const LYRHTTPErrorFailingURLResponseErrorKey;

/// The 'exception' that was caused in the deserialization process
extern NSString *const LYRHTTPErrorFailingURLResponseObjectExceptionKey;

/// The deserialized error object
extern NSString *const LYRHTTPErrorFailingURLResponseObjectErrorKey;

/// The 'data' response of the data task
extern NSString *const LYRHTTPErrorFailingURLResponseObjectDataErrorKey;

/// The 'message' field in a serialized response error
extern NSString *const LYRHTTPErrorFailingURLResponseObjectMessageErrorKey;

/// The 'status' field in a serialized response error
extern NSString *const LYRHTTPErrorFailingURLResponseObjectStatusErrorKey;

///------------------------
/// @name Utility Functions
///------------------------

/**
 Returns the user-agent string for the current application.
 */
NSString *LYRHTTPUserAgentString();

/// Defines classes for typical HTTP status codes
typedef NS_ENUM(NSInteger, LYRHTTPStatusCodeClass) {
    LYRHTTPStatusCodeClassSuccess       = 200,  // 200-299
    LYRHTTPStatusCodeClassRedirection   = 300,  // 300-399
    LYRHTTPStatusCodeClassClientError   = 400,  // 400-499
    LYRHTTPStatusCodeClassServerError   = 500   // 500-599
};

/**
 Returns a range for status codes in the given class
 
 @param statusCodeClass The HTTP status code class for which to return a range.
 @return A new range covering status codes in the requested class.
 */
NSRange LYRHTTPRangeForStatusCodeClass(LYRHTTPStatusCodeClass statusCodeClass);

/**
 A convenience function for testing if the status code of a given response falls within a given class.
 
 @param response The URL response to test the status code of.
 @param statusCodeClass The HTTP status code class to test for inclusion of the response status code.
 @return A Boolean value indicating if the status code of the given response object falls within the specified HTTP status code range.
 */
BOOL LYRHTTPIsResponseInStatusCodeClass(NSURLResponse *response, LYRHTTPStatusCodeClass statusCodeClass);

/**
 A convenience function that generates an instance of `NSRegularExpression` based on an input string.
 
 @param pattern An `NSString` instance of the regular expression pattern.
 @return An instance of the `NSRegularExpression` if the function generated the instance succesffully; otherwise `nil`.
 */
NSRegularExpression *LYRRegularExpressionWithString(NSString *pattern);

@interface LYRHTTPResponseSerializer : NSObject

+ (NSIndexSet *)acceptableStatusCodes;
+ (NSSet *)acceptableContentTypes;

+ (BOOL)isValidResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError **)error;

@end
