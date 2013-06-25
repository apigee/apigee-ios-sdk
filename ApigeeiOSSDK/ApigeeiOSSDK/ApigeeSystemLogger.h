//
//  ApigeeSystemLogger.h
//  ApigeeAppMonitor
//
//  Created by jaminschubert on 9/26/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeLogger.h"

/**
 * Internal interface. Do no export header with the framework
 */
@interface ApigeeLogger (SystemLogger)

+ (void) systemAssert:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4);
+ (void) systemError:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4);
+ (void) systemWarn:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4);
+ (void) systemInfo:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4);
+ (void) systemDebug:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4);
+ (void) systemVerbose:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4);

@end

#define SystemAssert(TAG, ...)  \
[ApigeeLogger systemAssert:__func__ tag:TAG format:__VA_ARGS__]

#define SystemError(TAG, ...)  \
[ApigeeLogger systemError:__func__ tag:TAG format:__VA_ARGS__]

#define SystemWarn(TAG, ...)  \
[ApigeeLogger systemWarn:__func__ tag:TAG format:__VA_ARGS__]

#define SystemInfo(TAG, ...)  \
[ApigeeLogger systemInfo:__func__ tag:TAG format:__VA_ARGS__]

#define SystemDebug(TAG, ...)  \
[ApigeeLogger systemDebug:__func__ tag:TAG format:__VA_ARGS__]

#define SystemVerbose(TAG, ...)  \
[ApigeeLogger systemVerbose:__func__ tag:TAG format:__VA_ARGS__]
