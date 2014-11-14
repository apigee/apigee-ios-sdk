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
#import <CoreLocation/CoreLocation.h>

/*!
 @abstract The relational operator to use for a query clause comparison
 @constant kApigeeQueryOperationEquals =
 @constant kApigeeQueryOperationLessThan <
 @constant kApigeeQueryOperationLessThanOrEqualTo <=
 @constant kApigeeQueryOperationGreaterThan >
 @constant kApigeeQueryOperationGreaterThanOrEqualTo >=
 */
enum RelationalOperator
{
    kApigeeQueryOperationEquals = 0,
    kApigeeQueryOperationLessThan = 1,
    kApigeeQueryOperationLessThanOrEqualTo = 2,
    kApigeeQueryOperationGreaterThan = 3,
    kApigeeQueryOperationGreaterThanOrEqualTo = 4
};

/***************************************************************
 QUERY MANAGEMENT:
 
 All query functions take one of these as an optional parameter
 (the client may send nil if desired). This will specify the
 limitations of the query. 
***************************************************************/

/*!
 @class ApigeeQuery
 @abstract ApigeeQuery provides a means of restricting the output of a query
 */
@interface ApigeeQuery : NSObject <NSCopying>

/*!
 @abstract Creates an ApigeeQuery instance from a dictionary of search properties
 @param dictParams Dictionary of search/query properties
 @return ApigeeQuery instance
 @see ApigeeQuery ApigeeQuery
 */
+ (ApigeeQuery*)queryFromDictionary:(NSDictionary*)dictParams;

// url terms used in Apigee searches. Set as you like.
// These are convenience methods. the same effect can be done
// by calling addURLTerm

/*!
 @abstract
 @param consumer
 */
-(void)setConsumer: (NSString *)consumer;

/*!
 @abstract
 @param lastUUID
 */
-(void)setLastUUID: (NSString *)lastUUID;

/*!
 @abstract
 @param time
 */
-(void)setTime: (long)time;

/*!
 @abstract
 @param prev
 */
-(void)setPrev: (int)prev;

/*!
 @abstract
 @param next
 */
-(void)setNext: (int)next;

/*!
 @abstract Sets the maximum number of entities to retrieve
 @param limit integer number of entities to retrieve
 */
-(void)setLimit: (int)limit;

/*!
 @abstract
 @param pos
 */
-(void)setPos: (NSString *)pos;

/*!
 @abstract
 @param update
 */
-(void)setUpdate: (BOOL)update;

/*!
 @abstract
 @param synchronized
 */
-(void)setSynchronized: (BOOL)synchronized;

/*!
 @abstract general function for adding additional URL terms
 @param urlTerm
 @param equals
 @discussion Note that all of the set functions call this method.
 */
-(void)addURLTerm: (NSString *)urlTerm equals:(NSString *)equals;

// ql operation requirements. For each of these, you provide the term, followed 
// by the operation (a kApigeeQueryOperationXXXX constant) followed by the value
// in whatever form you have it (NSString, int, or float are supported)
// Example: [foo addRequiredOperation: @"age" op:kApigeeQueryLessThan valueInt:27] would
// add the term "age < 27" to the ql.
/*!
 @abstract
 @param term
 @param op
 @param valueStr
 @description
 */
-(void)addRequiredOperation: (NSString *)term op:(int)op valueStr:(NSString *)valueStr;

/*!
 @abstract
 @param term
 @param op
 @param valueInt
 */
-(void)addRequiredOperation: (NSString *)term op:(int)op valueInt:(int) valueInt;

/*!
 @abstract adds a "contains" requirement to the query
 @param term
 @param value
 @discussion This adds the requirement that a value contain a given string.
    Example:
    <pre>
    @textblock
        [foo addRequiredContains:@"hobbies" value:@"fishing"];
    @/textblock
    </pre>
    would add the term "hobbies contains 'fishing'" to the ql.
 */
-(void)addRequiredContains: (NSString *)term value:(NSString *)value;

/*!
 @abstract adds an "in" requirement to the query
 @param term
 @param low
 @param high
 @discussion This adds a requirement that a field be within a certain range.
    Example:
    <pre>
    @textblock
        [foo appendRequiredIn:@"age" low:16.0 high:22.0];
    @/textblock
    </pre>
    would add the term "age in 16.0,22.0" to the ql.
    Note that the qualifier is inclusive, meaning it is true if low <= term <= high.
 */
-(void)addRequiredIn:(NSString *)term low:(int)low high:(int)high;

/*!
 @abstract adds a "within" requirement
 @param term
 @param latitude
 @param longitude
 @param distance in meters
 @discussion This adds a constraint that the term be within a certain distance
    of the sent-in x,y coordinates.
 */
-(void)addRequiredWithin:(NSString *)term
                latitude:(float)latitude
               longitude:(float)longitude
                distance:(float)distance;

/*!
 @abstract assembles a "within" requirement with a term name, CLLocation, and distance
 @param term
 @param location value specified as a CLLocation
 @param distance in meters
 @discussion This method is a convenience method and simply calls
    addRequiredWithin:latitude:longitude:distance:
 @see addRequiredWithin:latitude:longitude:distance:
 */
-(void)addRequiredWithinLocation:(NSString *)term
                        location:(CLLocation *)location
                        distance:(float)distance;

//-------------------- Oblique usage ----------------------------
/*!
 @abstract Adds a requirement to the query
 @param requirement The new requirement to add
 @discussion The requirements will *all* be sent when the query is adopted.
    This is an escalating list as you add them. Requirements are in Apigee
    Query language. So something like "firstname='bob'". This is one of the
    few places where the data you give will be sent to the server almost
    untouched. So if you make a mistake in your query, you are likely to cause
    the whole transaction to return an error. NOTE: This is different than URL
    terms. These are query terms sent along to the *single* URL term "ql".
    Note: This is an oblique-usage function. You will find all the ql operations
    supported in the various addRequiredXXXX functions above. You would only use
    this function if you already have ql strings prepared for some reason, or if
    there are new ql format operations that are not supported by this API.
 */
-(void)addRequirement: (NSString *)requirement;

/*!
 @internal
 @abstract returns the URL-ready string that detailes all specified requirements
 @discussion This is used internally by ApigeeClient, you don't need to call it.
 */
-(NSString *)getURLAppend;

@end
