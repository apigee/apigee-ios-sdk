//
//  ApigeeCompositeConfiguration+JSON.h
//  ApigeeiOSSDK
//
//  Created by jaminschubert on 9/18/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeCompositeConfiguration.h"

@interface ApigeeCompositeConfiguration (JSON)

+ (ApigeeCompositeConfiguration *) fromDictionary:(NSDictionary *) jsonObjects;

@end
