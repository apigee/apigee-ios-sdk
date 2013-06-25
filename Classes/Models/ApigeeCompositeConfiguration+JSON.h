//
//  InstaOpsCompositeConfiguration+JSON.h
//  InstaOpsAppMonitor
//
//  Created by jaminschubert on 9/18/12.
//  Copyright (c) 2012 InstaOps. All rights reserved.
//

#import "ApigeeCompositeConfiguration.h"

@interface ApigeeCompositeConfiguration (JSON)

+ (ApigeeCompositeConfiguration *) fromDictionary:(NSDictionary *) jsonObjects;

@end
