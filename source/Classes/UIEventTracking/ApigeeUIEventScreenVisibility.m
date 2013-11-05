//
//  ApigeeUIEventScreenVisibility.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeUIEventScreenVisibility.h"

@implementation ApigeeUIEventScreenVisibility

@synthesize screenTitle=_screenTitle;
@synthesize restorationIdentifier=_restorationIdentifier;
@synthesize nibName=_nibName;
@synthesize bundleIdentifier=_bundleIdentifier;
@synthesize eventTime=_eventTime;
@synthesize timeOnScreen=_timeOnScreen;
@synthesize haveTimeIntervalValue=_haveTimeIntervalValue;
@synthesize isVisible=_isVisible;

- (id)init
{
    self = [super init];
    if( self )
    {
        _haveTimeIntervalValue = NO;
        _isVisible = NO;
    }
    
    return self;
}

- (NSString*)trackingEntry
{
    NSMutableString* trackingString = [[NSMutableString alloc] init];

    if ([self.screenTitle length] > 0) {
        [trackingString appendFormat:@"Screen '%@'", self.screenTitle];
    } else {
        [trackingString appendFormat:@"Screen"];
    }
    
    if ([self.restorationIdentifier length] > 0) {
        [trackingString appendFormat:@", restoreId=%@", self.restorationIdentifier];
    }
    
    if (self.isVisible) {
        [trackingString appendString:@", visible=YES"];
    } else {
        [trackingString appendString:@", visible=NO"];
    }
    
    [trackingString appendFormat:@", event=%@", self.eventTime];
    
    if (self.haveTimeIntervalValue) {
        [trackingString appendFormat:@", timeOnScreen=%f", self.timeOnScreen];
    }
    
    return trackingString;
}

@end
