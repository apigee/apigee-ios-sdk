//
//  ApigeeNetworkEntry.m
//  ApigeeAppMonitor
//
//  Created by jaminschubert on 10/24/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "NSDate+Apigee.h"
#import "ApigeeModelUtils.h"
#import "ApigeeNetworkEntry.h"

static const NSUInteger kMaxUrlLength = 100;


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

- (id) initWithURL:(NSString *) theUrl started:(NSDate *) started ended:(NSDate *) ended
{
    self = [super init];
    
    if (self) {
        
        if ([theUrl length] > kMaxUrlLength) {
            self.url = [theUrl substringToIndex:kMaxUrlLength];
        } else {
            self.url = [theUrl copy];
        }
        
        NSDate *copyOfStartedDate = [started copy];
        NSString* startedTimestampMillis = [NSDate stringFromMilliseconds:[started dateAsMilliseconds]];
        self.timeStamp = startedTimestampMillis;
        self.startTime = startedTimestampMillis;
        self.endTime = [NSDate stringFromMilliseconds:[ended dateAsMilliseconds]];
        
        const long latencyMillis = [ended timeIntervalSinceDate:copyOfStartedDate] * 1000;
        
        self.latency = [NSString stringWithFormat:@"%ld", latencyMillis ];
        self.numSamples = @"1";
        self.numErrors = @"0";
    }
    
    return self;
}

- (NSDictionary*) asDictionary
{
    return [ApigeeModelUtils asDictionary:self];
}

@end
