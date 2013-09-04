//
//  ApigeeDevice.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApigeeEntity.h"


@interface ApigeeDevice : ApigeeEntity

@property (strong, nonatomic) NSString* name;

+ (BOOL)isSameType:(NSString*)type;

- (id)initWithDataClient:(ApigeeDataClient *)dataClient;
- (id)initWithEntity:(ApigeeEntity*)entity;

@end
