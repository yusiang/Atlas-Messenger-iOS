//
//  LYRLog.h
//  LayerKit
//
//  Created by Klemen Verdnik on 22/04/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

/**
 The purpose of this file is to set a global log level for the CocoaLumberjack,
 and forward our namespaced log macros to DDLog macros.
 */
#import <DDLog.h>

// We want SPDY to log through our logger
#define SPDY_DEBUG_LOGGING 0

extern int ddLogLevel;

#define LYR_XCODE_COLORS_ESCAPE @"\033["

#define LYR_XCODE_COLORS_RESET_FG   LYR_XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define LYR_XCODE_COLORS_RESET_BG   LYR_XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define LYR_XCODE_COLORS_RESET      LYR_XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color

#define LYR_LOG_COLOR_FILENAME      LYR_XCODE_COLORS_ESCAPE @"fg160,226,50;"
#define LYR_LOG_COLOR_ERROR         LYR_XCODE_COLORS_ESCAPE @"bg20,20,20;" LYR_XCODE_COLORS_ESCAPE @"fg255,50,50;"
#define LYR_LOG_COLOR_WARN          LYR_XCODE_COLORS_ESCAPE @"fg250,150,30;"
#define LYR_LOG_COLOR_INFO          LYR_XCODE_COLORS_RESET
#define LYR_LOG_COLOR_DEBUG         LYR_XCODE_COLORS_ESCAPE @"fg150,150,200;"
#define LYR_LOG_COLOR_VERBOSE       LYR_XCODE_COLORS_ESCAPE @"fg150,150,150;"

#define LYRLogError(frmt, ...)      DDLogError(frmt, ##__VA_ARGS__)
#define LYRLogWarn(frmt, ...)       DDLogWarn(frmt, ##__VA_ARGS__)
#define LYRLogInfo(frmt, ...)       DDLogInfo(frmt, ##__VA_ARGS__)
#define LYRLogDebug(frmt, ...)      DDLogDebug(frmt, ##__VA_ARGS__)
#define LYRLogVerbose(frmt, ...)    DDLogVerbose(frmt, ##__VA_ARGS__)

// TODO: make lumberjack do sync logging only in debug builds
// Undefine the asynchronous defaults:
#undef LOG_ASYNC_ENABLED
#undef LOG_ASYNC_VERBOSE
#undef LOG_ASYNC_DEBUG
#undef LOG_ASYNC_INFO
#undef LOG_ASYNC_WARN
#undef LOG_ASYNC_ERROR

// Define the logs levels to be synchronous:
#define LOG_ASYNC_ENABLED   NO
#define LOG_ASYNC_VERBOSE   (NO && LOG_ASYNC_ENABLED)   // Verbose logging will be synchronous
#define LOG_ASYNC_DEBUG     (NO && LOG_ASYNC_ENABLED)   // Debug logging will be synchronous
#define LOG_ASYNC_INFO      (NO && LOG_ASYNC_ENABLED)   // Info logging will be synchronous
#define LOG_ASYNC_WARN      (NO && LOG_ASYNC_ENABLED)   // Warn logging will be synchronous
#define LOG_ASYNC_ERROR     (NO && LOG_ASYNC_ENABLED)   // Error logging will be synchronous

/**
 @abstract Sets the global log level to the given value.
 */
void LYRSetLogLevel(int logLevel);

/**
 @abstract Sets the global logging level based on the environment variable `LYRLogLevel`.
 @discussion Valid values are: OFF, ERROR, WARN, INFO, DEBUG, VERBOSE
 */
void LYRSetLogLevelFromEnvironment(void);

/**
 @abstract Sets the log level to a specify value while executing a block.
 @param logLevel The log level to set while executing the block. One of `LOG_LEVEL_OFF`, `LOG_LEVEL_ERROR`, 
 `LOG_LEVEL_WARN`, `LOG_LEVEL_INFO`, or `LOG_LEVEL_DEBUG`.
 @param block The block to execute under the new log level.
 */
void LYRLogWithLevelWhileExecutingBlock(int tempLogLevel, void (^block)(void));

/**
 @abstract A convenience function that sets the log level to `LOG_LEVEL_OFF` while executing the block.
 @param block The block to execute under log level `LOG_LEVEL_OFF`.
 */
void LYRLogSilenceWhileExecutingBlock(void (^block)(void));
