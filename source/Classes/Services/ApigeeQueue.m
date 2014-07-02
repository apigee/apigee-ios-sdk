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
