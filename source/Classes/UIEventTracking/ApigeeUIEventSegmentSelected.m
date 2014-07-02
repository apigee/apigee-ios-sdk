/*
 * Copyright 2014 Apigee Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
