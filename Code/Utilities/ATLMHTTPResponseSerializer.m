//
//  ATLMHTTPResponseSerializer.m
//  Atlas Messenger
//
//  Created by Blake Watters on 6/28/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "ATLMHTTPResponseSerializer.h"

NSString *const ATLMHTTPResponseErrorDomain = @"com.layer.LSSample.HTTPResponseError";
static NSRange const ATLMHTTPSuccessStatusCodeRange = {200, 100};
static NSRange const ATLMHTTPClientErrorStatusCodeRange = {400, 100};
static NSRange const ATLMHTTPServerErrorStatusCodeRange = {500, 100};

typedef NS_ENUM(NSInteger, ATLMHTTPResponseStatus) {
    ATLMHTTPResponseStatusSuccess,
    ATLMHTTPResponseStatusClientError,
    ATLMHTTPResponseStatusServerError,
    ATLMHTTPResponseStatusOther,
};

static ATLMHTTPResponseStatus ATLMHTTPResponseStatusFromStatusCode(NSInteger statusCode)
{
    if (NSLocationInRange(statusCode, ATLMHTTPSuccessStatusCodeRange)) return ATLMHTTPResponseStatusSuccess;
    if (NSLocationInRange(statusCode, ATLMHTTPClientErrorStatusCodeRange)) return ATLMHTTPResponseStatusClientError;
    if (NSLocationInRange(statusCode, ATLMHTTPServerErrorStatusCodeRange)) return ATLMHTTPResponseStatusServerError;
    return ATLMHTTPResponseStatusOther;
}

static NSString *ATLMHTTPErrorMessageFromErrorRepresentation(id representation)
{
    if ([representation isKindOfClass:[NSString class]]) {
        return representation;
    } else if ([representation isKindOfClass:[NSArray class]]) {
        return [representation componentsJoinedByString:@", "];
    } else if ([representation isKindOfClass:[NSDictionary class]]) {
        // Check for direct error message
        id errorMessage = representation[@"error"];
        if (errorMessage) {
            return ATLMHTTPErrorMessageFromErrorRepresentation(errorMessage);
        }
        
        // Rails errors in nested dictionary
        id errors = representation[@"errors"];
        if ([errors isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *messages = [NSMutableArray new];
            [errors enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString *description = ATLMHTTPErrorMessageFromErrorRepresentation(obj);
                NSString *message = [NSString stringWithFormat:@"%@ %@", key, description];
                [messages addObject:message];
            }];
            return [messages componentsJoinedByString:@" "];
        }
    }
    return [NSString stringWithFormat:@"An unknown error representation was encountered. (%@)", representation];
}

@implementation ATLMHTTPResponseSerializer

+ (BOOL)responseObject:(id *)object withData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError **)error
{
    NSParameterAssert(object);
    NSParameterAssert(response);
    
    if (data.length && ![response.MIMEType isEqualToString:@"application/json"]) {
        NSString *description = [NSString stringWithFormat:@"Expected content type of 'application/json', but encountered a response with '%@' instead.", response.MIMEType];
        if (error) *error = [NSError errorWithDomain:ATLMHTTPResponseErrorDomain code:ATLMHTTPResponseErrorInvalidContentType userInfo:@{NSLocalizedDescriptionKey: description}];
        return NO;
    }
    
    ATLMHTTPResponseStatus status = ATLMHTTPResponseStatusFromStatusCode(response.statusCode);
    if (status == ATLMHTTPResponseStatusOther) {
        NSString *description = [NSString stringWithFormat:@"Expected status code of 2xx, 4xx, or 5xx but encountered a status code '%ld' instead.", (long)response.statusCode];
        if (error) *error = [NSError errorWithDomain:ATLMHTTPResponseErrorDomain code:ATLMHTTPResponseErrorInvalidContentType userInfo:@{NSLocalizedDescriptionKey: description}];
        return NO;
    }
    
    // No response body
    if (!data.length) {
        if (status != ATLMHTTPResponseStatusSuccess) {
            if (error) *error = [NSError errorWithDomain:ATLMHTTPResponseErrorDomain code:(status == ATLMHTTPResponseStatusClientError ? ATLMHTTPResponseErrorClientError : ATLMHTTPResponseErrorServerError) userInfo:@{NSLocalizedDescriptionKey: @"An error was encountered without a response body."}];
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
    
    if (status != ATLMHTTPResponseStatusSuccess) {
        NSString *errorMessage = ATLMHTTPErrorMessageFromErrorRepresentation(deserializedResponse);
        if (error) *error = [NSError errorWithDomain:ATLMHTTPResponseErrorDomain code:(status == ATLMHTTPResponseStatusClientError ? ATLMHTTPResponseErrorClientError : ATLMHTTPResponseErrorServerError) userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
        return NO;
    }
    
    *object = deserializedResponse;
    return YES;
}

@end
