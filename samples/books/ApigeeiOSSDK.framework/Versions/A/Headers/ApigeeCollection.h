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

@property (unsafe_unretained) ApigeeDataClient* dataClient; // weak
@property (strong, nonatomic) NSString* type;
@property (strong, nonatomic) NSMutableDictionary* qs;
@property (strong, nonatomic) NSMutableArray* list;
@property (strong, nonatomic) NSMutableArray* previous;
@property (strong, nonatomic) NSString* next;
@property (strong, nonatomic) NSString* cursor;


- (id)init:(ApigeeDataClient*)theDataClient type:(NSString*)type qs:(NSDictionary*)qs;

- (ApigeeClientResponse*)fetch;

- (ApigeeEntity*)addEntity:(NSDictionary*)entityData;
- (ApigeeClientResponse*)destroyEntity:(ApigeeEntity*)entity;

- (ApigeeClientResponse*)getEntityByUuid:(NSString*)uuid;

- (ApigeeEntity*)getFirstEntity;
- (ApigeeEntity*)getLastEntity;

- (BOOL)hasNextEntity;
- (BOOL)hasPrevEntity;

- (ApigeeEntity*)getNextEntity;
- (ApigeeEntity*)getPrevEntity;

- (void)resetEntityPointer;

- (void)saveCursor:(NSString*)cursor;

- (void)resetPaging;

- (BOOL)hasNextPage;
- (BOOL)hasPrevPage;

- (ApigeeClientResponse*)getNextPage;
- (ApigeeClientResponse*)getPrevPage;

@end
