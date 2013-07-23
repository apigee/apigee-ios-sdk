//
//  ApigeeQueue.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

// this comment added for a test commit

#import "ApigeeQueue.h"

@interface ApigeeQueue()

@property (strong) NSMutableArray *elements;

@end

@implementation ApigeeQueue

#pragma mark - Initialization

- (id) init
{
    self = [super init];
    
    if (self) {
        self.elements = [NSMutableArray array];
    }
    
    return self;
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    self = [super init];
    
    if (self) {
        self.elements = [NSMutableArray arrayWithCapacity:capacity];
    }
    
    return self;
}

#pragma mark - Interface

- (id) dequeue
{
    @synchronized(self) {
        if (!self.elements.count) {
            return  nil;
        }

        id element = [self.elements objectAtIndex:0];
        [self.elements removeObjectAtIndex:0];

        return element;
    }
}

- (NSArray *) dequeueAll
{
    @synchronized(self) {
        NSArray *all = [NSArray arrayWithArray:self.elements];
        [self.elements removeAllObjects];
        
        return all;
    }
}

- (void) enqueue:(id) obj
{
    @synchronized (self) {
        if (obj) {
            [self.elements addObject:obj];
        }
    }
}

- (void) removeAllObjects
{
    @synchronized (self) {
        [self.elements removeAllObjects];
    }
}

@end
