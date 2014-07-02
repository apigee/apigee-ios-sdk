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

#import "ApigeeAPSAlert.h"

@implementation ApigeeAPSAlert

@synthesize body;
@synthesize actionLocKey;
@synthesize locKey;
@synthesize locArgs;
@synthesize launchImage;

- (void)setValue:(id)value forKey:(NSString*)key into:(NSMutableDictionary*)dict
{
    if (value) {
        [dict setValue:value forKey:key];
    } else {
        [dict setValue:[NSNull null] forKey:key];
    }
}

- (NSDictionary*)toDictionary
{
    NSMutableDictionary* dictAlert = [[NSMutableDictionary alloc] init];
    
    [self setValue:self.body forKey:@"body" into:dictAlert];
    [self setValue:self.actionLocKey forKey:@"action-loc-key" into:dictAlert];
    [self setValue:self.locKey forKey:@"loc-key" into:dictAlert];
    [self setValue:self.locArgs forKey:@"loc-args" into:dictAlert];
    [self setValue:self.launchImage forKey:@"launch-image" into:dictAlert];
    
    return dictAlert;
}

@end
