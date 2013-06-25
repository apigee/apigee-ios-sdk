//
//  ApigeeMonitorSettings+JSON.h
//  ApigeeAppMonitor
//
//  Created by jaminschubert on 9/18/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeMonitorSettings.h"

@interface ApigeeMonitorSettings (JSON)

+ (ApigeeMonitorSettings *) fromDictionary:(NSDictionary *) jsonObjects;

@end
