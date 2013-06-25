//
//  ApigeeCustomConfigParam+JSON.h
//  ApigeeAppMonitor
//
//  Created by jaminschubert on 9/18/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeCustomConfigParam.h"

@interface ApigeeCustomConfigParam (JSON)

+ (NSArray *) transformArray:(NSArray *) jsonObjects;
+ (ApigeeCustomConfigParam *) fromDictionary:(NSDictionary *) jsonObjects;

@end
