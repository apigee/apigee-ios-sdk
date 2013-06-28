//
//  ApigeeCustomConfigParam+JSON.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeJSONConfigKeys.h"
#import "ApigeeCustomConfigParam+JSON.h"

@implementation ApigeeCustomConfigParam (JSON)

+ (NSArray *) transformArray:(NSArray *) jsonObjects
{
    if (!jsonObjects) {
        return nil;
    }
    
    NSMutableArray *params = [NSMutableArray array];
    
    for (NSDictionary *obj in jsonObjects) {
        [params addObject:[self fromDictionary:obj]];
    }
    
    return params;
}

+ (ApigeeCustomConfigParam *) fromDictionary:(NSDictionary *) jsonObjects
{
    if (!jsonObjects) {
        return nil;
    }
    
    ApigeeCustomConfigParam *param = [[ApigeeCustomConfigParam alloc] init];
    
    param.paramId = [[jsonObjects objectForKey:kAppConfigCustomParamId]integerValue];
    param.category = [jsonObjects objectForKey:kAppConfigCustomParamTag];
    param.key = [jsonObjects objectForKey:kAppConfigCustomParamKey];
    param.value = [jsonObjects objectForKey:kAppConfigCustomParamValue];
    
    return param;
}

@end
