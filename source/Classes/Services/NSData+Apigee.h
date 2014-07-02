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

/*!
 @category NSData (Apigee)
 @discussion This category provides methods that capture network performance
    metrics on built-in NSData methods that perform network calls.
 */
@interface NSData (Apigee)

/*!
 @abstract Creates and returns a data object containing the data from the
    location specified by url.
 @param url The URL from which to read data.
 @param readOptionsMask A mask that specifies options for reading the data.
 @param errorPtr If there is an error reading in the data, upon return contains an NSError object that describes the problem.
 @return A data object containing the data from the location specified by url.
 @discussion This method simply calls the NSData class method
    dataWithContentsOfURL:options:error: while capturing the network performance
    metrics for that call.
 */
+ (NSData*) timedDataWithContentsOfURL:(NSURL *) url
                               options:(NSDataReadingOptions) readOptionsMask
                                 error:(NSError **) errorPtr;

/*!
 @abstract Returns a data object containing the data from the location specified
    by a given URL.
 @param url The URL from which to read data.
 @return A data object containing the data from the location specified by url.
 @discussion This method simply calls the NSData class method dataWithContentsOfURL:
    while capturing the network performance metrics of that call.
 */
+ (NSData*) timedDataWithContentsOfURL:(NSURL *) url;

/*!
 @abstract Returns a data object initialized with the data from the location
    specified by a given URL.
 @param url The URL from which to read data.
 @param readOptionsMask A mask that specifies options for reading the data.
 @param errorPtr If there is an error reading in the data, upon return contains
    an NSError object that describes the problem.
 @return A data object initialized with the data from the location specified by url.
 @discussion This method simply calls the NSData instance method
    initWithContentsOfURL:options:error: while capturing the network performance
    metrics of that call.
 */
- (NSData*) initWithTimedContentsOfURL:(NSURL *) url
                               options:(NSDataReadingOptions) readOptionsMask
                                 error:(NSError **) errorPtr;

/*!
 @abstract Initializes a newly allocated data object initialized with the data
    from the location specified by url.
 @param url The URL from which to read data.
 @return An NSData object initialized with the data from the location specified by url.
 @discussion This method simply calls the NSData instance method initWithContentsOfURL:
    while capturing the network performance metrics of that call.
 */
- (NSData*) initWithTimedContentsOfURL:(NSURL *) url;

/*!
 @abstract Writes the bytes in the receiver to the location specified by a given URL.
 @param url The location to which to write the receiver's bytes.
 @param writeOptionsMask A mask that specifies options for writing the data.
 @param errorPtr If there is an error writing out the data, upon return contains
    an NSError object that describes the problem.
 @return YES if the operation succeeds, otherwise NO.
 @discussion This method simply calls the NSData instance method writeToURL:options:error:
    while capturing the network performance metrics of that call.
 */
- (BOOL) timedWriteToURL:(NSURL *) url
                 options:(NSDataWritingOptions) writeOptionsMask
                   error:(NSError **) errorPtr;

@end
