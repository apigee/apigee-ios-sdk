//
//  ApigeeQueue.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApigeeQueue : NSObject

- (id)initWithCapacity:(NSUInteger)capacity;

- (id) dequeue;
- (NSArray *) dequeueAll;
- (void) enqueue:(id) obj;
- (void) removeAllObjects;

@end
