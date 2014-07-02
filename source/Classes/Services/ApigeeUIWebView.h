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

#import <UIKit/UIKit.h>

/*!
 @class ApigeeUIWebView
 @abstract UIWebView with built-in network performance capture
 @discussion Note that HTTP status codes are not reported for calls made from
    this class because they're not accessible from UIWebView.
 */
@interface ApigeeUIWebView : UIWebView

/*!
 @abstract Initialization for NSCoding
 @param aDecoder an NSCoder instance for data population
 */
- (id) initWithCoder:(NSCoder *)aDecoder;

/*!
 @abstract Initialization with frame rectangle
 @param frame the rectangle frame for initial size and placement
 */
- (id) initWithFrame:(CGRect)frame;

/*!
 @abstract Sets the delegate for event callbacks
 @param delegate the UIWebViewDelegate to use for event callbacks
 */
- (void) setDelegate:(id<UIWebViewDelegate>)delegate;

@end
