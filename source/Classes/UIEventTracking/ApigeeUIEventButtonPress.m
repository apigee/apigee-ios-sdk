//
//  ApigeeUIEventButtonPress.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeUIEventButtonPress.h"

@implementation ApigeeUIEventButtonPress

@synthesize buttonTitle=_buttonTitle;
@synthesize isBarButton=_isBarButton;

- (id)init
{
    self = [super init];
    if( self )
    {
        _isBarButton = NO;
    }
    
    return self;
}

- (NSString*)trackingEntry
{
    NSString* buttonType;
    
    if (self.isBarButton) {
        buttonType = @"Bar button";
    } else {
        buttonType = @"Button";
    }
    
    if ([self.buttonTitle length] > 0) {
        return [NSString stringWithFormat:@"%@ '%@' pressed %@",
                buttonType,
                self.buttonTitle,
                [super trackingEntry]];
    } else {
        return [NSString stringWithFormat:@"%@ pressed %@",
                buttonType,
                [super trackingEntry]];
    }
}

@end
