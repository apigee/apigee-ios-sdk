//
//  ApigeeUIControlEvent.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeUIControlEvent.h"

@implementation ApigeeUIControlEvent

@synthesize restorationIdentifier=_restorationIdentifier;
@synthesize nibName=_nibName;
@synthesize eventTime=_eventTime;
@synthesize tag=_tag;
@synthesize x=_x;
@synthesize y=_y;
@synthesize width=_width;
@synthesize height=_height;

- (id)init
{
    self = [super init];
    if( self )
    {
        _tag = -1;
        _x = -1;
        _y = -1;
        _width = -1;
        _height = -1;
    }
    
    return self;
}

- (void)populateWithControl:(UIControl*)control
{
    [self populateCoordinates:control.frame];
    
    if( [control respondsToSelector:@selector(restorationIdentifier)] )
    {
        NSString* restorationIdentifier = control.restorationIdentifier;
        if( [restorationIdentifier length] > 0 )
        {
            self.restorationIdentifier = restorationIdentifier;
        }
    }
    
    if( control.tag > 0 )
    {
        self.tag = control.tag;
    }
}

- (void)populateCoordinates:(CGRect)rect
{
    self.x = rect.origin.x;
    self.y = rect.origin.y;
    self.width = rect.size.width;
    self.height = rect.size.height;
}

- (NSString*)trackingEntry
{
    NSMutableString* trackingString = [[NSMutableString alloc] init];
    
    if (self.tag > -1) {
        [trackingString appendFormat:@"tag=%d", self.tag];
    }
    
    if (self.x > -1 && self.y > -1 && self.width > -1 && self.height > -1) {
        if ([trackingString length] > 0) {
            [trackingString appendString:@","];
        }
        
        [trackingString appendFormat:@"x=%d,y=%d,w=%d,h=%d",
         self.x,
         self.y,
         self.width,
         self.height];
    }

    if ([trackingString length] > 0) {
        [trackingString appendString:@","];
    }
    
    [trackingString appendFormat:@"time=%@",self.eventTime];
    
    if ([self.restorationIdentifier length] > 0) {
        [trackingString appendFormat:@",restoreId=%@", self.restorationIdentifier];
    }
    
    return trackingString;
}

@end
