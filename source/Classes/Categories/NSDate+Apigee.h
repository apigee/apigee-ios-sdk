//
//  NSDate+Apigee.h
//  ApigeeiOSSDK
//
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
