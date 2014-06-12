//
//  LYRDDLogFormatter.m
//  LayerKit
//
//  Created by Klemen Verdnik on 22/04/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import "LYRDDLogFormatter.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"
#import "DDFileLogger.h"
#import <pthread.h>

const NSString *LYRDDLogPrefix = @"LYR ";

NSString *LYRDDLogDateFormatter(NSDate *date)
{
    static dispatch_once_t once;
    static NSDateFormatter *dateFormatter;
    static dispatch_queue_t queueSerialFormatter;
    dispatch_once(&once, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss.SSS"];
        queueSerialFormatter = dispatch_queue_create("com.layer.layerkit.logDateFormatter", NULL);
    });
    __block NSString *formattedDateString;
    dispatch_sync(queueSerialFormatter, ^{ formattedDateString = [dateFormatter stringFromDate:date]; });
    return formattedDateString;
}

@interface LYRDDLogFormatter ()

@property (nonatomic, assign) BOOL isColorOutputEnabled;

@end

@implementation LYRDDLogFormatter

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isColorOutputEnabled = NO;
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel, *colorPrefix, *fileAndLine;
    switch (logMessage->logFlag) {
        case LOG_FLAG_ERROR : { logLevel = @"[ERROR]"; colorPrefix = LYR_LOG_COLOR_ERROR; break; }
        case LOG_FLAG_WARN  : { logLevel = @"[WARNING]"; colorPrefix = LYR_LOG_COLOR_WARN; break; }
        case LOG_FLAG_INFO  : { logLevel = @"[INFO]"; colorPrefix = LYR_LOG_COLOR_INFO; break; }
        case LOG_FLAG_DEBUG : { logLevel = @"[DEBUG]"; colorPrefix = LYR_LOG_COLOR_DEBUG; break; }
        default             : { logLevel = @"[VERBOSE]"; colorPrefix = LYR_LOG_COLOR_VERBOSE; break; }
    }
    logLevel = [LYRDDLogPrefix stringByAppendingString:logLevel];
    NSString *timeAndProcess = [NSString stringWithFormat:@"%@ %@[%u:%u]", LYRDDLogDateFormatter(logMessage->timestamp), [[NSProcessInfo processInfo] processName], [[NSProcessInfo processInfo] processIdentifier], logMessage->machThreadID];
    NSString *cleanedUpLogMessage = [logMessage->logMsg stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    fileAndLine = [NSString stringWithFormat:@"%@:%d", [[NSString stringWithUTF8String:logMessage->file] lastPathComponent], logMessage->lineNumber];
    if (self.isColorOutputEnabled)
    {
        timeAndProcess = [colorPrefix stringByAppendingString:timeAndProcess];
        fileAndLine = [[LYR_LOG_COLOR_FILENAME stringByAppendingString:fileAndLine] stringByAppendingString:colorPrefix];
        cleanedUpLogMessage = [cleanedUpLogMessage stringByAppendingString:LYR_XCODE_COLORS_RESET];
    }
    cleanedUpLogMessage = [cleanedUpLogMessage stringByReplacingOccurrencesOfString:@"\n    " withString:@" "];
    cleanedUpLogMessage = [cleanedUpLogMessage stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    return [NSString stringWithFormat:@"%@ %@ %@ %@", timeAndProcess, logLevel, fileAndLine, cleanedUpLogMessage];
}

- (void)didAddToLogger:(id<DDLogger>)logger
{
    char *xcodeColorsEnv = getenv("XCODE_COLORS");
    self.isColorOutputEnabled = xcodeColorsEnv && strcmp(xcodeColorsEnv, "YES") == 0;

    if ([logger isKindOfClass:[DDTTYLogger class]]) {
        self.isColorOutputEnabled &= YES;
    } else if ([logger isKindOfClass:[DDASLLogger class]]) {
        self.isColorOutputEnabled = NO;
    } else if ([logger isKindOfClass:[DDFileLogger class]]) {
        self.isColorOutputEnabled = NO;
    }
}

@end
