//
//  LYRJSONHTTPResponseSerializer.m
//  
//
//  Created by Klemen Verdnik on 5/30/14.
//
//

#import "LYRJSONHTTPResponseSerializer.h"

@implementation LYRJSONHTTPResponseSerializer

+ (NSIndexSet *)acceptableStatusCodes
{
    NSMutableIndexSet *JSONStatusCodes = [NSMutableIndexSet indexSet];
    [JSONStatusCodes addIndexesInRange:NSMakeRange(LYRHTTPStatusCodeClassSuccess, 100)];
    [JSONStatusCodes addIndexesInRange:NSMakeRange(LYRHTTPStatusCodeClassClientError, 100)];
    [JSONStatusCodes addIndexesInRange:NSMakeRange(LYRHTTPStatusCodeClassServerError, 100)];
    return JSONStatusCodes;
}

+ (NSSet *)acceptableContentTypes
{
    return [NSSet setWithArray:@[@"^application/json", @"^text/json"]];
}

+ (BOOL)responseObject:(id *)responseObject
           forResponse:(NSHTTPURLResponse *)response
                  data:(NSData *)data
                 error:(NSError *__autoreleasing *)error
{
    // Validate if response has an acceptable content-type and status code
    if (![[self class] isValidResponse:response data:data error:error]) return NO;
    
    // Deserialize the response (if possible)
    id deserializedResponseObject = nil;
    if (data && [data length]) {
        deserializedResponseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
        if (! deserializedResponseObject) {
            // Deserialization failure
            return NO;
        }
        if (responseObject) *responseObject = deserializedResponseObject;
    }
    
    if (LYRHTTPIsResponseInStatusCodeClass(response, LYRHTTPStatusCodeClassSuccess)) {
        // Deserialized successfully, return the object for processing
        return YES;
    } else if (LYRHTTPIsResponseInStatusCodeClass(response, LYRHTTPStatusCodeClassClientError) ||
               LYRHTTPIsResponseInStatusCodeClass(response, LYRHTTPStatusCodeClassServerError)) {
        
        // Validate that the error is of the expected structure
        if (! [deserializedResponseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedStringFromTable(@"Request failed: %@ (%lu)", @"LayerKit", nil), [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], (unsigned long)response.statusCode],
                                       NSURLErrorFailingURLErrorKey:[response URL],
                                       LYRHTTPErrorFailingURLResponseErrorKey: response,
                                       LYRHTTPErrorFailingURLResponseObjectErrorKey: (deserializedResponseObject ?: [NSNull null])
                                       };
            if (error) *error = [NSError errorWithDomain:LYRHTTPErrorDomain code:LYRHTTPErrorInvalidResponseObject userInfo:userInfo];
            return NO;
        }
        
        // Return server error
        NSDictionary *responseError = (NSDictionary *)deserializedResponseObject;
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedStringFromTable(@"Request failed: %@ (%lu): %@", @"LayerKit", nil), [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], (unsigned long)response.statusCode, responseError[@"message"]],
                                   NSURLErrorFailingURLErrorKey:[response URL],
                                   LYRHTTPErrorFailingURLResponseErrorKey: response,
                                   LYRHTTPErrorFailingURLResponseObjectErrorKey: responseError,
                                   LYRHTTPErrorFailingURLResponseObjectMessageErrorKey: responseError[@"message"],
                                   LYRHTTPErrorFailingURLResponseObjectStatusErrorKey: responseError[@"status"]
                                   };
        
        NSInteger errorCode = LYRHTTPIsResponseInStatusCodeClass(response, LYRHTTPStatusCodeClassClientError) ? LYRHTTPErrorRemoteSystemRejection : LYRHTTPErrorRemoteSystemFailure;
        if (error) *error = [NSError errorWithDomain:LYRHTTPErrorDomain code:errorCode userInfo:userInfo];
        return NO;
    }
    
    return NO;
}

@end
