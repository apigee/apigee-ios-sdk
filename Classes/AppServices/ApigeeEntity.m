//
//  ApigeeEntity.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeEntity.h"
#import "ApigeeClientResponse.h"
#import "ApigeeDataClient.h"
#import "ApigeeUser.h"

static NSString* PROPERTY_UUID = @"uuid";
static NSString* PROPERTY_TYPE = @"type";



@implementation ApigeeEntity

@synthesize dataClient;
@synthesize properties;

- (id)initWithDataClient:(ApigeeDataClient*)dataClient
{
    self = [super init];
    if( self )
    {
        self.properties = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (NSString*)getStringProperty:(NSString*)name
{
    NSObject* value = [self get:name];
    if (value) {
        if ([value isKindOfClass:[NSString class]]) {
            return (NSString*) value;
        }
    }
    
    return nil;
}

- (BOOL)getBoolProperty:(NSString*)name
{
    NSObject* value = [self get:name];
    if (value) {
        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber* number = (NSNumber*) value;
            return [number boolValue];
        }
    }
    
    return FALSE;
}

- (float)getFloatProperty:(NSString*)name
{
    NSObject* value = [self get:name];
    if (value) {
        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber* number = (NSNumber*) value;
            return [number floatValue];
        }
    }
    
    return 0.0;
}

- (int)getIntProperty:(NSString*)name
{
    NSObject* value = [self get:name];
    if (value) {
        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber* number = (NSNumber*) value;
            return [number intValue];
        }
    }
    
    return 0;
}

- (long)getLongProperty:(NSString*)name
{
    NSObject* value = [self get:name];
    if (value) {
        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber* number = (NSNumber*) value;
            return [number longValue];
        }
    }
    
    return 0L;
}

- (NSObject*)getObjectProperty:(NSString*)name
{
    return [self get:name];
}

- (ApigeeClientResponse*)save
{
    ApigeeClientResponse* response = nil;
    NSString* uuid = [self getStringProperty:@"uuid"];
    BOOL entityAlreadyExists = NO;
    
    if ([ApigeeDataClient isUuidValid:uuid]) {
        entityAlreadyExists = YES;
    }
    
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    
    // copy over all properties except some specific ones
    NSArray* keys = [self.properties allKeys];
    
    for (NSString* key in keys) {
        if( ! [key isEqualToString:@"metadata"] &&
            ! [key isEqualToString:@"created"] &&
            ! [key isEqualToString:@"modified"] &&
            //! [key isEqualToString:@"type"] &&
            ! [key isEqualToString:@"activated"] &&
           ! [key isEqualToString:@"uuid"] ) {
            [data setValue:[self.properties valueForKey:key] forKey:key];
        }
    }
    
    if (entityAlreadyExists) {
        // update it
        response = [self.dataClient updateEntity:uuid entity:data];
    } else {
        // create it
        response = [self.dataClient createEntity:data];
    }
    
    if ([response error] != nil) {
        [self.dataClient writeLog:@"Could not save entity."];
    } else {
        if ([response entityCount] > 0) {
            ApigeeEntity* entity = [response firstEntity];
            self.properties = entity.properties;
        }
    }
    
    return response;
}

- (ApigeeClientResponse*)fetch
{
    ApigeeClientResponse* response = [[ApigeeClientResponse alloc] initWithDataClient:self.dataClient];
    NSString* type = [self getStringProperty:@"type"];
    NSString* uuid = [self getStringProperty:@"uuid"]; // may be NULL
    if ([uuid length] > 0) {
        type = [type stringByAppendingString:@"/$uuid"];
    } else {
        if ([type isEqualToString:@"user"] || [type isEqualToString:@"users"]) {
            NSString* username = [self getStringProperty:@"username"];
            if ([username length] > 0) {
                type = [type stringByAppendingString:@"/$username"];
            } else {
                NSString* error = @"no_name_specified";
                [self.dataClient writeLog:error];
                [response setError:error];
                [response setErrorCode:error];
                return response;
            }
        } else {
            NSString* name = [self getStringProperty:@"name"];
            if ([name length] > 0) {
                type = [type stringByAppendingString:@"/$name"];
            } else {
                NSString* error = @"no_name_specified";
                [self.dataClient writeLog:error];
                [response setError:error];
                [response setErrorCode:error];
                return response;
            }
        }
    }
    
    NSMutableDictionary* dictQueryParams = [[NSMutableDictionary alloc] init];
    [dictQueryParams setValue:uuid forKey:@"uuid"];
    
    ApigeeQuery* query = [ApigeeQuery queryFromDictionary:dictQueryParams];
    
    response = [self.dataClient getEntities:type query:query];
    if ([response error] != nil) {
        [self.dataClient writeLog:@"Could not get entity."];
    } else {
        ApigeeUser* user = response.user;
        if (user != nil) {
            [self addProperties:user.properties];
        } else if ([response entityCount] > 0) {
            ApigeeEntity* entity = [response firstEntity];
            self.properties = entity.properties;
        }
    }
    
    return response;
}

