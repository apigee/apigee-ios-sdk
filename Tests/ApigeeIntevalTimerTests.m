//
//  ApigeeIntevalTimerTests.m
//  ApigeeAppMonitor
//
//  Created by jaminschubert on 9/20/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeIntervalTimer.h"

@interface ApigeeIntevalTimerTests : GHTestCase

@property (strong, nonatomic) ApigeeIntervalTimer* timer;
@property (readwrite, nonatomic) NSInteger counts;

@end

@implementation ApigeeIntevalTimerTests

- (void) setUp
{
    [super setUp];
    self.timer = [[ApigeeIntervalTimer alloc] init];
}

- (void) tearDown
{
    self.timer = nil;
    [super setUp];
}

- (void) testRunTimer
{
    self.counts = 0;
    [self.timer fireOnInterval:1 withTask:^{
        self.counts += 1;
    }];
    
    int tries = 0;
    while (tries < 20) {
        
        if (self.counts > 0)
            break;
        
        [NSThread sleepForTimeInterval:1.0];
        tries++;
    }
    
    if (self.counts > 0) {
        [self.timer cancel];
    } else {
        GHFail(@"Timer didn't fire task");
    }
    
    //ensure we can cancel 
    [self.timer cancel];
}

@end
