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
    }
    return self;
}

- (NSURLSession *)defaultURLSession
{
    NSData *nsdata = [@"kevin:kfc1coleman" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedCreds = [nsdata base64EncodedStringWithOptions:0];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{ @"Accept": @"application/json", @"Content-Type": @"application/json", @"Authorization": [NSString stringWithFormat:@"Basic %@", base64EncodedCreds]};
    return [NSURLSession sessionWithConfiguration:configuration];
}


- (void)postIssueWithPhoto:(UIImage *)photo summary:(NSString *)summary description:(NSString *)description
{
    NSDictionary *parameters = @{
                                 @"fields": @{
                                         @"project": @{ @"key": @"SUPP" },
                                         @"summary": summary,
                                         @"description": description,
                                         @"issuetype": @{ @"name": @"Bug" }
                                         }
                                 };
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

        } else {
         
        }
    }] resume];
    
}

- (void)attachImage:(UIImage *)image toIssue:(NSString *)issue
{
    NSString *issueURL = [NSString stringWithFormat:@"rest/api/2/issue/%@/attachments", @"SUPP-109"];
    NSURL *URL = [NSURL URLWithString:issueURL relativeToURL:self.baseURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [self postImage:image request:request];
//    request.HTTPMethod = @"POST";
//
//    
//    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        
//        NSLog(@"Got response: %@, data: %@, error: %@", response, data, error);
//        if (!response && error) {
//            NSLog(@"Failed with error: %@", error);
//            return;
//        }
//        
//        NSError *serializationError = nil;
//        NSDictionary *userDetails = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
//        BOOL success = [LSHTTPResponseSerializer responseObject:&userDetails withData:data response:(NSHTTPURLResponse *)response error:&serializationError];
//        if (success) {
//            
//        } else {
//            
//        }
//    }] resume];

}

- (NSMutableURLRequest *)photoBodyWithImage:(UIImage *)image request:(NSMutableURLRequest *)request
{
    // We need to add a header field named Content-Type with a value that tells that it's a form and also add a boundary.
    // I just picked a boundary by using one from a previous trace, you can just copy/paste from the traces.
    NSString *boundary = @"----WebKitFormBoundarycC4YiaUFwM44F6rT";
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    // end of what we've added to the header
    
    // the body of the post
    NSMutableData *body = [NSMutableData data];
    
    // Now we need to append the different data 'segments'. We first start by adding the boundary.
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Now append the image
    // Note that the name of the form field is exactly the same as in the trace ('attachment[file]' in my case)!
    // You can choose whatever filename you want.
    [body appendData:[@"Content-Disposition: form-data; name=\"attachment[file]\";filename=\"picture.png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // We now need to tell the receiver what content type we have
    // In my case it's a png image. If you have a jpg, set it to 'image/jpg'
    [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Now we append the actual image data
    [body appendData:[NSData dataWithData:UIImagePNGRepresentation(image)]];
    
    // and again the delimiting boundary
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // adding the body we've created to the request
    [request setHTTPBody:body];
    
    return request;
}

- (void)postImage:(UIImage *)image request:(NSMutableURLRequest *)request
{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      @"test.png" ];
    NSData* data = UIImagePNGRepresentation(image);
    [data writeToFile:path atomically:YES];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    [request setValue:path forHTTPHeaderField:@"Content-Length"];
    [request setValue:image forKey:@"filename"];
    
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
            
        } else {
            
        }
    }] resume];
    
}

@end

