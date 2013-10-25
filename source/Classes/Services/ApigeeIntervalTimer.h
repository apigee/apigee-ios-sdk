//
//  ApigeeIntervalTimer.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//


@interface ApigeeIntervalTimer : NSObject

- (void) fireOnInterval:(NSTimeInterval)interval
                 target:(id)target
               selector:(SEL)targetSelector
                repeats:(BOOL)repeats;
- (void) cancel;

@end
