//
//  MetricsEntry.h
//  ApigeeAppMonitoring
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

@interface ApigeeMetricsEntry : NSObject

@property (strong, nonatomic) NSString *appConfigType;
@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *applicationVersion;
@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSString *deviceModel;
@property (strong, nonatomic) NSString *deviceOperatingSystem;
@property (strong, nonatomic) NSString *devicePlatform;
@property (strong, nonatomic) NSString *deviceType;
@property (strong, nonatomic) NSString *endDay;
@property (strong, nonatomic) NSString *endHour;
@property (strong, nonatomic) NSString *endMinute;
@property (strong, nonatomic) NSString *endMonth;
@property (strong, nonatomic) NSString *endTime;
@property (strong, nonatomic) NSString *endWeek;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *isNetworkRoaming;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *latency;
@property (strong, nonatomic) NSString *networkCarrier;
@property (strong, nonatomic) NSString *networkCountry;
@property (strong, nonatomic) NSString *networkType;
@property (strong, nonatomic) NSString *numErrors;
@property (strong, nonatomic) NSString *numSamples;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *sessionId;
@property (strong, nonatomic) NSString *startTime;
@property (strong, nonatomic) NSString *timeStamp;
@property (strong, nonatomic) NSString *transactionDetails;

- (NSDictionary*) asDictionary;

@end
