/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ApigeeNSURLSessionDataTaskInfo.h"
#import "ApigeeNetworkEntry.h"

@implementation ApigeeNSURLSessionDataTaskInfo

@synthesize sessionDataTask;
@synthesize networkEntry;
@synthesize completionHandler;
@synthesize dataSize;
@synthesize key;

- (id)init
{
    self = [super init];
    if( self )
    {
        self.dataSize = 0;
    }
    
    return self;
}

- (void)debugPrint
{
    NSLog(@"========= Start ApigeeNSURLSessionDataTaskInfo ======");
    NSLog(@"sessionDataTask=%@", self.sessionDataTask);
    if( self.networkEntry )
    {
        [self.networkEntry debugPrint];
    }
    else
    {
        NSLog(@"networkEntry is nil");
    }
    NSLog(@"completionHandler=%@", self.completionHandler);
    NSLog(@"dataSize=%lu", (unsigned long)self.dataSize);
    NSLog(@"key=%@", self.key);
    NSLog(@"========= End ApigeeNSURLSessionDataTaskInfo ======");
}

@end
