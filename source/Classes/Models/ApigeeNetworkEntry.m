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

#import "NSDate+Apigee.h"
#import "ApigeeModelUtils.h"
#import "ApigeeNetworkEntry.h"
#import "ApigeeLogger.h"

static const NSUInteger kMaxUrlLength = 200;

static NSString *kHeaderReceiptTime    = @"x-apigee-receipttime";
static NSString *kHeaderResponseTime   = @"x-apigee-responsetime";
static NSString *kHeaderProcessingTime = @"x-apigee-serverprocessingtime";
static NSString *kHeaderServerId       = @"x-apigee-serverid";

static NSDate* startupTimeDate;
static CFTimeInterval startupTimeSeconds;

@interface ApigeeNetworkEntry ()

@property (strong, nonatomic) NSDate* startNetTime;
@property (strong, nonatomic) NSDate* endNetTime;

@end


@implementation ApigeeNetworkEntry

@synthesize url;
@synthesize timeStamp;
@synthesize startTime;
@synthesize endTime;
@synthesize latency;
@synthesize numSamples;
@synthesize numErrors;
@synthesize transactionDetails;
@synthesize httpStatusCode;
@synthesize responseDataSize;
@synthesize serverProcessingTime;
@synthesize serverReceiptTime;
@synthesize serverResponseTime;
@synthesize serverId;
@synthesize domain;
//@synthesize allowsCellularAccess;

@synthesize startNetTime;
@synthesize endNetTime;

+ (void)load
{
    startupTimeDate = [NSDate date];
    startupTimeSeconds = CACurrentMediaTime();
}

+ (NSDate*)secondsTimeToDate:(CFTimeInterval)secondsValue
{
    CFTimeInterval secondsSinceAppStart = secondsValue - startupTimeSeconds;
    return [startupTimeDate dateByAddingTimeInterval:secondsSinceAppStart];
}

+ (CFTimeInterval)dateToSecondsTime:(NSDate*)date
{
    NSTimeInterval timeIntervalSecondsSinceStartup =
        [date timeIntervalSinceDate:startupTimeDate];
    return timeIntervalSecondsSinceStartup;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.numSamples = @"1";
        self.numErrors = @"0";
    }
    
    return self;
}

- (void)setValue:(id)value forKey:(NSString*)key inDict:(NSMutableDictionary*)dict
{
    if ((value != nil) && ([key length] > 0)) {
        [dict setValue:value forKey:key];
    }
}

- (NSDictionary*) asDictionary
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    [self setValue:self.url forKey:@"url" inDict:dict];
    [self setValue:self.timeStamp forKey:@"timeStamp" inDict:dict];
    [self setValue:self.startTime forKey:@"startTime" inDict:dict];
    [self setValue:self.endTime forKey:@"endTime" inDict:dict];
    [self setValue:self.latency forKey:@"latency" inDict:dict];
    [self setValue:self.numSamples forKey:@"numSamples" inDict:dict];
    [self setValue:self.numErrors forKey:@"numErrors" inDict:dict];
    [self setValue:self.transactionDetails forKey:@"transactionDetails" inDict:dict];
    [self setValue:self.httpStatusCode forKey:@"httpStatusCode" inDict:dict];
    [self setValue:self.responseDataSize forKey:@"responseDataSize" inDict:dict];
    [self setValue:self.serverProcessingTime forKey:@"serverProcessingTime" inDict:dict];
    [self setValue:self.serverReceiptTime forKey:@"serverReceiptTime" inDict:dict];
    [self setValue:self.serverResponseTime forKey:@"serverResponseTime" inDict:dict];
    [self setValue:self.serverId forKey:@"serverId" inDict:dict];
    [self setValue:self.domain forKey:@"domain" inDict:dict];
    
    return dict;
}

- (void)populateWithURLString:(NSString*)urlString
{
    if ([urlString length] > kMaxUrlLength) {
        self.url = [urlString substringToIndex:kMaxUrlLength];
    } else {
        self.url = [urlString copy];
    }
}

- (void)populateWithURL:(NSURL*)theUrl
{
    [self populateWithURLString:[theUrl absoluteString]];
}

- (void)populateWithRequest:(NSURLRequest*)request
{
    [self populateWithURL:request.URL];
    //self.allowsCellularAccess = [NSNumber numberWithBool:request.allowsCellularAccess];
}

