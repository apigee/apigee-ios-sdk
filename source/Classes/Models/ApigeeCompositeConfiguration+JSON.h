//
//  ApigeeCompositeConfiguration+JSON.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeCompositeConfiguration.h"


@interface ApigeeCompositeConfiguration (JSON)

+ (ApigeeCompositeConfiguration *) fromDictionary:(NSDictionary *) jsonObjects;

@end
