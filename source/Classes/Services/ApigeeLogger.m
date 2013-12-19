//
//  ApigeeLogger.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#include <asl.h>
#include <unistd.h>

#import "ApigeeSystemLogger.h"
#import "ApigeeOpenUDID.h"
#import "ApigeeCustomASLMessageKeys.h"
#import "ApigeeLogger.h"
#import "ApigeeMonitoringClient.h"

#define kApigeeSystemSenderKey @"com.Apigee.system"

static const int kMaxMethodLength = 30;

#define GID_UID_LENGTH 12
static char gidValue[GID_UID_LENGTH];
static char uidValue[GID_UID_LENGTH];
static BOOL haveGidAndUid = NO;


@implementation ApigeeLogger

#pragma mark - Instance management

//- (ApigeeLogger *) logger
//{
//    return [[ApigeeLogger alloc] init];
//}

#pragma mark - Log level translation

+ (int) aslLevel:(ApigeeLogLevel) level
{
    switch (level) {
        case kApigeeLogLevelAssert:
            return ASL_LEVEL_CRIT;
        case kApigeeLogLevelError:
            return ASL_LEVEL_ERR;
        case kApigeeLogLevelWarn:
            return ASL_LEVEL_WARNING;
        default: //all others are notice
            return ASL_LEVEL_NOTICE;
    }
}

#pragma mark - ASL message key support

+ (NSString *) aslAppSenderKey
{
    static NSString *sender = nil;
    
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sender = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    });
    
    return sender;
}

+ (NSString *) executableName
{
    static NSString *executableName = nil;
    
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        executableName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
    });
    
    return executableName;
}

#pragma mark - Logging support

+ (void) assert:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(2, 3)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:[ApigeeLogger aslAppSenderKey] function:nil tag:tag format:format list:args level:kApigeeLogLevelAssert];
    
    va_end(args);
}

+ (void) error:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(2, 3)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:[ApigeeLogger aslAppSenderKey] function:nil tag:tag format:format list:args level:kApigeeLogLevelError];
    
    va_end(args);
}

+ (void) warn:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(2, 3)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:[ApigeeLogger aslAppSenderKey] function:nil tag:tag format:format list:args level:kApigeeLogLevelWarn];
    
    va_end(args);
}

+ (void) info:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(2, 3)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:[ApigeeLogger aslAppSenderKey] function:nil tag:tag format:format list:args level:kApigeeLogLevelInfo];
    
    va_end(args);
}

+ (void) debug:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(2, 3)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:[ApigeeLogger aslAppSenderKey] function:nil tag:tag format:format list:args level:kApigeeLogLevelDebug];
    
    va_end(args);
}

+ (void) verbose:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(2, 3)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:[ApigeeLogger aslAppSenderKey] function:nil tag:tag format:format list:args level:kApigeeLogLevelVerbose];
    
    va_end(args);
}

#pragma mark - Internal

