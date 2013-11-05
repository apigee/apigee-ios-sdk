//
//  ApigeeUIEventListener.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApigeeUIEventScreenVisibility;
@class ApigeeUIEventButtonPress;
@class ApigeeUIEventSwitchToggled;
@class ApigeeUIEventSegmentSelected;


@protocol ApigeeUIEventListener <NSObject>

- (void)screenVisibilityChanged:(ApigeeUIEventScreenVisibility*)screenEvent;
- (void)buttonPressed:(ApigeeUIEventButtonPress*)buttonPressEvent;
- (void)switchToggled:(ApigeeUIEventSwitchToggled*)switchToggledEvent;
- (void)segmentSelected:(ApigeeUIEventSegmentSelected*)segmentSelectedEvent;
- (BOOL)invokeOnMainThread;

@end
