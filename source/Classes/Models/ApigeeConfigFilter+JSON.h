//
//  ApigeeConfigFilter+JSON.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeConfigFilter.h"


@interface ApigeeConfigFilter (JSON)

+ (NSArray *) transformArray:(NSArray *) jsonObjects;
+ (ApigeeConfigFilter *) fromDictionary:(NSDictionary *) jsonObjects;

@end
