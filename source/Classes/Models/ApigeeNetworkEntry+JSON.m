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

#import "ApigeeNetworkEntry.h"
#import "ApigeeNetworkEntry+JSON.h"

@implementation ApigeeNetworkEntry (JSON)

+ (NSArray *) toDictionaries:(NSArray *) networkEntries
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[networkEntries count]];
    
    for (ApigeeNetworkEntry *entry in networkEntries) {
        [array addObject:[entry asDictionary]];
    }
    
    return array;
}

@end
