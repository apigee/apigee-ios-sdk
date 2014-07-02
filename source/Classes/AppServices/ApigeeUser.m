/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ApigeeUser.h"
#import "ApigeeClientResponse.h"
#import "ApigeeDataClient.h"

static NSString* ENTITY_TYPE  = @"user";

static NSString* PROPERTY_USERNAME   = @"username";
static NSString* PROPERTY_EMAIL      = @"email";
static NSString* PROPERTY_NAME       = @"name";
static NSString* PROPERTY_FIRSTNAME  = @"firstname";
static NSString* PROPERTY_MIDDLENAME = @"middlename";
static NSString* PROPERTY_LASTNAME   = @"lastname";
static NSString* PROPERTY_ACTIVATED  = @"activated";
static NSString* PROPERTY_PICTURE    = @"picture";
static NSString* PROPERTY_DISABLED   = @"disabled";

static NSString* OLD_PASSWORD = @"oldpassword";
static NSString* NEW_PASSWORD = @"newpassword";


@implementation ApigeeUser

+ (BOOL)isSameType:(NSString*)type
{
    return [type isEqualToString:ENTITY_TYPE];
}

- (id)initWithDataClient:(ApigeeDataClient*)dataClient
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

- (void)setUsername:(NSString *)username
{
    [self setProperty:PROPERTY_USERNAME string:username];
}

- (NSString*)username
{
    return [self getStringProperty:PROPERTY_USERNAME];
}

- (void)setFirstname:(NSString *)firstname
{
    [self setProperty:PROPERTY_FIRSTNAME string:firstname];
}

- (NSString*)firstname
{
    return [self getStringProperty:PROPERTY_FIRSTNAME];
}

- (void)setMiddlename:(NSString *)middlename
{
    [self setProperty:PROPERTY_MIDDLENAME string:middlename];
}

- (NSString*)middlename
{
    return [self getStringProperty:PROPERTY_MIDDLENAME];
}

- (void)setLastname:(NSString *)lastname
{
    [self setProperty:PROPERTY_LASTNAME string:lastname];
}

- (NSString*)lastname
{
    return [self getStringProperty:PROPERTY_LASTNAME];
}

- (void)setName:(NSString *)name
{
    [self setProperty:PROPERTY_NAME string:name];
}

- (NSString*)name
{
    return [self getStringProperty:PROPERTY_NAME];
}

- (void)setEmail:(NSString *)email
{
    [self setProperty:PROPERTY_EMAIL string:email];
}

- (NSString*)email
{
    return [self getStringProperty:PROPERTY_EMAIL];
}

- (void)setPicture:(NSString *)picture
{
    [self setProperty:PROPERTY_PICTURE string:picture];
}

- (NSString*)picture
{
    return [self getStringProperty:PROPERTY_PICTURE];
}

- (void)setActivated:(BOOL)activated
{
    [self setProperty:PROPERTY_ACTIVATED bool:activated];
}

- (BOOL)activated
{
    return [self getBoolProperty:PROPERTY_ACTIVATED];
}

- (void)setDisabled:(BOOL)disabled
{
    [self setProperty:PROPERTY_DISABLED bool:disabled];
}

- (BOOL)disabled
{
    return [self getBoolProperty:PROPERTY_DISABLED];
}

- (ApigeeClientResponse*)save
{
    ApigeeClientResponse* response = [super save];
    
    if ( [response error] == nil ) {
        // need to perform a change of password?
        NSString* oldPassword = [self getStringProperty:OLD_PASSWORD];
        NSString* newPassword = [self getStringProperty:NEW_PASSWORD];

        if (([oldPassword length] > 0) && ([newPassword length] > 0)) {
            
            NSString* usernameOrEmail = self.username;
            
            response = [self.dataClient updateUserPassword:usernameOrEmail
                                               oldPassword:oldPassword
                                               newPassword:newPassword];
            
            if ( [response error] != nil ) {
                [self.dataClient writeLog:@"Could not update user's password."];
            }
            
            [self.properties removeObjectForKey:OLD_PASSWORD];
            [self.properties removeObjectForKey:NEW_PASSWORD];
        }
    }
    
    return response;
}

@end
