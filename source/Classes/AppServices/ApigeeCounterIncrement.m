//
//  ApigeeCounterIncrement.m
//  ApigeeiOSSDK
//
//  Created by Paul Dardeau on 1/16/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "ApigeeCounterIncrement.h"

@implementation ApigeeCounterIncrement

- (id)init
{
    self = [super init];
    if (self) {
        self.counterIncrementValue = 1;
    }
    
    return self;
}

- (id)initWithName:(NSString*)theCounterName
    incrementValue:(NSUInteger)theCounterIncrementValue
{
    self = [super init];
    if (self) {
        self.counterName = theCounterName;
        self.counterIncrementValue = theCounterIncrementValue;
    }
    
    return self;
}

@end
