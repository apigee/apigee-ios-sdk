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
