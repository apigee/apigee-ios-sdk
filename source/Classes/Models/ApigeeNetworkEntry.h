//
//  ApigeeNetworkEntry.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

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

+ (uint64_t)machTime;
+ (CGFloat)millisFromMachStartTime:(uint64_t)startTime endTime:(uint64_t)endTime;
+ (CGFloat)secondsFromMachStartTime:(uint64_t)startTime endTime:(uint64_t)endTime;
+ (NSDate*)machTimeToDate:(uint64_t)machTime;

- (id)init;

- (NSDictionary*) asDictionary;

- (void)populateWithURLString:(NSString*)urlString;
- (void)populateWithURL:(NSURL*)theUrl;
- (void)populateWithRequest:(NSURLRequest*)request;
- (void)populateWithResponse:(NSURLResponse*)response;
- (void)populateWithResponseData:(NSData*)responseData;
- (void)populateWithResponseDataSize:(NSUInteger)dataSize;
- (void)populateWithError:(NSError*)error;
- (void)populateStartTime:(uint64_t)started ended:(uint64_t)ended;

- (void)debugPrint;

@end
