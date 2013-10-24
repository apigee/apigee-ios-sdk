//
//  ApigeeCollection.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApigeeDataClient;
@class ApigeeClientResponse;
@class ApigeeEntity;


/*!
 @class ApigeeCollection
 @abstract
 */
@interface ApigeeCollection : NSObject
{
	NSString* _type;
	NSMutableDictionary* _qs;
	NSMutableArray* _list;
	int _iterator;
	NSMutableArray* _previous;
	NSString* _next;
	NSString* _cursor;
}

@property (weak, nonatomic) ApigeeDataClient* dataClient;
@property (strong, nonatomic) NSString* type;
@property (strong, nonatomic) NSMutableDictionary* qs;
@property (strong, nonatomic) NSMutableArray* list;
@property (strong, nonatomic) NSMutableArray* previous;
@property (strong, nonatomic) NSString* next;
@property (strong, nonatomic) NSString* cursor;


/*!
 @abstract
 @param theDataClient
 @param type
 @param qs
 */
- (id)init:(ApigeeDataClient*)theDataClient type:(NSString*)type qs:(NSDictionary*)qs;

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
