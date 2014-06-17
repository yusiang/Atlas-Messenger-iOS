//
//  LYRSampleParticipant.h
//  LYRSampleData
//
//  Created by Kevin Coleman on 6/4/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYRSampleParticipant : NSObject

@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *identifier;

+ (NSSet *)participants:(int)number;
+ (instancetype)participantWithNumber:(int)number;

@end