- (void)populateWithResponse:(NSURLResponse*)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        
        self.httpStatusCode = [NSString stringWithFormat:@"%ld", (long)[httpResponse statusCode]];
        
        NSDictionary *headerFields = [httpResponse allHeaderFields];
        NSString *receiptTime = [headerFields valueForKey:kHeaderReceiptTime];
        NSString *responseTime = [headerFields valueForKey:kHeaderResponseTime];
        NSString *processingTime = [headerFields valueForKey:kHeaderProcessingTime];
        NSString *theServerId = [headerFields valueForKey:kHeaderServerId];
        
        if ([theServerId length] > 0) {
            self.serverId = theServerId;
        }
        
        if ([processingTime length] > 0) {
            self.serverProcessingTime = processingTime;
        }
        
        if ([receiptTime length] > 0) {
            self.serverReceiptTime = receiptTime;
        }
        
        if ([responseTime length] > 0) {
            self.serverResponseTime = responseTime;
        }
    }
}

- (void)populateWithResponseData:(NSData*)responseData
{
    [self populateWithResponseDataSize:[responseData length]];
}

- (void)populateWithResponseDataSize:(NSUInteger)dataSize
{
    self.responseDataSize = [NSString stringWithFormat:@"%lu", (unsigned long)dataSize];
}

- (void)populateWithError:(NSError*)error
{
    if (error) {
        @try {
            self.transactionDetails = [error localizedDescription];
            self.numErrors = @"1";
        }
        @catch (NSException *exception)
        {
            ApigeeLogWarn(@"MONITOR_CLIENT",
                          @"unable to capture networking error: %@",
                          [exception reason]);
        }
    }
}

- (void)recordStartTime
{
    self.startNetTime = [NSDate date];
}

- (void)recordEndTime
{
    self.endNetTime = [NSDate date];
    [self populateStartTimeStamp:self.startNetTime
                    endTimeStamp:self.endNetTime];
}

- (void)populateStartTime:(CFTimeInterval)started ended:(CFTimeInterval)ended
{
    NSDate* start = [ApigeeNetworkEntry secondsTimeToDate:started];
    NSDate* end = [ApigeeNetworkEntry secondsTimeToDate:ended];
    [self populateStartTimeStamp:start endTimeStamp:end];
}

- (void)populateStartTimeStamp:(NSDate*)started endTimeStamp:(NSDate*)ended
{
    if (started && ended) {
        BOOL datesPassSanityCheck = NO;
        
        NSDate* earlier = [started earlierDate:ended];
        if (earlier != started) {
            if (NSOrderedSame == [started compare:ended]) {
                datesPassSanityCheck = YES;
            } else {
                ApigeeLogError(@"NET_MONITOR",@"end time=%@ precedes start time=%@",ended,started);
            }
        } else {
            datesPassSanityCheck = YES;
        }
        
        if (datesPassSanityCheck) {
            NSString* startedTimestampMillis =
                [NSDate stringFromMilliseconds:[started dateAsMilliseconds]];
            self.timeStamp = startedTimestampMillis;
            self.startTime = startedTimestampMillis;
            self.endTime = [NSDate stringFromMilliseconds:[ended dateAsMilliseconds]];
    
            const NSTimeInterval latencySeconds = [ended timeIntervalSinceDate:started];
            const long latencyMillis = latencySeconds * 1000;
            self.latency = [NSString stringWithFormat:@"%ld", latencyMillis ];
        }
    }
}

- (void)debugPrint
{
    NSLog(@"========= Start ApigeeNetworkEntry ========");
    NSLog(@"url='%@'", self.url);
    NSLog(@"timeStamp='%@'", self.timeStamp);
    NSLog(@"startTime='%@'", self.startTime);
    NSLog(@"endTime='%@'", self.endTime);
    NSLog(@"latency='%@'", self.latency);
    NSLog(@"numSamples='%@'", self.numSamples);
    NSLog(@"numErrors='%@'", self.numErrors);
    NSLog(@"transactionDetails='%@'", self.transactionDetails);
    NSLog(@"httpStatusCode='%@'", self.httpStatusCode);
    NSLog(@"responseDataSize='%@'", self.responseDataSize);
    NSLog(@"serverProcessingTime='%@'", self.serverProcessingTime);
    NSLog(@"serverReceiptTime='%@'", self.serverReceiptTime);
    NSLog(@"serverResponseTime='%@'", self.serverResponseTime);
    NSLog(@"serverId='%@'", self.serverId);
    NSLog(@"domain='%@'", self.domain);
    NSLog(@"========= End ApigeeNetworkEntry ========");
}

@end
