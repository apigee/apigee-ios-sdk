//
//  MetricsEntry.m
//  ApigeeAppMonitoring
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeModelUtils.h"
#import "ApigeeMetricsEntry.h"

@implementation ApigeeMetricsEntry

@synthesize appConfigType;
@synthesize appId;
@synthesize applicationVersion;
@synthesize deviceId;
@synthesize deviceModel;
@synthesize deviceOSVersion;
@synthesize devicePlatform;
@synthesize deviceType;
@synthesize endDay;
@synthesize endHour;
@synthesize endMinute;
@synthesize endMonth;
@synthesize endTime;
@synthesize endWeek;
@synthesize identifier;
@synthesize isNetworkRoaming;
@synthesize latitude;
@synthesize longitude;
@synthesize latency;
@synthesize networkCarrier;
@synthesize networkCountry;
@synthesize networkType;
@synthesize numErrors;
@synthesize numSamples;
@synthesize url;
@synthesize sessionId;
@synthesize startTime;
@synthesize timeStamp;
@synthesize transactionDetails;

- (NSDictionary*) asDictionary
{
    return [ApigeeModelUtils asDictionary:self];
}
         
@end
