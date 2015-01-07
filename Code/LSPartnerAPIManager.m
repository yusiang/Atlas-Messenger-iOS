//
//  LSJiraManager.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/23/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSPartnerAPIManager.h"
#import "LSHTTPResponseSerializer.h"

@interface LSPartnerAPIManager () <NSURLSessionDelegate>

@property (nonatomic) NSURL *baseURL;
@property (nonatomic) NSURLSession *URLSession;
@property (nonatomic) NSURLSession *uploadSession;

@end

@implementation LSPartnerAPIManager

+ (instancetype)managerWithBaseURL:(NSURL *)baseURL
{
    return [[self alloc] initWithBaseURL:baseURL];
}

- (id)initWithBaseURL:(NSURL *)baseURL
{
    self = [super init];
    if (self) {
        _baseURL = baseURL;
        _URLSession = [self defaultURLSession];
        _uploadSession = [self uploadSession];
    }
    return self;
}

- (NSURLSession *)uploadSession
{
    NSData *nsdata = [@"kevin:kfc1coleman" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedCreds = [nsdata base64EncodedStringWithOptions:0];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{ @"Accept": @"application/json",
                                             @"X-Atlassian-Token" : @"nocheck",
                                             @"Authorization": [NSString stringWithFormat:@"Basic %@", base64EncodedCreds]};
    return [NSURLSession sessionWithConfiguration:configuration];
}

- (NSURLSession *)defaultURLSession
{
    NSData *nsdata = [@"kevin:kfc1coleman" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedCreds = [nsdata base64EncodedStringWithOptions:0];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{ @"Accept": @"application/json",
                                             @"Content-Type": @"application/json",
                                             @"Authorization": [NSString stringWithFormat:@"Basic %@", base64EncodedCreds]};
    return [NSURLSession sessionWithConfiguration:configuration];
}


- (void)postIssueWithPhoto:(UIImage *)photo summary:(NSString *)summary description:(NSString *)description
{
    NSDictionary *parameters = @{@"fields":
                                    @{@"project":
                                         @{@"key": @"DES"},
                                      @"summary": summary,
                                      @"description": description,
                                      @"issuetype":
                                          @{@"name": @"Bug" }}};
    NSURL *URL = [NSURL URLWithString:@"rest/api/2/issue/" relativeToURL:self.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSLog(@"Got response: %@, data: %@, error: %@", response, data, error);
        if (!response && error) {
            NSLog(@"Failed with error: %@", error);
            return;
        }
        
        NSError *serializationError = nil;
        NSDictionary *userDetails = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
        BOOL success = [LSHTTPResponseSerializer responseObject:&userDetails withData:data response:(NSHTTPURLResponse *)response error:&serializationError];
        if (success) {
            [self attachImage:photo toIssue:[userDetails valueForKey:@"id"]];
        } else {
         
        }
    }] resume];
}

- (void)attachImage:(UIImage *)image toIssue:(NSString *)issue
{
    NSString *issueURL = [NSString stringWithFormat:@"rest/api/2/issue/%@/attachments", issue];
    NSURL *URL = [NSURL URLWithString:issueURL relativeToURL:self.baseURL];
    NSMutableURLRequest *request = [self photoBodyWithImage:image url:URL];
    
    [[self.uploadSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSLog(@"Got response: %@, data: %@, error: %@", response, data, error);
        if (!response && error) {
            NSLog(@"Failed with error: %@", error);
            return;
        }
        
        NSError *serializationError = nil;
        NSDictionary *userDetails = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
        BOOL success = [LSHTTPResponseSerializer responseObject:&userDetails withData:data response:(NSHTTPURLResponse *)response error:&serializationError];
        if (success) {
            
        } else {
            
        }
    }] resume];
}

- (NSMutableURLRequest *)photoBodyWithImage:(UIImage *)image url:(NSURL *)URL
{
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    //[request addValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"photo.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:UIImagePNGRepresentation(image)]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
    return request;
}



@end

