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
