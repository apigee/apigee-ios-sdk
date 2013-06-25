//
//  LogEntry.m
//  ApigeeAppMonitoring
//
//  Created by Sam Griffith on 2/24/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeModelUtils.h"
#import "ApigeeLogEntry.h"

@implementation ApigeeLogEntry

@synthesize tag;
@synthesize logLevel;
@synthesize logMessage;
@synthesize timeStamp;

- (NSDictionary*) asDictionary
{
    return [ApigeeModelUtils asDictionary:self];
}

@end
