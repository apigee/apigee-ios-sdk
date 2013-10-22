//
//  ApigeeLogger.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

typedef enum {
    kApigeeLogLevelVerbose = 2,
    kApigeeLogLevelDebug = 3,
    kApigeeLogLevelInfo = 4,
    kApigeeLogLevelWarn = 5,
    kApigeeLogLevelError = 6,
    kApigeeLogLevelAssert = 7
} ApigeeLogLevel;

@interface ApigeeLogger : NSObject 

//- (ApigeeLogger *) logger;
+ (int) aslLevel:(ApigeeLogLevel) level;
+ (NSString *) aslAppSenderKey;
+ (NSString *) executableName;


+ (void) assert:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(2, 3);
+ (void) error:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(2, 3);
+ (void) warn:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(2, 3);
+ (void) info:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(2, 3);
+ (void) debug:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(2, 3);
+ (void) verbose:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(2, 3);

@end

@interface ApigeeLogger (MacroSupport)

+ (void) assertFrom:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4);
+ (void) errorFrom:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4);
+ (void) warnFrom:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4);
+ (void) infoFrom:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4);
+ (void) debugFrom:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4);
+ (void) verboseFrom:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4);

+ (void) assertFrom:(const char *) function tag:(NSString *) tag message:(NSString *) message;
+ (void) errorFrom:(const char *) function tag:(NSString *) tag message:(NSString *) message;
+ (void) warnFrom:(const char *) function tag:(NSString *) tag message:(NSString *) message;
+ (void) infoFrom:(const char *) function tag:(NSString *) tag message:(NSString *) message;
+ (void) debugFrom:(const char *) function tag:(NSString *) tag message:(NSString *) message;
+ (void) verboseFrom:(const char *) function tag:(NSString *) tag message:(NSString *) message;

@end

#define ApigeeLogAssert(TAG, ...)  \
[ApigeeLogger assertFrom:__func__ tag:TAG format:__VA_ARGS__]

#define ApigeeLogError(TAG, ...)  \
[ApigeeLogger errorFrom:__func__ tag:TAG format:__VA_ARGS__]

#define ApigeeLogWarn(TAG, ...)  \
[ApigeeLogger warnFrom:__func__ tag:TAG format:__VA_ARGS__]

#define ApigeeLogInfo(TAG, ...)  \
[ApigeeLogger infoFrom:__func__ tag:TAG format:__VA_ARGS__]

#define ApigeeLogDebug(TAG, ...)  \
[ApigeeLogger debugFrom:__func__ tag:TAG format:__VA_ARGS__]

#define ApigeeLogVerbose(TAG, ...)  \
[ApigeeLogger verboseFrom:__func__ tag:TAG format:__VA_ARGS__]


// Use these variants when the logging content is a single NSString
#define ApigeeLogAssertMessage(TAG, MESSAGE)  \
[ApigeeLogger assertFrom:__func__ tag:TAG message:MESSAGE]

#define ApigeeLogErrorMessage(TAG, MESSAGE)  \
[ApigeeLogger errorFrom:__func__ tag:TAG message:MESSAGE]

#define ApigeeLogWarnMessage(TAG, MESSAGE)  \
[ApigeeLogger warnFrom:__func__ tag:TAG message:MESSAGE]

#define ApigeeLogInfoMessage(TAG, MESSAGE)  \
[ApigeeLogger infoFrom:__func__ tag:TAG message:MESSAGE]

#define ApigeeLogDebugMessage(TAG, MESSAGE)  \
[ApigeeLogger debugFrom:__func__ tag:TAG message:MESSAGE]

#define ApigeeLogVerboseMessage(TAG, MESSAGE)  \
[ApigeeLogger verboseFrom:__func__ tag:TAG message:MESSAGE]

