//
//  ApigeeUIEventSegmentSelected.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeUIEventSegmentSelected.h"

@implementation ApigeeUIEventSegmentSelected

@synthesize segmentTitle=_segmentTitle;
@synthesize selectedSegmentIndex=_selectedSegmentIndex;

- (id)init
{
    self = [super init];
    if( self )
    {
        _selectedSegmentIndex = -1;
    }
    
    return self;
}

- (NSString*)trackingEntry
{
    return [NSString stringWithFormat:@"Segment selected '%@' index=%d %@",
            self.segmentTitle,
            self.selectedSegmentIndex,
            [super trackingEntry]];
}

@end
