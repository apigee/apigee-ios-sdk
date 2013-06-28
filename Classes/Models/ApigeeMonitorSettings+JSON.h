//
//  ApigeeMonitorSettings+JSON.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeMonitorSettings.h"

@interface ApigeeMonitorSettings (JSON)

+ (ApigeeMonitorSettings *) fromDictionary:(NSDictionary *) jsonObjects;

@end
