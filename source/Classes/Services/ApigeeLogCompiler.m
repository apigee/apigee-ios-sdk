/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <asl.h>

#import "NSDate+Apigee.h"
#import "ApigeeLogEntry.h"
#import "ApigeeCustomASLMessageKeys.h"
#import "ApigeeLogger.h"
#import "ApigeeLogCompiler.h"

#define kApigeeMaxLogEntries 100
#define kApigeeMaxLogMessageLength 200
#define kApigeeLastLogTransmission @"ApigeeLastLogTransmission"

@implementation ApigeeLogCompiler

#pragma mark - Instance management

+ (ApigeeLogCompiler *) systemCompiler
{
    static ApigeeLogCompiler *compiler = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        compiler = [[ApigeeLogCompiler alloc] init];
    });
    
    return compiler;
}

#pragma mark - Interface implementation

+ (void) refreshUploadTimestamp:(NSDate*)lastLogTransmissionDate
{
    [[NSUserDefaults standardUserDefaults] setObject:lastLogTransmissionDate
                                              forKey:kApigeeLastLogTransmission];
}

+ (void) refreshUploadTimestamp
{
    [self refreshUploadTimestamp:[NSDate date]];
}

- (NSDate*) retrieveLogsEntriesForSender:(NSString*)sender
                               sinceTime:(NSDate*)sinceTime
                                settings:(ApigeeActiveSettings *) settings
                              populating:(NSMutableArray*)logEntries
                     maxNumberLogEntries:(int)maxNumberLogEntries
                       autoPromoteErrors:(BOOL)autoPromoteErrors
{
    // we only query ASL if we have a sender value
    if([sender length] < 1) {
        return nil;
    }
    
    // don't bother running query if we've already retrieved our maximum number of entries
    if([logEntries count] >= maxNumberLogEntries) {
        return nil;
    }
    
    NSDate *newestMessage = nil;

    aslmsg q = asl_new(ASL_TYPE_QUERY);
    asl_set_query(q, ASL_KEY_SENDER, [sender UTF8String], ASL_QUERY_OP_EQUAL);
    
    if(sinceTime != nil) {
        NSString *since = [NSString stringWithFormat:@"%.f", [sinceTime timeIntervalSince1970]];
        asl_set_query(q, ASL_KEY_TIME, [since UTF8String], ASL_QUERY_OP_GREATER);
    }
    
    aslresponse r = asl_search(NULL, q);
    aslmsg m;
    BOOL querying = YES;
    
    while (querying && (NULL != (m = aslresponse_next(r))))
    {
        ApigeeLogLevel level = kApigeeLogLevelDebug;
        const char* messageLevel = asl_get(m, kApigeeLogLevelASLMessageKey);
        
        if (messageLevel) {
            const int messageLevelAsInt = atoi(messageLevel);
            if (messageLevelAsInt > 0) {
                level = messageLevelAsInt;
            }
        }
        
        if (level < settings.logLevelToMonitor) {
            continue;
        }
        
        ApigeeLogEntry *logEntry = [ApigeeLogEntry new];
        
        //note: log messages persisted via our API will have the custom log level key set, but NSLog statements will not.  As such, we impose
        //a level of debug on the message if the custom key does not exist. Otherwise, we accept the definition on the message and filter
        //accordingly.
        
        NSString* logLevelCode = @"D"; // debug
        
        switch( level )
        {
            case kApigeeLogLevelVerbose:
                logLevelCode = @"V";
                break;
            case kApigeeLogLevelDebug:
                logLevelCode = @"D";
                break;
            case kApigeeLogLevelInfo:
                logLevelCode = @"I";
                break;
            case kApigeeLogLevelWarn:
                logLevelCode = @"W";
                break;
            case kApigeeLogLevelError:
                logLevelCode = @"E";
                break;
            case kApigeeLogLevelAssert:
                logLevelCode = @"A";
                break;
        }
        
        logEntry.logLevel = logLevelCode;

        
        if (asl_get(m, ASL_KEY_FACILITY) != NULL) {
            logEntry.tag = [NSString stringWithUTF8String:asl_get(m, ASL_KEY_FACILITY)];
        }
        
        if (asl_get(m, ASL_KEY_MSG)) {
            NSString *message = [NSString stringWithUTF8String:asl_get(m, ASL_KEY_MSG)];
            
            if ([message length] > kApigeeMaxLogMessageLength) {
                logEntry.logMessage = [message substringToIndex:kApigeeMaxLogMessageLength];
            } else {
                logEntry.logMessage = message;
            }
        }
        
        NSString *seconds = [NSString stringWithUTF8String:asl_get(m, ASL_KEY_TIME)];
        
        // timestamp values in ASL are stored in seconds. we report timestamps
        // in milliseconds to the server. we just append '000' to the end to
        // represent the value in milliseconds
        NSDate *entryTimestamp = [NSDate dateWithTimeIntervalSince1970:[seconds doubleValue]];
        
        if (nil == newestMessage) {
            newestMessage = [entryTimestamp copy];
        } else {
            if ([entryTimestamp compare:newestMessage] == NSOrderedDescending) {
                newestMessage = [entryTimestamp copy];
            }
        }
        
        // convert seconds to milliseconds by appending 3 zeros
        logEntry.timeStamp = [NSString stringWithFormat:@"%@000", seconds];
        
        
        if ([logEntries count] < kApigeeMaxLogEntries) {
            BOOL discardEntry = NO;
            
            //REVIEW: we should consider the following and how, if at all, we
            // want to handle it. 'libMobileGestalt...' log messages are not
            // uncommon when running on the simulator. Should we suppress it
            // on the client?
#if (TARGET_IPHONE_SIMULATOR)
            // filter out some messages that commonly show up on simulator
            if ([logEntry.tag isEqualToString:@"user"] &&
                (level == kApigeeLogLevelDebug)) {
                NSString *logMessage = logEntry.logMessage;
                
                if ([logMessage hasPrefix:@"libMobileGestalt"]) {
                    discardEntry = YES;
                } else {
                    NSRange rangeSubstring =
                    [logMessage rangeOfString:@"Could not successfully update network info during" ];
                    if (rangeSubstring.location != NSNotFound) {
                        discardEntry = YES;
                    }
                }
            }
#endif
      
            // auto-promotion of errors
            // the test here is for level = 'debug' because that's how the
            // NSLog messages get reported
            if (autoPromoteErrors && (level == kApigeeLogLevelDebug)) {
                if ([logEntry.logMessage length] > 5) {
                    NSString* logMessagePrefix = [logEntry.logMessage substringToIndex:5];
                    NSString* lowerLogMessagePrefix = [logMessagePrefix lowercaseString];
                    if ([lowerLogMessagePrefix isEqualToString:@"error"]) {
                        unichar sixthChar = [logEntry.logMessage characterAtIndex:5];
                        if (sixthChar < 'a' || sixthChar > 'z') {
                            // promote to error
                            NSCharacterSet* setWhitespace = [NSCharacterSet whitespaceCharacterSet];
                            NSString* updatedLogMessage = [logEntry.logMessage substringFromIndex:6];
                            NSString* trimmedUpatedLogMessage = [updatedLogMessage stringByTrimmingCharactersInSet:setWhitespace];
                            logEntry.logLevel = @"E";
                            logEntry.logMessage = trimmedUpatedLogMessage;
                        }
                    }
                }
            }

            if (!discardEntry) {
                [logEntries addObject:logEntry];
            }
        } else {
            querying = NO;  // no need to continue running query, because we'll just be ignoring the results
            SystemDebug(@"IO_Diagnostics",@"Not capturing due to log level or full queue: '%@'", logEntry.logMessage);
        }
    }
    
    aslresponse_free(r);
    asl_free(q);
    
    return newestMessage;
}

