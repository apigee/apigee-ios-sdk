//
//  ApigeeUIEventSwitchToggled.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApigeeUIControlEvent.h"

@interface ApigeeUIEventSwitchToggled : ApigeeUIControlEvent
{
    BOOL _switchIsOn;
}

@property(nonatomic) BOOL switchIsOn;

- (NSString*)trackingEntry;

@end
