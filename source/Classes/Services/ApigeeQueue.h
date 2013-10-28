//
//  ApigeeQueue.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

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
