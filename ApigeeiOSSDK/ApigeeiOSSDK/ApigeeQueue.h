//
//  ApigeeQueue.h
//  ApigeeAppMonitor
//
//  Created by jaminschubert on 10/25/12.
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
