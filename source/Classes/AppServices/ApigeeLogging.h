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

/*!
 @protocol ApigeeLogging
 @abstract The protocol expected for a logging object used by App Services
 */
@protocol ApigeeLogging<NSObject>

/*!
 @methodgroup Verbose Logging Methods
 */
/*!
 @abstract Logs a message with log level of verbose
 @param tag The component or layer reporting the message
 @param msg The string message to log
 */
- (void)verbose:(NSString*)tag message:(NSString*)msg;

/*!
 @abstract Logs a message and exception with log level of verbose
 @param tag The component or layer reporting the message
 @param msg The string message to log
 @param e The exception to log
 */
- (void)verbose:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;

/*!
 @abstract Logs a message and error with log level of verbose
 @param tag The component or layer reporting the message
 @param msg The string message to log
 @param e The error to log
 */
- (void)verbose:(NSString*)tag message:(NSString*)msg error:(NSError*)e;


/*!
 @methodgroup Debug Logging Methods
 */
/*!
 @abstract Logs a message with log level of debug
 @param tag The component or layer reporting the message
 @param msg The string message to log
 */
- (void)debug:(NSString*)tag message:(NSString*)msg;

/*!
 @abstract Logs a message and exception with log level of debug
 @param tag The component or layer reporting the message
 @param msg The string message to log
 @param e The exception to log
 */
- (void)debug:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;

/*!
 @abstract Logs a message and error with log level of debug
 @param tag The component or layer reporting the message
 @param msg The string message to log
 @param e The error to log
 */
- (void)debug:(NSString*)tag message:(NSString*)msg error:(NSError*)e;


/*!
 @methodgroup Info Logging Methods
 */
/*!
 @abstract Logs a message with log level of info
 @param tag The component or layer reporting the message
 @param msg The string message to log
 */
- (void)info:(NSString*)tag message:(NSString*)msg;

/*!
 @abstract Logs a message and exception with log level of info
 @param tag The component or layer reporting the message
 @param msg The string message to log
 @param e The exception to log
 */
- (void)info:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;

/*!
 @abstract Logs a message and error with log level of info
 @param tag The component or layer reporting the message
 @param msg The string message to log
 @param e The error to log
 */
- (void)info:(NSString*)tag message:(NSString*)msg error:(NSError*)e;


/*!
 @methodgroup Warn Logging Methods
 */
/*!
 @abstract Logs a message with log level of warn
 @param tag The component or layer reporting the message
 @param msg The string message to log
 */
- (void)warn:(NSString*)tag message:(NSString*)msg;

/*!
 @abstract Logs a message and exception with log level of warn
 @param tag The component or layer reporting the message
 @param msg The string message to log
 @param e The exception to log
 */
- (void)warn:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;

/*!
 @abstract Logs a message and error with log level of warn
 @param tag The component or layer reporting the message
 @param msg The string message to log
 @param e The error to log
 */
- (void)warn:(NSString*)tag message:(NSString*)msg error:(NSError*)e;


/*!
 @methodgroup Error Logging Methods
 */
/*!
 @abstract Logs a message with log level of error
 @param tag The component or layer reporting the message
 @param msg The string message to log
 */
- (void)error:(NSString*)tag message:(NSString*)msg;

/*!
 @abstract Logs a message and exception with log level of error
 @param tag The component or layer reporting the message
 @param msg The string message to log
 @param e The exception to log
 */
- (void)error:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;

/*!
 @abstract Logs a message and error with log level of error
 @param tag The component or layer reporting the message
 @param msg The string message to log
 @param e The error to log
 */
- (void)error:(NSString*)tag message:(NSString*)msg error:(NSError*)e;


/*!
 @methodgroup Assert/Critical Error Logging Methods
 */
/*!
 @abstract Logs a message with log level of assert/critical
 @param tag The component or layer reporting the message
 @param msg The string message to log
 */
- (void)assert:(NSString*)tag message:(NSString*)msg;

/*!
 @abstract Logs a message and exception with log level of assert/critical
 @param tag The component or layer reporting the message
 @param msg The string message to log
 @param e The exception to log
 */
- (void)assert:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;

/*!
 @abstract Logs a message and error with log level of assert/critical
 @param tag The component or layer reporting the message
 @param msg The string message to log
 @param e The error to log
 */
- (void)assert:(NSString*)tag message:(NSString*)msg error:(NSError*)e;


@end
