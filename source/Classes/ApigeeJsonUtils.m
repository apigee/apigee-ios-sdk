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

#import "ApigeeJsonUtils.h"


@implementation ApigeeJsonUtils

+ (NSString*)encode:(id)object
{
    NSError* error = nil;
    NSString* json = [ApigeeJsonUtils encode:object error:&error];
    
    if (json == nil) {
        if( error != nil ) {
            NSLog(@"unable to encode to JSON: %@", [error localizedDescription]);
        } else {
            NSLog(@"unable to encode to JSON: %@", object);
        }
    }
    
    return nil;
}

+ (NSString*)encode:(id)object error:(NSError**)error
{
    NSData* dataObject = [ApigeeJsonUtils encodeAsData:object error:error];
    if (dataObject != nil) {
        return [[NSString alloc] initWithData:dataObject
                                     encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}

+ (NSData*)encodeAsData:(id)object
{
    NSError* error = nil;
    NSData* data = [ApigeeJsonUtils encodeAsData:object error:&error];
    if (data == nil) {
        if (error != nil) {
            NSLog(@"unable to encode to JSON data: %@", [error localizedDescription]);
        } else {
            NSLog(@"unable to encode to JSON data: %@", object);
        }
    }
    
    return data;
}

+ (NSData*)encodeAsData:(id)object error:(NSError**)error
{
    NSJSONWritingOptions writingOptions = 0;
    
#if (TARGET_IPHONE_SIMULATOR)
    writingOptions = NSJSONWritingPrettyPrinted;
#endif
    
    NSData* jsonAsData = [NSJSONSerialization dataWithJSONObject:object
                                           options:writingOptions
                                             error:error];
    if( jsonAsData == nil ) {
        NSLog( @"error: unable to encode as json. %@", object);
        if( *error ) {
            NSLog( @"error: %@", [*error localizedDescription]);
        } else {
            NSLog( @"no error given by NSJSONSerialization");
        }
    }
    
    return jsonAsData;
}

+ (id)decode:(NSString*)json
{
    NSError* error = nil;
    id objects = [ApigeeJsonUtils decode:json error:&error];
    if( objects == nil || error != nil ) {
        if( error != nil ) {
            NSLog( @"JSON parse error: %@", [error localizedDescription]);
        } else {
            NSLog( @"JSON parse failed. no error given. %@", json );
        }
        
        return nil;
    } else {
        return objects;
    }
}

+ (id)decode:(NSString*)json error:(NSError**)error
{
    NSData* jsonAsData = [json dataUsingEncoding:NSUTF8StringEncoding];
    return [ApigeeJsonUtils decodeData:jsonAsData error:error];
}

+ (id)decodeData:(NSData*)jsonData
{
    NSError* error = nil;
    id objects = [ApigeeJsonUtils decodeData:jsonData error:&error];
    if( objects == nil || error != nil ) {
        if( error != nil ) {
            NSLog( @"JSON parse error: %@", [error localizedDescription]);
        } else {
            NSLog( @"JSON parse failed. no error given. %@", jsonData );
        }
    }
    
    return objects;
}

+ (id)decodeData:(NSData*)jsonData error:(NSError**)error
{
    return [NSJSONSerialization JSONObjectWithData:jsonData
                                           options:NSJSONReadingMutableContainers
                                             error:error];
}

@end
