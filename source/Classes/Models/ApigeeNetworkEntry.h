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

#import <Foundation/Foundation.h>


@interface ApigeeNetworkEntry : NSObject

@property (strong) NSString *url;
@property (strong) NSString *timeStamp;
@property (strong) NSString *startTime;
@property (strong) NSString *endTime;
@property (strong) NSString *latency;
@property (strong) NSString *numSamples;
@property (strong) NSString *numErrors;
@property (strong) NSString *transactionDetails;
@property (strong) NSString *httpStatusCode;
@property (strong) NSString *responseDataSize;
@property (strong) NSString *serverProcessingTime;
@property (strong) NSString *serverReceiptTime;
@property (strong) NSString *serverResponseTime;
@property (strong) NSString *serverId;
@property (strong) NSString *domain;
//@property (strong) NSNumber *allowsCellularAccess;

+ (NSDate*)secondsTimeToDate:(CFTimeInterval)secondsValue;
+ (CFTimeInterval)dateToSecondsTime:(NSDate*)date;

- (id)init;

- (NSDictionary*) asDictionary;

- (void)populateWithURLString:(NSString*)urlString;
- (void)populateWithURL:(NSURL*)theUrl;
- (void)populateWithRequest:(NSURLRequest*)request;
- (void)populateWithResponse:(NSURLResponse*)response;
- (void)populateWithResponseData:(NSData*)responseData;
- (void)populateWithResponseDataSize:(NSUInteger)dataSize;
- (void)populateWithError:(NSError*)error;
- (void)populateStartTime:(CFTimeInterval)started ended:(CFTimeInterval)ended;
- (void)populateStartTimeStamp:(NSDate*)started endTimeStamp:(NSDate*)ended;

- (void)recordStartTime;
- (void)recordEndTime;

- (void)debugPrint;

@end
