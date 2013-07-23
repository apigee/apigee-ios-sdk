//
//  ApigeeNetworkEntry+JSON.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeNetworkEntry.h"
#import "ApigeeNetworkEntry+JSON.h"

@implementation ApigeeNetworkEntry (JSON)

+ (NSArray *) toDictionaries:(NSArray *) networkEntries
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[networkEntries count]];
    
    for (ApigeeNetworkEntry *entry in networkEntries) {
        [array addObject:[entry asDictionary]];
    }
    
    return array;
}

@end
