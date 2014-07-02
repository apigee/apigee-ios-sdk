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

#import <Foundation/Foundation.h>

@interface ApigeeUIControlEvent : NSObject
{
    NSString* _restorationIdentifier;
    NSString* _nibName;
    NSDate* _eventTime;
    int _tag;
    int _x;
    int _y;
    int _width;
    int _height;
}

@property(strong, nonatomic) NSString* restorationIdentifier;
@property(strong, nonatomic) NSString* nibName;
@property(strong, nonatomic) NSDate* eventTime;
@property(nonatomic) int tag;
@property(nonatomic) int x;
@property(nonatomic) int y;
@property(nonatomic) int width;
@property(nonatomic) int height;

- (void)populateWithControl:(UIControl*)control;
- (void)populateCoordinates:(CGRect)rect;

- (NSString*)trackingEntry;

@end
