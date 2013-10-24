//
//  ApigeeNetworkEntry+JSON.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeNetworkEntry.h"

/*!
 @internal
 */
@interface ApigeeNetworkEntry (JSON)

+ (NSArray *) toDictionaries:(NSArray *) networkEntries;

@end
