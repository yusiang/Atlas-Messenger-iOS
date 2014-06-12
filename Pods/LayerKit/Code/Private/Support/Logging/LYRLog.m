//
//  LYRDDLogLevel.m
//  LayerKit
//
//  Created by Klemen Verdnik on 22/04/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRLog.h"
#import "SPDYCommonLogger.h"

#ifndef LYR_LOG_LEVEL
#define LYR_LOG_LEVEL LOG_LEVEL_ERROR
#endif

int ddLogLevel = LYR_LOG_LEVEL;

void LYRSetLogLevel(int logLevel)
{
    ddLogLevel = logLevel;
}

void LYRSetLogLevelFromEnvironment(void)
{
    NSString *logLevel = [[NSProcessInfo processInfo].environment[@"LAYER_LOG_LEVEL"] uppercaseString];
    if (!logLevel) {
        return;
    } else if ([logLevel isEqualToString:@"OFF"]) {
        ddLogLevel = LOG_LEVEL_OFF;
    } else if ([logLevel isEqualToString:@"ERROR"]) {
        ddLogLevel = LOG_LEVEL_ERROR;
    } else if ([logLevel isEqualToString:@"WARN"]) {
        ddLogLevel = LOG_LEVEL_WARN;
    } else if ([logLevel isEqualToString:@"INFO"]) {
        ddLogLevel = LOG_LEVEL_INFO;
    } else if ([logLevel isEqualToString:@"DEBUG"]) {
        ddLogLevel = LOG_LEVEL_DEBUG;
    } else if ([logLevel isEqualToString:@"VERBOSE"]) {
        ddLogLevel = LOG_LEVEL_VERBOSE;
    } else {
        [NSException raise:NSInvalidArgumentException format:@"Invalid value given for `LYRLogLevel` environment variable: '%@'", logLevel];
    }
}

@interface LYRSPDYLogger : NSObject <SPDYLogger>
@end

@implementation LYRSPDYLogger

+ (void)load
{
    LYRSPDYLogger *logger = [LYRSPDYLogger new];
    [SPDYCommonLogger setLogger:logger];
}

- (void)log:(NSString *)message atLevel:(SPDYLogLevel)logLevel
{
    switch (logLevel) {
        case SPDYLogLevelError:
            LYRLogError(message);
            break;
        
        case SPDYLogLevelDebug:
            LYRLogDebug(message);
        break;
        
        case SPDYLogLevelInfo:
            LYRLogInfo(message);
        break;
        
        case SPDYLogLevelWarning:
            LYRLogWarn(message);
        break;
        
        default:
        break;
    }
}

@end

void LYRLogWithLevelWhileExecutingBlock(int tempLogLevel, void (^block)(void))
{
    int currentLogLevel = ddLogLevel;
    @try {
        ddLogLevel = tempLogLevel;
        block();
    } @finally {
        ddLogLevel = currentLogLevel;
    }
}

void LYRLogSilenceWhileExecutingBlock(void (^block)(void))
{
    LYRLogWithLevelWhileExecutingBlock(LOG_LEVEL_OFF, block);
}
