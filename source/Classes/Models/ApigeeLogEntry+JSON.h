//
//  ApigeeLogEntry+JSON.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeLogEntry.h"

/*!
 @internal
 */
@interface ApigeeLogEntry (JSON)

+ (NSArray *) toDictionaries:(NSArray *) logEntries;

@end
