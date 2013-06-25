//
//  NSDate+Apigee.h
//  ApigeeiOSSDK
//
//  Created by Sam Griffith on 3/20/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#define kApigeeMillisecondsPerSecond 1000

@interface NSDate (Apigee)

+ (int64_t) nowAsMilliseconds;
- (int64_t) dateAsMilliseconds;
+ (NSDate *) dateFromMilliseconds:(int64_t) milliseconds;
+ (NSString *) stringFromMilliseconds:(int64_t) milliseconds;
+ (NSString*) unixTimestampAsString;
+ (int64_t) unixTimestampAsLong;

@end
