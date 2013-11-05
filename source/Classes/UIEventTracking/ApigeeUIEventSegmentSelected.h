//
//  ApigeeUIEventSegmentSelected.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApigeeUIControlEvent.h"

@interface ApigeeUIEventSegmentSelected : ApigeeUIControlEvent
{
    NSString* _segmentTitle;
    int _selectedSegmentIndex;
}

@property(strong, nonatomic) NSString* segmentTitle;
@property(nonatomic) int selectedSegmentIndex;

- (NSString*)trackingEntry;

@end
