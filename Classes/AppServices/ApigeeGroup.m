//
//  ApigeeGroup.m
//  ApigeeiOSSDK
//
//  Created by Paul Dardeau on 5/30/13.
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeGroup.h"

static NSString* ENTITY_TYPE = @"group";

static NSString* PROPERTY_PATH  = @"path";
static NSString* PROPERTY_TITLE = @"title";


@implementation ApigeeGroup

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

- (id)initWithEntity:(ApigeeEntity*)entity
{
    self = [super initWithDataClient:entity.dataClient];
    if( self )
    {
        self.properties = entity.properties;
        self.type = ENTITY_TYPE;
    }
    
    return self;
}

- (void)setPath:(NSString *)path
{
    return [self setProperty:PROPERTY_PATH string:path];
}

- (NSString*)path
{
    return [self getStringProperty:PROPERTY_PATH];
}

- (void)setTitle:(NSString *)title
{
    return [self setProperty:PROPERTY_TITLE string:title];
}

- (NSString*)title
{
    return [self getStringProperty:PROPERTY_TITLE];
}


@end
