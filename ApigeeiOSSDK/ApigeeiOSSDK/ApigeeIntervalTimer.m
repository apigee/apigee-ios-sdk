//
//  ApigeeIntervalTimer.m
//  ApigeeAppMonitor
//
//  Created by jaminschubert on 9/20/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeIntervalTimer.h"

#define kApigeeTimerLeeway 1ull

@interface TimerParameters : NSObject
{
    NSTimeInterval _timeInterval;
    id _target;
    SEL _targetSelector;
    BOOL _repeats;
}

@property(nonatomic,assign) NSTimeInterval timeInterval;
@property(strong) id target;
@property(assign) SEL targetSelector;
@property(assign) BOOL repeats;

@end

@implementation TimerParameters

@synthesize timeInterval=_timeInterval;
@synthesize target=_target;
@synthesize targetSelector=_targetSelector;
@synthesize repeats=_repeats;

@end

@interface ApigeeIntervalTimer ()

@property (strong) NSTimer *timer;

@end

@implementation ApigeeIntervalTimer

#pragma mark - Initialization / Clean up

- (void)setUpTimer:(TimerParameters*)timerParameters
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timerParameters.timeInterval
                                                  target:timerParameters.target
                                                selector:timerParameters.targetSelector
                                                userInfo:nil
                                                 repeats:timerParameters.repeats];
}

#pragma mark - Public interface

- (void) fireOnInterval:(NSTimeInterval)interval
                 target:(id)target
               selector:(SEL)targetSelector
                repeats:(BOOL)repeats
{
    if( [NSThread isMainThread] )
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                      target:target
                                                    selector:targetSelector
                                                    userInfo:nil
                                                     repeats:repeats];
    }
    else
    {
        TimerParameters* timerParams = [[TimerParameters alloc] init];
        timerParams.timeInterval = interval;
        timerParams.target = target;
        timerParams.targetSelector = targetSelector;
        timerParams.repeats = repeats;
        
        [self performSelectorOnMainThread:@selector(setUpTimer:)
                               withObject:timerParams
                            waitUntilDone:NO];
    }
}

- (void) cancel
{
    [self.timer invalidate];
}

@end
