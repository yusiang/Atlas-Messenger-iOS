//
//  ATLMSession.h
//  Atlas Messenger
//
//  Created by Blake Watters on 6/28/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATLMUser.h"

/**
 @abstract The `ATLMSession` class models a persistent user session.
 */
@interface ATLMSession : NSObject <NSCoding>

+ (instancetype)sessionWithAuthenticationToken:(NSString *)authenticationToken user:(ATLMUser *)user;

@property (nonatomic, readonly) NSString *authenticationToken;
@property (nonatomic, readonly) ATLMUser *user;

@end
