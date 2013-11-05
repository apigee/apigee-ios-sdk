//
//  ApigeeUIEventSwitchToggled.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeUIEventSwitchToggled.h"

@implementation ApigeeUIEventSwitchToggled

@synthesize switchIsOn=_switchIsOn;

- (id)init
{
    self = [super init];
    if( self )
    {
        _switchIsOn = NO;
    }
    
    return self;
}

- (NSString*)trackingEntry
{
    return [NSString stringWithFormat:@"Switch toggled %@ %@",
            _switchIsOn ? @"ON" : @"OFF",
            [super trackingEntry]];
}

@end
