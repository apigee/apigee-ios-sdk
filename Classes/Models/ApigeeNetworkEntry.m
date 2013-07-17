//
//  ApigeeNetworkEntry.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "NSDate+Apigee.h"
#import "ApigeeModelUtils.h"
#import "ApigeeNetworkEntry.h"

static const NSUInteger kMaxUrlLength = 100;

static NSString *kHeaderReceiptTime    = @"x-apigee-receipttime";
static NSString *kHeaderResponseTime   = @"x-apigee-responsetime";
static NSString *kHeaderProcessingTime = @"x-apigee-serverprocessingtime";
static NSString *kHeaderServerId       = @"x-apigee-serverid";


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

- (id)init
{
    self = [super init];
    if (self) {
        self.numSamples = @"1";
        self.numErrors = @"0";
    }
    
    return self;
}

- (NSDictionary*) asDictionary
{
    return [ApigeeModelUtils asDictionary:self];
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
        
        self.httpStatusCode = [NSString stringWithFormat:@"%d", [httpResponse statusCode]];
        
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
    self.responseDataSize = [NSString stringWithFormat:@"%d",
                             [responseData length]];
}

- (void)populateWithError:(NSError*)error
{
    if (error) {
        self.numErrors = @"1";
        self.transactionDetails = [error localizedDescription];
    }
}

- (void)populateStartTime:(NSDate*)started ended:(NSDate*)ended
{
    NSDate *copyOfStartedDate = [started copy];
    NSString* startedTimestampMillis = [NSDate stringFromMilliseconds:[started dateAsMilliseconds]];
    self.timeStamp = startedTimestampMillis;
    self.startTime = startedTimestampMillis;
    self.endTime = [NSDate stringFromMilliseconds:[ended dateAsMilliseconds]];
    
    const long latencyMillis = [ended timeIntervalSinceDate:copyOfStartedDate] * 1000;
    
    self.latency = [NSString stringWithFormat:@"%ld", latencyMillis ];
}

@end