+ (void) logToASL:(NSString *) sender
         function:(NSString *) function
              tag:(NSString *) tag
          message:(NSString *) message
            level:(ApigeeLogLevel) level
{
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if ((level > kApigeeLogLevelVerbose) && [monitoringClient isPaused]) {
        return;
    }
    
    //note: swap the commented line below to stop output to standard err stream (xcode console)
    //aslclient client = asl_open([sender UTF8String], [tag UTF8String], ASL_OPT_NO_REMOTE);
    aslclient client = asl_open([sender UTF8String], [tag UTF8String], ASL_OPT_STDERR | ASL_OPT_NO_REMOTE);
    
    if (client == NULL) {
        SystemDebug(@"IO_Diagnostics",@"Unable to access ASL");
        return;
    }
    
    //note: ASL doesn't seem to honor this call, it will still drop anything below ASL_LEVEL_NOTICE
    asl_set_filter(client, ASL_FILTER_MASK_UPTO(ASL_LEVEL_DEBUG));
    
    aslmsg msg = asl_new(ASL_TYPE_MSG);
    
    if (msg != NULL) {
        
        if( ! haveGidAndUid ) {
            NSString * gid = [NSString stringWithFormat:@"%d", getgid()];
            NSString * uid = [NSString stringWithFormat:@"%d", getuid()];
            strncpy(gidValue,[gid UTF8String],GID_UID_LENGTH);
            strncpy(uidValue,[uid UTF8String],GID_UID_LENGTH);
            gidValue[GID_UID_LENGTH-1] = '\0';
            uidValue[GID_UID_LENGTH-1] = '\0';
            haveGidAndUid = YES;
        }
        
        //security for messages, only we can query for these
        if (haveGidAndUid) {
            asl_set(msg, ASL_KEY_READ_GID, gidValue);
            asl_set(msg, ASL_KEY_READ_UID, uidValue);
        }
        
        char logLevelAsString[8];
        snprintf(logLevelAsString, 8, "%d", (int) level);
        
        asl_set(msg, kApigeeLogLevelASLMessageKey, logLevelAsString);
        
        NSString *output;
        
        if ([function length] != 0) {
            output = [NSString stringWithFormat:@"%@ %@", function, message];
        } else {
            output = message;
        }
        
        asl_log(client, msg, [ApigeeLogger aslLevel:level], "%s", [output UTF8String]);
        asl_free(msg);
    } else {
        SystemDebug(@"IO_Diagnostics",@"Unable to create new ASL message");
    }
    
    asl_close(client);
}

+ (void) logToASL:(NSString *) sender
            function:(NSString *) function
                 tag:(NSString *) tag
              format:(NSString *) format
                list:(va_list) args
               level:(ApigeeLogLevel) level
{
    NSString *output = nil;
    NSRange rangePercent = [format rangeOfString:@"%"];
    if (rangePercent.location != NSNotFound) {
        output = [[NSString alloc] initWithFormat:format arguments:args];
    } else {
        output = format;
    }
    
    [ApigeeLogger logToASL:sender
                  function:function
                       tag:tag
                   message:output
                     level:level];
}

+ (NSString *) formatFunctionName:(const char *) fname
{
    if (!fname) {
        return nil;
    }
    
    NSString *function = [[NSString stringWithUTF8String:fname]
                          stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([function length] == 0) {
        return @"(unknown)";
    }
    
    //obj-c or c++ names
    if ([function hasPrefix:@"-["] || [function hasPrefix:@"+["] || [function hasSuffix:@")"]) {
        
        if (([function hasPrefix:@"-["] || [function hasPrefix:@"+["]) && [function hasSuffix:@"]"]) {
            NSRange rangeSpace = [function rangeOfString:@" "];
            if (rangeSpace.location != NSNotFound) {
                NSString *className = [function substringWithRange:NSMakeRange(2, rangeSpace.location-2)];
                NSString *methodName = [function substringFromIndex:rangeSpace.location+1];
                methodName = [methodName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if ([methodName length] > kMaxMethodLength) {
                    NSString *prefix = [function substringToIndex:2];
                    function = [NSString stringWithFormat:@"%@%@ %@...]",
                                prefix,
                                className,
                                [methodName substringToIndex:kMaxMethodLength]];
                    return function;
                }
            }
        }
        
        return function;
    }
    
    //c style name
    return [NSString stringWithFormat:@"%@()", function];
}


@end

@implementation ApigeeLogger(MacroSupport)

+ (void) assertFrom:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:[ApigeeLogger aslAppSenderKey] function:[self formatFunctionName:function] tag:tag format:format list:args level:kApigeeLogLevelAssert];
    
    va_end(args);
}

+ (void) errorFrom:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:[ApigeeLogger aslAppSenderKey] function:[self formatFunctionName:function] tag:tag format:format list:args level:kApigeeLogLevelError];
    
    va_end(args);    
}

+ (void) warnFrom:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:[ApigeeLogger aslAppSenderKey] function:[self formatFunctionName:function] tag:tag format:format list:args level:kApigeeLogLevelWarn];
    
    va_end(args);
}

