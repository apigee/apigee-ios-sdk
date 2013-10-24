//
//  ApigeeQueue+NetworkMetrics.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeQueue.h"

@class ApigeeNetworkEntry;

/*!
 @internal
 */
@interface ApigeeQueue (NetworkMetrics)

+ (ApigeeQueue *) networkMetricsQueue;

+ (void) recordNetworkTransaction:(NSURL*) url startTime:(NSDate*) startTime endTime:(NSDate*) endTime;
+ (void) recordNetworkEntry:(ApigeeNetworkEntry*) networkEntry;

@end
