//
//  ApigeeUIEventManager.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ApigeeUIEventListener;
@class ApigeeUIEventButtonPress;
@class ApigeeUIEventScreenVisibility;
@class ApigeeUIEventSwitchToggled;
@class ApigeeUIEventSegmentSelected;


@interface ApigeeUIEventManager : NSObject
{
    NSMutableArray* _listListeners;
    NSString* _nibName;
    BOOL _isOnIphone;
}

@property(strong,nonatomic) NSMutableArray* listListeners;
@property(strong,nonatomic) NSString* nibName;

+ (ApigeeUIEventManager*)sharedInstance;

- (void)addUIEventListener:(id<ApigeeUIEventListener>)listener;
- (void)removeUIEventListener:(id<ApigeeUIEventListener>)listener;

- (void)notifyButtonPress:(ApigeeUIEventButtonPress*)buttonPressEvent;
- (void)notifyScreenVisibilityChange:(ApigeeUIEventScreenVisibility*)screenVisibilityEvent;
- (void)notifySwitchToggled:(ApigeeUIEventSwitchToggled*)switchToggledEvent;
- (void)notifySegmentSelected:(ApigeeUIEventSegmentSelected*)segmentSelectedEvent;

- (void)setUpApigeeSwizzling;

@end
