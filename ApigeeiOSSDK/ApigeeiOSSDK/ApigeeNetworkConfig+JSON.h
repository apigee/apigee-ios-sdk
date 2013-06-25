//
//  ApigeeNetworkConfig+JSON.h
//  ApigeeAppMonitor
//
//  Created by jaminschubert on 9/18/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeNetworkConfig.h"

@interface ApigeeNetworkConfig (JSON)

+ (ApigeeNetworkConfig *) fromDictionary:(NSDictionary *) jsonObjects;

@end
