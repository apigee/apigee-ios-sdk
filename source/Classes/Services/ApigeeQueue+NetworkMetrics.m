/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
