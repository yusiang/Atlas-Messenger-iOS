//
//  LSParseController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSParseController.h"

@implementation LSParseController

- (id) init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)initializeParseSDK
{
//    [Parse setApplicationId:@"FvtTD9THmnMNlBxQKZ0R3RVx3zuVYgcG1uPFR7Mo"
//                  clientKey:@"eT1sf2vFjeHRehFYJ2A2jlGCr5dq2tQWLpqJvh4Z"];
    
}

- (void)createParseUserWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(NSError *))completion
{
    completion(nil);
//    PFUser *user = [PFUser user];
//    user.email = email;
//    user.username = email;
//    user.password = password;
//    
//    //Sign Up User in the Background with Parse
//    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (!error) {
//            
//            //Start up the LayerController and get an authentication nonce
//            self.layerController = [[LSLayerController alloc] init];
//            [self.layerController authenticationNonceWithCompletion:^(NSString *string, NSError *error) {
//                if(!error) {
//                    
//                    //Request identity token from Parse
//                    [self requestLayerIdentityTokenWithNonce:string];
//                }
//            }];
//            completion(nil);
//        } else {
//            completion(error);
//        }
//    }];
}

- (void)logParseUserInWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(NSError *))completion
{
    if([email isEqualToString:@"test@layer.com"] && [password isEqualToString:@"password"]) {
        completion (nil);
    } else {
        NSError *error = [NSError errorWithDomain:@"Invalid Login Credentials" code:404 userInfo:nil];
        completion (error);
    }
//    [PFUser logInWithUsernameInBackground:email password:password
//                                    block:^(PFUser *user, NSError *error) {
//                                        if (user) {
//                                            completion(nil);
//                                        } else {
//                                            completion(error);
//                                        }
//                                    }];
}

- (void)logOutParseUser
{
//    [PFUser logOut];
}

- (void)requestLayerIdentityTokenWithNonce:(NSString *)nonce
{
//    [PFCloud callFunctionInBackground:@"requestIdentityToken"
//                       withParameters:@{@"nonce": nonce,
//                                        @"uid" : @"8372kdjd83"}
//                                block:^(NSString *identityToken, NSError *error) {
//                                    if (identityToken) {
//                                        
//                                    }
//                                }];
}

@end

