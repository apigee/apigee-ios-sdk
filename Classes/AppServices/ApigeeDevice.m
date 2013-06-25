//
//  ApigeeDevice.m
//  ApigeeiOSSDK
//
//  Created by Paul Dardeau on 5/30/13.
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeDevice.h"

static NSString* ENTITY_TYPE = @"device";

static NSString* PROPERTY_NAME = @"name";


@implementation ApigeeDevice

+ (BOOL)isSameType:(NSString*)type
{
    return [type isEqualToString:ENTITY_TYPE];
}

- (id)initWithDataClient:(ApigeeDataClient *)dataClient
{
    self = [super initWithDataClient:dataClient];
    if( self )
    {
        self.type = ENTITY_TYPE;
    }
    
    return self;
}

- (id)initWithEntity:(ApigeeEntity *)entity
{
    self = [super initWithDataClient:entity.dataClient];
    if( self )
    {
        self.properties = entity.properties;
        self.type = ENTITY_TYPE;
    }
    
    return self;
}

- (void)setName:(NSString *)name
{
    [self setProperty:PROPERTY_NAME string:name];
}

- (NSString*)name
{
    return [self getStringProperty:PROPERTY_NAME];
}

@end
