/*
 * Copyright 2014 Apigee Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
