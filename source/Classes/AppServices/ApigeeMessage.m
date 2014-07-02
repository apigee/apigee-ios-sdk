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

#import "ApigeeMessage.h"

static NSString* ENTITY_TYPE = @"message";

static NSString* PROPERTY_CORRELATION_ID = @"correlation_id";
static NSString* PROPERTY_DESTINATION    = @"destination";
static NSString* PROPERTY_REPLY_TO       = @"reply_to";
//static NSString* PROPERTY_TIMESTAMP      = @"timestamp";
static NSString* PROPERTY_CATEGORY       = @"category";
static NSString* PROPERTY_INDEXED        = @"indexed";
static NSString* PROPERTY_PERSISTENT     = @"persistent";


@implementation ApigeeMessage

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

- (void)setCategory:(NSString *)category {
    [self setProperty:PROPERTY_CATEGORY string:category];
}

- (NSString*)category
{
    return [self getStringProperty:PROPERTY_CATEGORY];
}

- (void)setCorrelationId:(NSString *)correlationId {
    [self setProperty:PROPERTY_CORRELATION_ID string:correlationId];
}

- (NSString*)correlationId
{
    return [self getStringProperty:PROPERTY_CORRELATION_ID];
}

- (void)setDestination:(NSString *)destination {
    [self setProperty:PROPERTY_DESTINATION string:destination];
}

- (NSString*)destination
{
    return [self getStringProperty:PROPERTY_DESTINATION];
}

- (void)setReplyTo:(NSString *)replyTo
{
    [self setProperty:PROPERTY_REPLY_TO string:replyTo];
}

- (NSString*)replyTo
{
    return [self getStringProperty:PROPERTY_REPLY_TO];
}

- (void)setPersistent:(BOOL)persistent
{
    [self setProperty:PROPERTY_PERSISTENT bool:persistent];
}

- (BOOL)persistent
{
    return [self getBoolProperty:PROPERTY_PERSISTENT];
}

- (void)setIndexed:(BOOL)indexed
{
    [self setProperty:PROPERTY_INDEXED bool:indexed];
}

- (BOOL)indexed
{
    return [self getBoolProperty:PROPERTY_INDEXED];
}

@end
