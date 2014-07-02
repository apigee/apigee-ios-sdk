/*
 * Copyright 2014 Apigee Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <sys/time.h>
#import "NSDate+Apigee.h"

@implementation NSDate (Apigee)

+ (int64_t) nowAsMilliseconds
{
    struct timeval t;
    gettimeofday(&t, NULL);
    
    return (((int64_t) t.tv_sec) * kApigeeMillisecondsPerSecond) + (((int64_t) t.tv_usec) / kApigeeMillisecondsPerSecond);
}

- (int64_t) dateAsMilliseconds
{
    return (int64_t) ([self timeIntervalSince1970] * kApigeeMillisecondsPerSecond);
}

+ (NSDate*) dateFromMilliseconds:(int64_t) milliseconds
{
    return [NSDate dateWithTimeIntervalSince1970:(milliseconds / kApigeeMillisecondsPerSecond)];
}

+ (NSString *) stringFromMilliseconds:(int64_t) milliseconds
{
    return [[NSNumber numberWithLongLong:milliseconds] stringValue];
}

+ (NSString*) unixTimestampAsString
{
    return [NSDate stringFromMilliseconds:[NSDate nowAsMilliseconds]];
}

+ (int64_t) unixTimestampAsLong
{
    return [self nowAsMilliseconds];
}

@end
