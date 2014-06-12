//
//  LYRHTTPResponseSerializer.m
//  
//
//  Created by Klemen Verdnik on 5/30/14.
//
//

#import "LYRHTTPResponseSerializer.h"
#include <sys/types.h>
#include <sys/sysctl.h>

NSString *const LYRHTTPErrorDomain = @"com.layer.LayerKit.HTTP";
NSString *const LYRHTTPErrorFailingURLResponseErrorKey = @"response";
NSString *const LYRHTTPErrorFailingURLResponseObjectExceptionKey = @"exception";
NSString *const LYRHTTPErrorFailingURLResponseObjectErrorKey = @"responseObject";
NSString *const LYRHTTPErrorFailingURLResponseObjectDataErrorKey = @"data";
NSString *const LYRHTTPErrorFailingURLResponseObjectMessageErrorKey = @"message";
NSString *const LYRHTTPErrorFailingURLResponseObjectStatusErrorKey = @"status";

NSString *LYRHardwareModelString()
{
    size_t size = 100;
    char *hw_machine = malloc(size);
    int name[] = {CTL_HW,HW_MACHINE};
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    return hardware;
}

// Format is: iPhone/5.1 iOS/7.1 LayerSDK/1.0 UltraApp/3.2.1
NSString *LYRHTTPUserAgentString()
{
    NSString *sanitizedHardwareString = nil;
    NSString *hardwareString = LYRHardwareModelString();
    if ([@[ @"i386", @"x86_64" ] containsObject:hardwareString]) {
        sanitizedHardwareString = @"iOS_Simulator";
    } else {
        NSRange range = [hardwareString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        NSString *model = [hardwareString substringToIndex:range.location - 1];
        NSString *version = [[hardwareString substringFromIndex:range.location - 1] stringByReplacingOccurrencesOfString:@"," withString:@"."];
        sanitizedHardwareString = [@[ model, version ] componentsJoinedByString:@"/"];
    }
    NSString *systemName = [[UIDevice currentDevice] systemName];
    if ([systemName isEqualToString:@"iPhone OS"]) {
        systemName = @"iOS";
    }
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey];
    NSString *appVersion = (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey];
    
    return [NSString stringWithFormat:@"%@ %@/%@ LayerSDK/1.0 %@/%@",
            sanitizedHardwareString,
            systemName,
            [[UIDevice currentDevice] systemVersion],
            appName,
            appVersion];
}

NSRange LYRHTTPRangeForStatusCodeClass(LYRHTTPStatusCodeClass statusCodeClass)
{
    return NSMakeRange(statusCodeClass, 100);
}

BOOL LYRHTTPIsResponseInStatusCodeClass(NSURLResponse *response, LYRHTTPStatusCodeClass statusCodeClass)
{
    if (! [response isKindOfClass:[NSHTTPURLResponse class]]) [NSException raise:NSInternalInconsistencyException format:@"Attempt to check status code on response that is not a `NSHTTPURLResponse`."];
    return NSLocationInRange([(NSHTTPURLResponse *)response statusCode], LYRHTTPRangeForStatusCodeClass(statusCodeClass));
}

NSRegularExpression *LYRRegularExpressionWithString(NSString *pattern)
{
    NSError *error;
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    if (!regEx) [NSException raise:NSInternalInconsistencyException format:@"Attempt to generate a regular expression with the pattern: '%@' but failed with %@", pattern, error];
    return regEx;
}

@implementation LYRHTTPResponseSerializer

+ (BOOL)isValidResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError **)error
{
    // Check if the response object is of correct class
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) [NSException raise:NSInternalInconsistencyException format:@"Attempt to validate response that is not a `NSHTTPURLResponse`."];
    
    // Check if the response Status Code is acceptable
    if (![[[self class] acceptableStatusCodes] containsIndex:response.statusCode]) {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Unacceptable response Status Code: %@ (%lu)", [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], response.statusCode],
                                   NSURLErrorFailingURLErrorKey:response.URL,
                                   LYRHTTPErrorFailingURLResponseErrorKey:response,
                                   LYRHTTPErrorFailingURLResponseObjectDataErrorKey:data
                                   };
        if (error) *error = [NSError errorWithDomain:LYRHTTPErrorDomain code:LYRHTTPErrorUnexpectedStatusCode userInfo:userInfo];
        return NO;
    }
    
    // Check if the response Content Type is acceptable
    BOOL typeMatches = NO;
    for (NSString *pattern in [[self class] acceptableContentTypes]) {
        NSRegularExpression *regex = LYRRegularExpressionWithString(pattern);
        NSTextCheckingResult *match = [regex firstMatchInString:response.MIMEType options:0 range:NSMakeRange(0, [response.MIMEType length])];
        if (match){
            typeMatches = YES;
            break;
        }
    }
    if (!typeMatches) {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Unacceptable Content-Type: %@ (%lu)", response.MIMEType],
                                   NSURLErrorFailingURLErrorKey:response.URL,
                                   LYRHTTPErrorFailingURLResponseErrorKey:response,
                                   LYRHTTPErrorFailingURLResponseObjectDataErrorKey:data
                                   };
        if (error) *error = [NSError errorWithDomain:LYRHTTPErrorDomain code:LYRHTTPErrorUnprocessableContentType userInfo:userInfo];
        return NO;
    }
    
    return YES;
}

@end
