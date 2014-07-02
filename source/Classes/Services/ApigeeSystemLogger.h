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
