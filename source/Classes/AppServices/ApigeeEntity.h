//
//  ApigeeEntity.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApigeeDataClient;
@class ApigeeClientResponse;

/*!
 @class ApigeeEntity
 @abstract Class representing data associated with a generic entity
 */
@interface ApigeeEntity : NSObject


@property (weak) ApigeeDataClient* dataClient;
@property (strong, nonatomic) NSMutableDictionary* properties;
@property (strong, nonatomic) NSString* type;
@property (strong, nonatomic) NSString* uuid;

/*!
 @abstract
 @param dataClient
 */
- (id)initWithDataClient:(ApigeeDataClient*)dataClient;

/*!
 @abstract persists entity to server database
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
- (ApigeeClientResponse*)save;

/*!
 @abstract retrieves/refreshes entity from server database
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
- (ApigeeClientResponse*)fetch;

/*!
 @abstract
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
- (ApigeeClientResponse*)destroy;

/*!
 @abstract Retrieves list of property names that have been set for this entity
 @return array of property names for this entity
 */
- (NSArray*)propertyNames;

/*!
 @abstract
 @param name the property name whose value is being retrieved
 @return
 */
- (NSObject*)get:(NSString*)name;

/*!
 @abstract
 @param name the property name whose value is being retrieved
 @return
 */
- (NSString*)getStringProperty:(NSString*)name;

/*!
 @abstract
 @param name the property name whose value is being retrieved
 @return
 */
- (BOOL)getBoolProperty:(NSString*)name;

/*!
 @abstract
 @param name the property name whose value is being retrieved
 @return
 */
- (float)getFloatProperty:(NSString*)name;

/*!
 @abstract
 @param name the property name whose value is being retrieved
 @return
 */
- (int)getIntProperty:(NSString*)name;

/*!
 @abstract
 @param name the property name whose value is being retrieved
 @return
 */
- (long)getLongProperty:(NSString*)name;

/*!
 @abstract
 @param name the property name whose value is being retrieved
 @return
 */
- (NSObject*)getObjectProperty:(NSString*)name;

/*!
 @abstract
 @param dictProperties
 */
- (void)addProperties:(NSDictionary*)dictProperties;

/*!
 @abstract
 @param name the property name whose value is being set
 @param value
 */
- (void)setProperty:(NSString*)name string:(NSString*)value;

/*!
 @abstract
 @param name the property name whose value is being set
 @param value
 */
- (void)setProperty:(NSString*)name bool:(BOOL)value;

/*!
 @abstract
 @param name the property name whose value is being set
 @param value
 */
- (void)setProperty:(NSString*)name float:(float)value;

/*!
 @abstract
 @param name the property name whose value is being set
 @param value
 */
- (void)setProperty:(NSString*)name int:(int)value;

/*!
 @abstract
 @param name the property name whose value is being set
 @param value
 */
- (void)setProperty:(NSString*)name long:(long)value;

/*!
 @abstract
 @param name the property name whose value is being set
 @param value
 */
- (void)setProperty:(NSString*)name object:(NSObject*)value;

/*!
 @abstract
 @param connectType
 @param targetEntity
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeEntity ApigeeEntity
 */
- (ApigeeClientResponse*)connect:(NSString*)connectType
                    targetEntity:(ApigeeEntity*)targetEntity;

/*!
 @abstract
 @param connectType
 @param targetEntity
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeEntity ApigeeEntity
 */
- (ApigeeClientResponse*)disconnect:(NSString*)connectType
                       targetEntity:(ApigeeEntity*)targetEntity;


@end
