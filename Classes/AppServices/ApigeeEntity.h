//
//  ApigeeEntity.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApigeeDataClient;
@class ApigeeClientResponse;

@interface ApigeeEntity : NSObject


@property (unsafe_unretained) ApigeeDataClient* dataClient;
@property (strong, nonatomic) NSMutableDictionary* properties;
@property (strong, nonatomic) NSString* type;
@property (strong, nonatomic) NSString* uuid;


- (id)initWithDataClient:(ApigeeDataClient*)dataClient;

- (ApigeeClientResponse*)save;
- (ApigeeClientResponse*)fetch;
- (ApigeeClientResponse*)destroy;

- (NSArray*)propertyNames;

- (NSObject*)get:(NSString*)name;
- (NSString*)getStringProperty:(NSString*)name;
- (BOOL)getBoolProperty:(NSString*)name;
- (float)getFloatProperty:(NSString*)name;
- (int)getIntProperty:(NSString*)name;
- (long)getLongProperty:(NSString*)name;
- (NSObject*)getObjectProperty:(NSString*)name;

- (void)addProperties:(NSDictionary*)dictProperties;


- (void)setProperty:(NSString*)name string:(NSString*)value;
- (void)setProperty:(NSString*)name bool:(BOOL)value;
- (void)setProperty:(NSString*)name float:(float)value;
- (void)setProperty:(NSString*)name int:(int)value;
- (void)setProperty:(NSString*)name long:(long)value;
- (void)setProperty:(NSString*)name object:(NSObject*)value;

- (ApigeeClientResponse*)connect:(NSString*)connectType targetEntity:(ApigeeEntity*)targetEntity;
- (ApigeeClientResponse*)disconnect:(NSString*)connectType targetEntity:(ApigeeEntity*)targetEntity;


@end
