//
//  ApigeeQueue+NetworkMetrics.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeQueue+NetworkMetrics.h"
#import "ApigeeNetworkEntry.h"
#import "NSString+Apigee.h"
#import "ApigeeMonitoringClient.h"

static const NSUInteger kMaxQueueDepth = 100;

@interface ApigeeMonitoringClient (NetworkActivityTracking)

- (void) updateLastNetworkTransmissionTime:(NSString*) networkTransmissionTime;

@end

@implementation ApigeeQueue (NetworkMetrics)

+ (ApigeeQueue *) networkMetricsQueue
{
    static ApigeeQueue *queue;
    
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        queue = [[ApigeeQueue alloc] initWithCapacity:kMaxQueueDepth];
    });
    
    return queue;
}

+ (void) recordNetworkEntry:(ApigeeNetworkEntry*) networkEntry
{
    ApigeeMonitoringClient *monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isParticipatingInSample]) {
        return;
    }
    
    if( ![networkEntry.startTime isEqualToString:@"0"] )
    {
        // See if it's our own SDK network traffic. We don't want
        // those metrics captured.
        NSString *theUrl = [networkEntry.url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        BOOL discardMetrics = NO;

        BOOL isEntryOurURL = [theUrl hasPrefix:[monitoringClient baseURLPath]];
        
        if( isEntryOurURL || [theUrl isEqualToString:@"about:blank"] )
        {
            discardMetrics = YES;
        }
        
        if ( ! discardMetrics ) {
            [[ApigeeQueue networkMetricsQueue] enqueue:networkEntry];
        }
        
        // we have an end time?
        if ([networkEntry.endTime length] > 0) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
            // keep track of the latest network transmission time that we know about
            dispatch_async(queue,^{
                [monitoringClient updateLastNetworkTransmissionTime:networkEntry.endTime];
            });
        }
    }
    else
    {
        NSLog( @"ERROR: not logging networkEntry. startTime is '0'");
    }
}

@end
