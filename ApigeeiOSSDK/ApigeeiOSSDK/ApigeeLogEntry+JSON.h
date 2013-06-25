//
//  ApigeeLogEntry+JSON.h
//  ApigeeAppMonitor
//
//  Created by jaminschubert on 9/27/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeLogEntry.h"

@interface ApigeeLogEntry (JSON)

+ (NSArray *) toDictionaries:(NSArray *) logEntries;

@end
