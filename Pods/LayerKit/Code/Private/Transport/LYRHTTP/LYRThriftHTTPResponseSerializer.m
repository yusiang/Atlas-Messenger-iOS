//
//  LYRThriftHTTPResponseSerializer.m
//  
//
//  Created by Klemen Verdnik on 5/30/14.
//
//

#import "LYRThriftHTTPResponseSerializer.h"
#import "TMemoryBuffer.h"
#import "TCompactProtocol.h"
#import "TBase.h"
#import "messaging.h"

///----------------------------------
/// @name JSON Response Serialization
///----------------------------------

@implementation LYRThriftHTTPResponseSerializer

+ (NSIndexSet *)acceptableStatusCodes
{
    NSMutableIndexSet *JSONStatusCodes = [NSMutableIndexSet indexSet];
    [JSONStatusCodes addIndexesInRange:NSMakeRange(LYRHTTPStatusCodeClassSuccess, 100)];
    return JSONStatusCodes;
}

+ (NSSet *)acceptableContentTypes
{
    return [NSSet setWithArray:@[@"^application/vnd.layer.messaging", @"^(application/vnd.layer.messaging+octet-stream)"]];
}

+ (BOOL)responseObject:(id *)responseObject
			   ofClass:(Class)thriftResponseClass
           forResponse:(NSHTTPURLResponse *)response
                  data:(NSData *)data
                 error:(NSError *__autoreleasing *)error
{
    // Validate if response has an acceptable content-type and status code
    if (![[self class] isValidResponse:response data:data error:error]) return NO;
    
    // Check if the class reference conforms to TBase
    if (![thriftResponseClass conformsToProtocol:@protocol(TBase)]) [NSException raise:NSInternalInconsistencyException format:@"Attempt to deserialize into an object of class `%@` that doesn't conform to the `TBase` protocol.", thriftResponseClass];

    // Deserialize the response (if possible)
    id<TBase> deserializedResponseObject;
    if (data && [data length]) {
        NSError *deserializationError;
        
        // Prepare a Thrift compact protocol
        TMemoryBuffer *memoryBuffer = [[TMemoryBuffer alloc] initWithData:data];
        TCompactProtocol *compactProtocol = [[TCompactProtocol alloc] initWithTransport:memoryBuffer];
        deserializedResponseObject = [thriftResponseClass new];
        
        // Perform deserialization
        @try {
            [deserializedResponseObject read:compactProtocol];
        }
        @catch (NSException *exception) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to deserialize a Thrift HTTP response: %@ (%lu): %@", [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], (unsigned long)response.statusCode, exception.reason],
                                       NSURLErrorFailingURLErrorKey:[response URL],
                                       LYRHTTPErrorFailingURLResponseErrorKey: response,
                                       LYRHTTPErrorFailingURLResponseObjectExceptionKey: exception,
                                       LYRHTTPErrorFailingURLResponseObjectMessageErrorKey: exception.reason
                                       };
            deserializationError = [NSError errorWithDomain:LYRHTTPErrorDomain code:LYRHTTPErrorInvalidResponseObject userInfo:userInfo];
        }
        
        // Deserialization failure
        if (deserializationError) {
            if (error) *error = deserializationError;
            return NO;
        }
    }
    
    // If an exception is found in the deserialized object, generate an error for it
    if ([deserializedResponseObject respondsToSelector:@selector(errorIsSet)] && [(NSNumber *)[(id)deserializedResponseObject valueForKey:@"errorIsSet"] boolValue]) {
        LYRTError *thriftError = [(id)deserializedResponseObject valueForKey:@"error"];
        
        // Generate error
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Request failed: %@ (%lu): %@", [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], (unsigned long)response.statusCode, thriftError.message],
                                   NSURLErrorFailingURLErrorKey:[response URL],
                                   LYRHTTPErrorFailingURLResponseErrorKey: response,
                                   LYRHTTPErrorFailingURLResponseObjectMessageErrorKey: thriftError.message,
                                   LYRHTTPErrorFailingURLResponseObjectStatusErrorKey: @(thriftError.code)
                                   };
        
        if (error) *error = [NSError errorWithDomain:LYRHTTPErrorDomain code:LYRHTTPErrorRemoteSystemRejection userInfo:userInfo];
        return NO;
    }
    
    // Response is clean and good to go!
    if (responseObject) *responseObject = deserializedResponseObject;
    return YES;
}

@end
