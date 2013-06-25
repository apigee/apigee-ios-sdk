//
//  NSDate+InstaOps
//  InstaOpsAppMonitor
//
//  Created by Sam Griffith on 3/20/12.
//  Copyright (c) 2012 InstaOps. All rights reserved.
//

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
