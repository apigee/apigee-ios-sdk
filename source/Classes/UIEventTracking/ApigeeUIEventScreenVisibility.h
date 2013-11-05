//
//  ApigeeUIEventScreenVisibility.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApigeeUIEventScreenVisibility : NSObject
{
    NSString* _screenTitle;
    NSString* _restorationIdentifier;
    NSString* _nibName;
    NSString* _bundleIdentifier;
    NSDate* _eventTime;
    NSTimeInterval _timeOnScreen;
    BOOL _haveTimeIntervalValue;
    BOOL _isVisible;
}

@property(strong, nonatomic) NSString* screenTitle;
@property(strong, nonatomic) NSString* restorationIdentifier;
@property(strong, nonatomic) NSString* nibName;
@property(strong, nonatomic) NSString* bundleIdentifier;
@property(strong, nonatomic) NSDate* eventTime;
@property(nonatomic) NSTimeInterval timeOnScreen;
@property(nonatomic) BOOL haveTimeIntervalValue;
@property(nonatomic) BOOL isVisible;

- (NSString*)trackingEntry;

@end
