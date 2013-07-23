//
//  ApigeeNetworkConfig+JSON.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeJSONConfigKeys.h"
#import "ApigeeNetworkConfig+JSON.h"

@implementation ApigeeNetworkConfig (JSON)

+ (ApigeeNetworkConfig *) fromDictionary:(NSDictionary *) jsonObjects
{
    if (!jsonObjects) {
        return nil;
    }
     
    ApigeeNetworkConfig *config = [[ApigeeNetworkConfig alloc] init];
    
    config.configId = [[jsonObjects objectForKey:kAppConfigNetowrkConfigId] intValue];
    config.heuristicCachingEnabled = [[jsonObjects objectForKey:kAppConfigNetowrkHueristicCachingEnabled] boolValue];
    config.heuristicCoefficient = [[jsonObjects objectForKey:kAppConfigNetowrkHueristicCoefficient] floatValue];
    config.heuristicDefaultLifetime = [[jsonObjects objectForKey:kAppConfigNetowrkHueristicDefaultLifeTime] integerValue];
    config.isSharedCache = [[jsonObjects objectForKey:kAppConfigNetowrkSharedCache] boolValue];
    config.maxCacheEntries = [[jsonObjects objectForKey:kAppConfigNetworkMaxCacheEntries] integerValue];
    config.maxObjectSizeBytes = [[jsonObjects objectForKey:kAppConfigNetowrkMaxObjectSize] integerValue];
    config.maxUpdateRetries = [[jsonObjects objectForKey:kAppConfigNetowrkMaxUpdateRetries] integerValue];
    
    return config;
}

@end
