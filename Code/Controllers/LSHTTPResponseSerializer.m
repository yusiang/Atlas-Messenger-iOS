//
//  LSHTTPResponseSerializer.m
//  LayerSample
//
//  Created by Blake Watters on 6/28/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSHTTPResponseSerializer.h"

NSString *const LSHTTPResponseErrorDomain = @"com.layer.LSSample.HTTPResponseError";
static NSRange const LSHTTPSuccessStatusCodeRange = {200, 100};
static NSRange const LSHTTPClientErrorStatusCodeRange = {400, 100};
static NSRange const LSHTTPServerErrorStatusCodeRange = {500, 100};

typedef NS_ENUM(NSInteger, LSHTTPResponseStatus) {
    LSHTTPResponseStatusSuccess,
    LSHTTPResponseStatusClientError,
    LSHTTPResponseStatusServerError,
    LSHTTPResponseStatusOther,
};

static LSHTTPResponseStatus LSHTTPResponseStatusFromStatusCode(NSInteger statusCode)
{
    if (NSLocationInRange(statusCode, LSHTTPSuccessStatusCodeRange)) return LSHTTPResponseStatusSuccess;
    if (NSLocationInRange(statusCode, LSHTTPClientErrorStatusCodeRange)) return LSHTTPResponseStatusClientError;
    if (NSLocationInRange(statusCode, LSHTTPServerErrorStatusCodeRange)) return LSHTTPResponseStatusServerError;
    return LSHTTPResponseStatusOther;
}

static NSString *LSHTTPErrorMessageFromErrorRepresentation(id representation)
{
    if ([representation isKindOfClass:[NSString class]]) {
        return representation;
    } else if ([representation isKindOfClass:[NSArray class]]) {
        return [representation componentsJoinedByString:@", "];
    } else if ([representation isKindOfClass:[NSDictionary class]]) {
        // Check for direct error message
        id errorMessage = representation[@"error"];
        if (errorMessage) {
            return LSHTTPErrorMessageFromErrorRepresentation(errorMessage);
        }
        
        // Rails errors in nested dictionary
        id errors = representation[@"errors"];
        if ([errors isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *messages = [NSMutableArray new];
            [errors enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString *description = LSHTTPErrorMessageFromErrorRepresentation(obj);
                NSString *message = [NSString stringWithFormat:@"%@ %@", key, description];
                [messages addObject:message];
            }];
            return [messages componentsJoinedByString:@" "];
        }
    }
    return [NSString stringWithFormat:@"An unknown error representation was encountered. (%@)", representation];
}

@implementation LSHTTPResponseSerializer

+ (BOOL)responseObject:(id *)object withData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError **)error
{
    NSParameterAssert(object);
    NSParameterAssert(response);
    
    if (data.length && ![response.MIMEType isEqualToString:@"application/json"]) {
        NSString *description = [NSString stringWithFormat:@"Expected content type of 'application/json', but encountered a response with '%@' instead.", response.MIMEType];
        if (error) *error = [NSError errorWithDomain:LSHTTPResponseErrorDomain code:LSHTTPResponseErrorInvalidContentType userInfo:@{NSLocalizedDescriptionKey: description}];
        return NO;
    }
    
    LSHTTPResponseStatus status = LSHTTPResponseStatusFromStatusCode(response.statusCode);
    if (status == LSHTTPResponseStatusOther) {
        NSString *description = [NSString stringWithFormat:@"Expected status code of 2xx, 4xx, or 5xx but encountered a status code '%ld' instead.", (long)response.statusCode];
        if (error) *error = [NSError errorWithDomain:LSHTTPResponseErrorDomain code:LSHTTPResponseErrorInvalidContentType userInfo:@{NSLocalizedDescriptionKey: description}];
        return NO;
    }
    
    // No response body
    if (!data.length) {
        if (status != LSHTTPResponseStatusSuccess) {
            if (error) *error = [NSError errorWithDomain:LSHTTPResponseErrorDomain code:(status == LSHTTPResponseStatusClientError ? LSHTTPResponseErrorClientError : LSHTTPResponseErrorServerError) userInfo:@{NSLocalizedDescriptionKey: @"An error was encountered without a response body."}];
            return NO;
        } else {
            // Successful response with no data (typical of a 204 (No Content) response)
            *object = nil;
            return YES;
        }
    }
    
    // We have response body and passed Content-Type checks, deserialize it
    NSError *serializationError;
    id deserializedResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
    if (!deserializedResponse) {
        if (error) *error = serializationError;
        return NO;
    }
    
    if (status != LSHTTPResponseStatusSuccess) {
        NSString *errorMessage = LSHTTPErrorMessageFromErrorRepresentation(deserializedResponse);
        if (error) *error = [NSError errorWithDomain:LSHTTPResponseErrorDomain code:(status == LSHTTPResponseStatusClientError ? LSHTTPResponseErrorClientError : LSHTTPResponseErrorServerError) userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
        return NO;
    }
    
    *object = deserializedResponse;
    return YES;
}

@end
