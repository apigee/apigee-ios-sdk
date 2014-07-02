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

#import "ApigeeDataClient.h"

@class ApigeeClientResponse;
@class ApigeeEntity;
@class ApigeeQuery;


/*!
 @class ApigeeCollection
 @abstract
 */
@interface ApigeeCollection : NSObject

@property (weak, nonatomic) ApigeeDataClient* dataClient;
@property (strong, nonatomic) NSString* type;
@property (strong, nonatomic) NSMutableDictionary* qs;
@property (strong, nonatomic) NSMutableArray* list;
@property (strong, nonatomic) NSMutableArray* previous;
@property (strong, nonatomic) NSString* next;
@property (strong, nonatomic) NSString* cursor;
@property (strong, nonatomic) ApigeeQuery* query;

/*!
 @abstract Initializes and populates a collection of the specified type using the given query parameters
 @param theDataClient instance of ApigeeDataClient
 @param type The collection type
 @param qs The query parameters to restrict which entities are returned
 */
- (id)init:(ApigeeDataClient*)theDataClient type:(NSString*)type qs:(NSDictionary*)qs;

/*!
 @abstract Initializes and populates a collection of the specified type using the given query
 @param theDataClient instance of ApigeeDataClient
 @param type The collection type
 @param query The query to restrict which entities are returned
 */
- (id)init:(ApigeeDataClient*)theDataClient type:(NSString*)type query:(ApigeeQuery*)query;

/*!
 @abstract Initializes and asynchronously populates a collection of the specified type using the given query parameters
 @param theDataClient instance of ApigeeDataClient
 @param type The collection type
 @param qs The query parameters to restrict which entities are returned
 @param completionHandler the handler to run with initialization is complete
 @discussion Although this is an init method, the created instance will not be
 ready for use (i.e., populated with data) until the completion handler is called.
 */
- (id)init:(ApigeeDataClient*)theDataClient
      type:(NSString*)type
        qs:(NSDictionary*)qs
completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Initializes and asynchronously populates a collection of the specified type using the given query
 @param theDataClient instance of ApigeeDataClient
 @param type The collection type
 @param query The query to restrict which entities are returned
 @param completionHandler the handler to run with initialization is complete
 @discussion Although this is an init method, the created instance will not be
 ready for use (i.e., populated with data) until the completion handler is called.
 */
- (id)init:(ApigeeDataClient*)theDataClient
      type:(NSString*)type
     query:(ApigeeQuery*)query
completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract
 @return instance of ApigeeClientResponse
 @see ApigeeClientResponse ApigeeClientResponse
 */
- (ApigeeClientResponse*)fetch;

/*!
 @abstract
 @param entityData
 @return
 @see ApigeeEntity ApigeeEntity
 */
- (ApigeeEntity*)addEntity:(NSDictionary*)entityData;

/*!
 @abstract
 @param entity
 @return instance of ApigeeClientResponse
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeEntity ApigeeEntity
 */
- (ApigeeClientResponse*)destroyEntity:(ApigeeEntity*)entity;

/*!
 @abstract Retrieves an entity for a specific UUID
 @param uuid the UUID for the entity
 @return instance of ApigeeClientResponse
 @see ApigeeClientResponse ApigeeClientResponse
 */
- (ApigeeClientResponse*)getEntityByUuid:(NSString*)uuid;

/*!
 @abstract Retrieves the first entity in the collection
 @return first instance of ApigeeEntity in the collection
 @see ApigeeEntity ApigeeEntity
 */
- (ApigeeEntity*)getFirstEntity;

/*!
 @abstract Retrieves the last entity in the collection
 @return last instance of ApigeeEntity in the collection
 @see ApigeeEntity ApigeeEntity
 */
- (ApigeeEntity*)getLastEntity;

/*!
 @abstract Determines if a next entity is available
 @return boolean indicating whether a next entity is available
 */
- (BOOL)hasNextEntity;

/*!
 @abstract Determines if a previous entity is available
 @return boolean indicating whether a previous entity is available
 */
- (BOOL)hasPrevEntity;

/*!
 @abstract Retrieves the next entity in this collection
 @return instance of ApigeeEntity
 @see ApigeeEntity ApigeeEntity
 */
- (ApigeeEntity*)getNextEntity;

/*!
 @abstract Retrieves the previous entity in this collection
 @return instance of ApigeeEntity
 @see ApigeeEntity ApigeeEntity
 */
- (ApigeeEntity*)getPrevEntity;

/*!
 @abstract
 */
- (void)resetEntityPointer;

/*!
 @abstract
 @param cursor
 */
- (void)saveCursor:(NSString*)cursor;

/*!
 @abstract
 */
- (void)resetPaging;

/*!
 @abstract Determines if a next page is available
 @return boolean indicating whether a nexts page is available
 */
- (BOOL)hasNextPage;

/*!
 @abstract Determines if a previous page is available
 @return boolean indicating whether a previous page is available
 */
- (BOOL)hasPrevPage;

/*!
 @abstract Retrieves the next page of entities for this collection
 @return an ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
- (ApigeeClientResponse*)getNextPage;

/*!
 @abstract Retrieves the previous page of entities for this collection
 @return an ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
- (ApigeeClientResponse*)getPrevPage;

@end
