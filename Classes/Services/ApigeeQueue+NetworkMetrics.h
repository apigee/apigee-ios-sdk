//
//  ApigeeQueue+NetworkMetrics.h
//  ApigeeAppMonitor
//
//  Created by jaminschubert on 10/25/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeQueue.h"

@class ApigeeNetworkEntry;


@interface ApigeeQueue (NetworkMetrics)

+ (ApigeeQueue *) networkMetricsQueue;

+ (void) recordNetworkTransaction:(NSURL*) url startTime:(NSDate*) startTime endTime:(NSDate*) endTime;
+ (void) recordNetworkEntry:(ApigeeNetworkEntry*) networkEntry;

@end