- (ApigeeClientResponse*)destroy
{
    ApigeeClientResponse* response = [[ApigeeClientResponse alloc] initWithDataClient:self.dataClient];
    NSString* type = [self type];
    NSString* uuid = [self uuid];

    if ([type length] == 0) {
        NSString* error = @"Error trying to delete object: No type specified.";
        [self.dataClient writeLog:error];
        [response setError:error];
        [response setErrorCode:error];
        return response;
    }

    if ([ApigeeDataClient isUuidValid:uuid]) {
        type = [type stringByAppendingString:@"/$uuid"];
    } else {
        NSString* error = @"Error trying to delete object: No UUID specified.";
        [self.dataClient writeLog:error];
        [response setError:error];
        [response setErrorCode:error];
        return response;
    }
    
    response = [self.dataClient removeEntity:type entityID:uuid];
    if ([response error] != nil) {
        [self.dataClient writeLog:@"Entity could not be deleted."];
    } else {
        [self.properties removeAllObjects];
        self.uuid = nil;
        self.type = nil;
    }
    
    return response;
}

- (NSArray*)propertyNames
{
    return [self.properties allKeys];
}

- (NSObject*)get:(NSString*)name
{
    return [self.properties valueForKey:name];
}

- (void)setProperty:(NSString*)name string:(NSString*)value
{
    [self.properties setValue:value forKey:name];
}

- (void)setProperty:(NSString*)name bool:(BOOL)value
{
    [self.properties setValue:[NSNumber numberWithBool:value] forKey:name];
}

- (void)setProperty:(NSString*)name float:(float)value
{
    [self.properties setValue:[NSNumber numberWithFloat:value] forKey:name];
}

- (void)setProperty:(NSString*)name int:(int)value
{
    [self.properties setValue:[NSNumber numberWithInt:value] forKey:name];
}

- (void)setProperty:(NSString*)name long:(long)value
{
    [self.properties setValue:[NSNumber numberWithLong:value] forKey:name];
}

- (void)setProperty:(NSString*)name object:(NSObject*)value
{
    [self.properties setValue:value forKey:name];
}

- (void)setType:(NSString *)type
{
    [self setProperty:PROPERTY_TYPE string:type];
}

- (void)setUuid:(NSString *)uuid
{
    [self setProperty:PROPERTY_UUID string:uuid];
}

- (NSString*)type
{
    return [self.properties valueForKey:PROPERTY_TYPE];
}

- (NSString *)uuid
{
    return [self.properties valueForKey:PROPERTY_UUID];
}

- (void)addProperties:(NSDictionary*)dictProperties
{
    NSArray* listKeys = [dictProperties allKeys];
    for (NSString* key in listKeys) {
        [self setProperty:key object:[dictProperties valueForKey:key]];
    }
}

- (ApigeeClientResponse*)connect:(NSString*)connectType
                    targetEntity:(ApigeeEntity*)targetEntity
{
    return [self.dataClient connectEntities:[self type]
                                connectorID:[self uuid]
                             connectionType:connectType
                              connecteeType:[targetEntity type]
                                connecteeID:[targetEntity uuid]];
}

- (ApigeeClientResponse*)disconnect:(NSString*)connectType
                       targetEntity:(ApigeeEntity*)targetEntity
{
    return [self.dataClient disconnectEntities:[self type]
                                   connectorID:[self uuid]
                                          type:connectType
                                   connecteeID:[targetEntity uuid]];
}


@end
