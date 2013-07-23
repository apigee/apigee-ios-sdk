//
//  ApigeeSessionMetricsCompiler.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeSessionMetrics.h"
#import "ApigeeActiveSettings.h"

@interface ApigeeSessionMetricsCompiler : NSObject

+ (ApigeeSessionMetricsCompiler *) systemCompiler;

- (ApigeeSessionMetrics *) compileMetricsForSettings:(ApigeeActiveSettings *) settings;

@end
