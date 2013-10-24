//
//  ApigeeCustomConfigParam+JSON.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeCustomConfigParam.h"

/*!
 @internal
 */
@interface ApigeeCustomConfigParam (JSON)

+ (NSArray *) transformArray:(NSArray *) jsonObjects;
+ (ApigeeCustomConfigParam *) fromDictionary:(NSDictionary *) jsonObjects;

@end
