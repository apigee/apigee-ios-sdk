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

#import "ApigeeDefaultiOSLog.h"

static NSString* kLevelVerbose = @"V";
static NSString* kLevelDebug   = @"D";
static NSString* kLevelInfo    = @"I";
static NSString* kLevelWarn    = @"W";
static NSString* kLevelError   = @"E";
static NSString* kLevelAssert  = @"A";


@implementation ApigeeDefaultiOSLog

- (void)log:(NSString*)level tag:(NSString*)tag message:(NSString*)message
{
    NSLog(@"%@", [NSString stringWithFormat:@"%@:%@", tag, message]);
}

- (void)log:(NSString*)level tag:(NSString*)tag message:(NSString*)message exception:(NSException*)e
{
    NSString* messageWithException = [NSString stringWithFormat:@"%@; exception=%@",
                                      message,
                                      [e reason]];
    [self log:level tag:tag message:messageWithException];
}

- (void)log:(NSString*)level tag:(NSString*)tag message:(NSString*)message error:(NSError*)e
{
    NSString* messageWithError = [NSString stringWithFormat:@"%@; error=%@",
                                  message,
                                  [e localizedDescription]];
    [self log:level tag:tag message:messageWithError];
}

- (void)verbose:(NSString*)tag message:(NSString*)msg
{
    [self log:kLevelVerbose tag:tag message:msg];
}

- (void)verbose:(NSString*)tag message:(NSString*)msg exception:(NSException*)e
{
    [self log:kLevelVerbose tag:tag message:msg exception:e];
}

- (void)verbose:(NSString*)tag message:(NSString*)msg error:(NSError*)e
{
    [self log:kLevelVerbose tag:tag message:msg error:e];
}

- (void)debug:(NSString*)tag message:(NSString*)msg
{
    [self log:kLevelDebug tag:tag message:msg];
}

- (void)debug:(NSString*)tag message:(NSString*)msg exception:(NSException*)e
{
    [self log:kLevelDebug tag:tag message:msg exception:e];
}

- (void)debug:(NSString*)tag message:(NSString*)msg error:(NSError*)e
{
    [self log:kLevelDebug tag:tag message:msg error:e];
}

- (void)info:(NSString*)tag message:(NSString*)msg
{
    [self log:kLevelInfo tag:tag message:msg];
}

- (void)info:(NSString*)tag message:(NSString*)msg exception:(NSException*)e
{
    [self log:kLevelInfo tag:tag message:msg exception:e];
}

- (void)info:(NSString*)tag message:(NSString*)msg error:(NSError*)e
{
    [self log:kLevelInfo tag:tag message:msg error:e];
}

- (void)warn:(NSString*)tag message:(NSString*)msg
{
    [self log:kLevelWarn tag:tag message:msg];
}

- (void)warn:(NSString*)tag message:(NSString*)msg exception:(NSException*)e
{
    [self log:kLevelWarn tag:tag message:msg exception:e];
}

- (void)warn:(NSString*)tag message:(NSString*)msg error:(NSError*)e
{
    [self log:kLevelWarn tag:tag message:msg error:e];
}

- (void)error:(NSString*)tag message:(NSString*)msg
{
    [self log:kLevelError tag:tag message:msg];
}

- (void)error:(NSString*)tag message:(NSString*)msg exception:(NSException*)e
{
    [self log:kLevelError tag:tag message:msg exception:e];
}

- (void)error:(NSString*)tag message:(NSString*)msg error:(NSError*)e
{
    [self log:kLevelError tag:tag message:msg error:e];
}

- (void)assert:(NSString*)tag message:(NSString*)msg
{
    [self log:kLevelAssert tag:tag message:msg];
}

- (void)assert:(NSString*)tag message:(NSString*)msg exception:(NSException*)e
{
    [self log:kLevelAssert tag:tag message:msg exception:e];
}

- (void)assert:(NSString*)tag message:(NSString*)msg error:(NSError*)e
{
    [self log:kLevelAssert tag:tag message:msg error:e];
}

@end
