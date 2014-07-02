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

#import "ApigeeAPSPayload.h"
#import "ApigeeAPSAlert.h"

@implementation ApigeeAPSPayload

@synthesize alertText;
@synthesize alertValues;
@synthesize badgeValue;
@synthesize sound;
@synthesize contentAvailable;

- (id)init
{
    self = [super init];
    if (self) {
        self.contentAvailable = NO;
    }
    
    return self;
}

- (NSDictionary*)toDictionary
{
    NSMutableDictionary* dictPayload = [[NSMutableDictionary alloc] init];
    
    if ([self.alertText length] > 0) {
        [dictPayload setValue:self.alertText
                       forKey:@"alert"];
    } else if (self.alertValues) {
        [dictPayload setValue:[self.alertValues toDictionary]
                       forKey:@"alert"];
    }
    
    if (self.badgeValue) {
        int badgeValueInt = [self.badgeValue intValue];
        if (badgeValueInt >= 0) {
            [dictPayload setValue:self.badgeValue
                           forKey:@"badge"];
        }
    }
    
    if ([self.sound length] > 0) {
        [dictPayload setValue:self.sound
                       forKey:@"sound"];
    }
    
    if (self.contentAvailable) {
        [dictPayload setValue:[NSNumber numberWithInt:1]
                       forKey:@"content-available"];
    }
    
    return dictPayload;
}

@end
