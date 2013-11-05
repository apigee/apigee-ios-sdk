//
//  ApigeeUIEventButtonPress.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApigeeUIControlEvent.h"

@interface ApigeeUIEventButtonPress : ApigeeUIControlEvent
{
    NSString* _buttonTitle;
    BOOL _isBarButton;
}

@property(strong, nonatomic) NSString* buttonTitle;
@property(nonatomic) BOOL isBarButton;

- (NSString*)trackingEntry;

@end
