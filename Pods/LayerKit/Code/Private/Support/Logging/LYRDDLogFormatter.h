//
//  LYRDDLogFormatter.h
//  LayerKit
//
//  Created by Klemen Verdnik on 22/04/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DDLog.h>

@interface LYRDDLogFormatter : NSObject <DDLogFormatter> {
    int atomicLoggerCount;
    NSDateFormatter *threadUnsafeDateFormatter;
}

@end
