//
//  ApigeeConfigFilter+JSON.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeJSONConfigKeys.h"
#import "ApigeeConfigFilter+JSON.h"

@implementation ApigeeConfigFilter (JSON)

+ (NSArray *) transformArray:(NSArray *) jsonObjects
{
    if (!jsonObjects || [jsonObjects isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray array];

    for (NSDictionary *obj in jsonObjects) {
        [array addObject:[self fromDictionary:obj]];
    }

    return array;
}

+ (ApigeeConfigFilter *) fromDictionary:(NSDictionary *) jsonObjects
{
    if (!jsonObjects || [jsonObjects isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    ApigeeConfigFilter *filter = [[ApigeeConfigFilter alloc] init];

    filter.filterId = [[jsonObjects objectForKey:kAppConfigFilterId] integerValue];
    filter.filterType = [jsonObjects objectForKey:kAppConfigFilterType];
    filter.filterValue = [jsonObjects objectForKey:kAppConfigFilterValue];
    
    return filter;
}

@end
