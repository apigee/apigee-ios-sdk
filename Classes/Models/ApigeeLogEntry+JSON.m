//
//  ApigeeLogEntry+JSON.m
//  ApigeeAppMonitor
//
//  Created by jaminschubert on 9/27/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeLogEntry.h"
#import "ApigeeLogEntry+JSON.h"

@implementation ApigeeLogEntry (JSON)

+ (NSArray *) toDictionaries:(NSArray *) logEntries
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[logEntries count]];
    
    for (ApigeeLogEntry *entry in logEntries) {
        [array addObject:[entry asDictionary]];
    }
    
    return array;
}

@end
