//
//  ApigeeUIControlEvent.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApigeeUIControlEvent : NSObject
{
    NSString* _restorationIdentifier;
    NSString* _nibName;
    NSDate* _eventTime;
    int _tag;
    int _x;
    int _y;
    int _width;
    int _height;
}

@property(strong, nonatomic) NSString* restorationIdentifier;
@property(strong, nonatomic) NSString* nibName;
@property(strong, nonatomic) NSDate* eventTime;
@property(nonatomic) int tag;
@property(nonatomic) int x;
@property(nonatomic) int y;
@property(nonatomic) int width;
@property(nonatomic) int height;

- (void)populateWithControl:(UIControl*)control;
- (void)populateCoordinates:(CGRect)rect;

- (NSString*)trackingEntry;

@end
