//
//  ApigeeNSURLSessionDataTaskInfo.m
//  ApigeeiOSSDK
//
//  Created by Paul Dardeau on 10/7/13.
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeNSURLSessionDataTaskInfo.h"
#import "ApigeeNetworkEntry.h"

@implementation ApigeeNSURLSessionDataTaskInfo

@synthesize startTime;
@synthesize sessionDataTask;
@synthesize networkEntry;
@synthesize completionHandler;
@synthesize dataSize;
@synthesize key;

- (id)init
{
    self = [super init];
    if( self )
    {
        self.dataSize = 0;
    }
    
    return self;
}

- (void)debugPrint
{
    NSLog(@"========= Start ApigeeNSURLSessionDataTaskInfo ======");
    NSLog(@"startTime=%@", self.startTime);
    NSLog(@"sessionDataTask=%@", self.sessionDataTask);
    if( self.networkEntry )
    {
        [self.networkEntry debugPrint];
    }
    else
    {
        NSLog(@"networkEntry is nil");
    }
    NSLog(@"completionHandler=%@", self.completionHandler);
    NSLog(@"dataSize=%d", self.dataSize);
    NSLog(@"key=%@", self.key);
    NSLog(@"========= End ApigeeNSURLSessionDataTaskInfo ======");
}

@end
