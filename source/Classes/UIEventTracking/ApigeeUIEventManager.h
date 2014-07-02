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

@protocol ApigeeUIEventListener;
@class ApigeeUIEventButtonPress;
@class ApigeeUIEventScreenVisibility;
@class ApigeeUIEventSwitchToggled;
@class ApigeeUIEventSegmentSelected;


@interface ApigeeUIEventManager : NSObject
{
    NSMutableArray* _listListeners;
    NSString* _nibName;
    BOOL _isOnIphone;
}

@property(strong,nonatomic) NSMutableArray* listListeners;
@property(strong,nonatomic) NSString* nibName;

+ (ApigeeUIEventManager*)sharedInstance;

- (void)addUIEventListener:(id<ApigeeUIEventListener>)listener;
- (void)removeUIEventListener:(id<ApigeeUIEventListener>)listener;

- (void)notifyButtonPress:(ApigeeUIEventButtonPress*)buttonPressEvent;
- (void)notifyScreenVisibilityChange:(ApigeeUIEventScreenVisibility*)screenVisibilityEvent;
- (void)notifySwitchToggled:(ApigeeUIEventSwitchToggled*)switchToggledEvent;
- (void)notifySegmentSelected:(ApigeeUIEventSegmentSelected*)segmentSelectedEvent;

- (void)setUpApigeeSwizzling;

@end
