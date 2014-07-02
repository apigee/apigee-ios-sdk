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
