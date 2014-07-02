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

#import "ApigeeEntity.h"

/*!
 @class ApigeeUser
 @abstract Class representing data associated with a user
 @see ApigeeEntity ApigeeEntity
 */
@interface ApigeeUser : ApigeeEntity

@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* firstname;
@property (strong, nonatomic) NSString* middlename;
@property (strong, nonatomic) NSString* lastname;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* picture;
@property (assign, nonatomic) BOOL activated;
@property (assign, nonatomic) BOOL disabled;

/*!
 @abstract Initializes an empty user object
 @param dataClient instance of ApigeeDataClient
 @see ApigeeDataClient ApigeeDataClient
 */
- (id)initWithDataClient:(ApigeeDataClient*)dataClient;

/*!
 @abstract Initializes with an ApigeeEntity object
 @param entity the ApigeeEntity object to use for initialization
 @see ApigeeEntity ApigeeEntity
 */
- (id)initWithEntity:(ApigeeEntity*)entity;

/*!
 @abstract Compares the specified type name to the type name for ApigeeUser
 @param type the type name to compare with
 @return boolean indicating whether the specified type name is the same as
    the type name for ApigeeUser
 */
+ (BOOL)isSameType:(NSString*)type;

@end
