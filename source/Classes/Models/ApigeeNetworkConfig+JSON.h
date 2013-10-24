//
//  ApigeeNetworkConfig+JSON.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeNetworkConfig.h"

/*!
 @internal
 */
@interface ApigeeNetworkConfig (JSON)

+ (ApigeeNetworkConfig *) fromDictionary:(NSDictionary *) jsonObjects;

@end
