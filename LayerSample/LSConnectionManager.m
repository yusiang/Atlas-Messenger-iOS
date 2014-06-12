//
//  LSConnectionManager.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSConnectionManager.h"

NSString *const LSIdentityTokenURL = @"http://localhost:3000/identityToken";

@implementation LSConnectionManager

- (void)requestLayerIdentityTokenWithNonce:(NSString *)nonce completion:(void (^)(NSString *, NSError *))completion
{
    NSMutableURLRequest *request = [self requestWithURLString:LSIdentityTokenURL];
    [request setHTTPBody:[self bodyWithDictionary:@{@"nonce": nonce}]];
    
    [[[self defaultURLSession] dataTaskWithRequest:request
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        
                            }] resume];
}

- (NSURLSession *)defaultURLSession
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    return [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
}

- (NSMutableURLRequest *)requestWithURLString:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    return request;
}
                                    
-(NSData *) bodyWithDictionary:(NSDictionary *)dictionary
{
    NSError *error;
    return [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
}

#pragma mark
#pragma mark NSURLSessionDelegate Methods

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        if([challenge.protectionSpace.host isEqualToString:@"api-beta.layer.com"]){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    
}
@end