- (NSArray *) compileLogsForSettings:(ApigeeActiveSettings *) settings
                   autoPromoteErrors:(BOOL)autoPromoteErrors
{
    NSMutableArray *logEntries = [NSMutableArray array];
    NSDate *timeStamp = [[NSUserDefaults standardUserDefaults] objectForKey:kApigeeLastLogTransmission];
    
    NSString* aslAppSenderKey = [ApigeeLogger aslAppSenderKey];
    NSString* executableName = [ApigeeLogger executableName];
    NSDate* newestExecutableSenderMessage = nil;
    
    NSDate *newestAppSenderMessage = [self retrieveLogsEntriesForSender:aslAppSenderKey
                                                              sinceTime:timeStamp
                                                               settings:settings
                                                             populating:logEntries
                                                    maxNumberLogEntries:kApigeeMaxLogEntries
                                                      autoPromoteErrors:autoPromoteErrors];
    
    if( ! [aslAppSenderKey isEqualToString:executableName]) {
        newestExecutableSenderMessage = [self retrieveLogsEntriesForSender:executableName
                                                                 sinceTime:timeStamp
                                                                  settings:settings
                                                                populating:logEntries
                                                       maxNumberLogEntries:kApigeeMaxLogEntries
                                                         autoPromoteErrors:autoPromoteErrors];
    }
    
    
    // found any messages?
    if ((newestAppSenderMessage != nil) || (newestExecutableSenderMessage != nil)) {
        if (newestExecutableSenderMessage == nil) {
            [ApigeeLogCompiler refreshUploadTimestamp:newestAppSenderMessage];
        } else if (newestAppSenderMessage == nil) {
            [ApigeeLogCompiler refreshUploadTimestamp:newestExecutableSenderMessage];
        } else {
            NSDate* newestMessageDate = [newestAppSenderMessage laterDate:newestExecutableSenderMessage];
            [ApigeeLogCompiler refreshUploadTimestamp:newestMessageDate];
        }
    }
    
    return logEntries;
}

@end
