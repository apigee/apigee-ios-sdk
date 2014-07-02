/*
 * Copyright 2014 Apigee Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

/*!
 @abstract The ApigeeQueue class implements the functionality of a standard
    queue.
 */
@interface ApigeeQueue : NSObject

/*!
 @abstract Initializes the queue and reserves the specified capacity.
 @param capacity The desired capacity for the queue.
 */
- (id)initWithCapacity:(NSUInteger)capacity;

/*!
 @abstract Retrieves object at the front of the queue.
 @return The object at the front of the queue, or nil if there are none.
 */
- (id) dequeue;

/*!
 @abstract Retrieves and removes all items currently in the queue.
 @return Array of all items that were in the queue at the time call was made.
 */
- (NSArray *) dequeueAll;

/*!
 @abstract Adds a new object to the back of the queue.
 @param The new object to be added to the queue.
 */
- (void) enqueue:(id) obj;

/*!
 @abstract Discards all objects that are currently in the queue.
 */
- (void) removeAllObjects;

@end