+ (void) infoFrom:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:[ApigeeLogger aslAppSenderKey] function:[self formatFunctionName:function] tag:tag format:format list:args level:kApigeeLogLevelInfo];
    
    va_end(args);
}

+ (void) debugFrom:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:[ApigeeLogger aslAppSenderKey] function:[self formatFunctionName:function] tag:tag format:format list:args level:kApigeeLogLevelDebug];
    
    va_end(args);
}

+ (void) verboseFrom:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:[ApigeeLogger aslAppSenderKey] function:[self formatFunctionName:function] tag:tag format:format list:args level:kApigeeLogLevelVerbose];
    
    va_end(args);
}

+ (void) assertFrom:(const char *) function tag:(NSString *) tag message:(NSString *) message
{
    [self logToASL:[ApigeeLogger aslAppSenderKey]
          function:[self formatFunctionName:function]
               tag:tag
           message:message
             level:kApigeeLogLevelAssert];
}

+ (void) errorFrom:(const char *) function tag:(NSString *) tag message:(NSString *) message
{
    [self logToASL:[ApigeeLogger aslAppSenderKey]
          function:[self formatFunctionName:function]
               tag:tag
           message:message
             level:kApigeeLogLevelError];
}

+ (void) warnFrom:(const char *) function tag:(NSString *) tag message:(NSString *) message
{
    [self logToASL:[ApigeeLogger aslAppSenderKey]
          function:[self formatFunctionName:function]
               tag:tag
           message:message
             level:kApigeeLogLevelWarn];
}

+ (void) infoFrom:(const char *) function tag:(NSString *) tag message:(NSString *) message
{
    [self logToASL:[ApigeeLogger aslAppSenderKey]
          function:[self formatFunctionName:function]
               tag:tag
           message:message
             level:kApigeeLogLevelInfo];
}

+ (void) debugFrom:(const char *) function tag:(NSString *) tag message:(NSString *) message
{
    [self logToASL:[ApigeeLogger aslAppSenderKey]
          function:[self formatFunctionName:function]
               tag:tag
           message:message
             level:kApigeeLogLevelDebug];
}

+ (void) verboseFrom:(const char *) function tag:(NSString *) tag message:(NSString *) message
{
    [self logToASL:[ApigeeLogger aslAppSenderKey]
          function:[self formatFunctionName:function]
               tag:tag
           message:message
             level:kApigeeLogLevelVerbose];
}

@end

@implementation ApigeeLogger(SystemLogger)

+ (void) systemAssert:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:kApigeeSystemSenderKey
          function:[self formatFunctionName:function]
               tag:tag
            format:format
              list:args
             level:kApigeeLogLevelAssert];
    
    va_end(args);
}

+ (void) systemError:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:kApigeeSystemSenderKey
          function:[self formatFunctionName:function]
               tag:tag
            format:format
              list:args
             level:kApigeeLogLevelError];
    
    va_end(args);
    
}

+ (void) systemWarn:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:kApigeeSystemSenderKey
          function:[self formatFunctionName:function]
               tag:tag
            format:format
              list:args
             level:kApigeeLogLevelWarn];
    
    va_end(args);
}

+ (void) systemInfo:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:kApigeeSystemSenderKey
          function:[self formatFunctionName:function]
               tag:tag
            format:format
              list:args
             level:kApigeeLogLevelInfo];
    
    va_end(args);
}

+ (void) systemDebug:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:kApigeeSystemSenderKey
          function:[self formatFunctionName:function]
               tag:tag
            format:format
              list:args
             level:kApigeeLogLevelDebug];
    
    va_end(args);
}

+ (void) systemVerbose:(const char *) function tag:(NSString *) tag format:(NSString *) format, ... NS_FORMAT_FUNCTION(3, 4)
{
    va_list args;
    va_start(args, format);
    
    [self logToASL:kApigeeSystemSenderKey
          function:[self formatFunctionName:function]
               tag:tag
            format:format
              list:args
             level:kApigeeLogLevelVerbose];
    
    va_end(args);
}

@end