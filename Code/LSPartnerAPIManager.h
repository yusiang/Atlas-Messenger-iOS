//
//  LSJiraManager.h
//  LayerSample
//
//  Created by Kevin Coleman on 10/23/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSPartnerAPIManager : NSObject

+ (instancetype)managerWithBaseURL:(NSURL *)baseURL;

- (void)postIssueWithPhoto:(UIImage *)photo summary:(NSString *)summary description:(NSString *)description;

- (void)attachImage:(UIImage *)image toIssue:(NSString *)issue;

@end
