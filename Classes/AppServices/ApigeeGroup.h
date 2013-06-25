//
//  ApigeeGroup.h
//  ApigeeiOSSDK
//
//  Created by Paul Dardeau on 5/30/13.
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApigeeEntity.h"

@class ApigeeDataClient;


@interface ApigeeGroup : ApigeeEntity

@property (strong, nonatomic) NSString* path;
@property (strong, nonatomic) NSString* title;

+ (BOOL)isSameType:(NSString*)type;

- (id)initWithDataClient:(ApigeeDataClient *)dataClient;
- (id)initWithEntity:(ApigeeEntity*)entity;

@end
