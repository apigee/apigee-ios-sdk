//
//  ApigeeQueue+NetworkMetrics.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeQueue.h"

@class ApigeeNetworkEntry;


/*!
 @category ApigeeQueue (NetworkMetrics)
 @discussion The NetworkMetrics category provides specialized methods for
    handling network metrics.
 */
@interface ApigeeQueue (NetworkMetrics)

/*!
 @abstract Retrieves the queue used for capturing network metrics that are
    awaiting transmission to the server.
 @return The queue used to hold network metrics awaiting transmission to server
 @see ApigeeQueue
 */
+ (ApigeeQueue *) networkMetricsQueue;

/*!
 @abstract Adds a new record of network performance metrics to the queue
 @param networkEntry the network performance metrics record to add to the end
    of the queue.
 @see ApigeeNetworkEntry
 */
+ (void) recordNetworkEntry:(ApigeeNetworkEntry*) networkEntry;

@end
