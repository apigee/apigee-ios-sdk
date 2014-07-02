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

#import "ApigeeLogging.h"

/*!
 @class ApigeeDefaultiOSLog
 @abstract
 */
@interface ApigeeDefaultiOSLog : NSObject <ApigeeLogging>

- (void)verbose:(NSString*)tag message:(NSString*)msg;
- (void)verbose:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;
- (void)verbose:(NSString*)tag message:(NSString*)msg error:(NSError*)e;

- (void)debug:(NSString*)tag message:(NSString*)msg;
- (void)debug:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;
- (void)debug:(NSString*)tag message:(NSString*)msg error:(NSError*)e;

- (void)info:(NSString*)tag message:(NSString*)msg;
- (void)info:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;
- (void)info:(NSString*)tag message:(NSString*)msg error:(NSError*)e;

- (void)warn:(NSString*)tag message:(NSString*)msg;
- (void)warn:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;
- (void)warn:(NSString*)tag message:(NSString*)msg error:(NSError*)e;

- (void)error:(NSString*)tag message:(NSString*)msg;
- (void)error:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;
- (void)error:(NSString*)tag message:(NSString*)msg error:(NSError*)e;

- (void)assert:(NSString*)tag message:(NSString*)msg;
- (void)assert:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;
- (void)assert:(NSString*)tag message:(NSString*)msg error:(NSError*)e;

@end
