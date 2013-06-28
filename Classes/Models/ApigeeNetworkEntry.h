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

- (id) initWithURL:(NSString *) url started:(NSDate *) started ended:(NSDate *) ended;
- (NSDictionary*) asDictionary;

@end
