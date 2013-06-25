//
//  ApigeeDevice.h
//  ApigeeiOSSDK
//
//  Created by Paul Dardeau on 5/30/13.
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
