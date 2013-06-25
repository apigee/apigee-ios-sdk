//
//  ApigeeSessionMetricsCompiler.h
//  ApigeeAppMonitor
//
//  Created by jaminschubert on 9/21/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeSessionMetrics.h"
#import "ApigeeActiveSettings.h"

@interface ApigeeSessionMetricsCompiler : NSObject

+ (ApigeeSessionMetricsCompiler *) systemCompiler;

- (ApigeeSessionMetrics *) compileMetricsForSettings:(ApigeeActiveSettings *) settings;

@end
