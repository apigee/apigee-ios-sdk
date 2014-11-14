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

#import "ApigeeQuery.h"
#import "ApigeeHTTPManager.h"

static NSString* kEntityTypeKey = @"type";

@interface ApigeeQuery ()
@property (strong,nonatomic) NSMutableArray* m_requirements;
@property (strong,nonatomic) NSMutableString* m_urlTerms;
@end

@implementation ApigeeQuery 

+ (ApigeeQuery*)queryFromDictionary:(NSDictionary*)dictParams
{
    NSArray* allKeys = [dictParams allKeys];
    ApigeeQuery* query = nil;

    if( [allKeys count] > 0 ) {
        query = [[ApigeeQuery alloc] init];
        
        Class clsNSNumber = [NSNumber class];
        Class clsNSString = [NSString class];
    
        for( NSString* key in allKeys ) {
            if( ! [key isEqualToString:kEntityTypeKey] ) {
                id value = [dictParams valueForKey:key];
                if ([value isKindOfClass:clsNSNumber]) {
                    NSNumber* valueAsNumber = (NSNumber*) value;
                    [query addRequiredOperation:key
                                             op:kApigeeQueryOperationEquals
                                       valueInt:[valueAsNumber intValue]];
                } else if ([value isKindOfClass:clsNSString]) {
                    NSString* valueAsString = (NSString*) value;
                    [query addRequiredOperation:key
                                             op:kApigeeQueryOperationEquals
                                       valueStr:valueAsString];
                } else {
                    //TODO: add log message indicating that the key is not
                    //      being used to construct the query
                }
            }
        }
    }

    return query;
}

-(id)init
{
    self = [super init];
    if ( self )
    {
        _m_requirements = [NSMutableArray new];
        _m_urlTerms = [NSMutableString new];
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    ApigeeQuery* copiedQuery = [[self class] allocWithZone:zone];
    copiedQuery.m_requirements = [[NSMutableArray alloc] initWithArray:self.m_requirements copyItems:YES];
    copiedQuery.m_urlTerms = [self.m_urlTerms mutableCopy];
    return copiedQuery;
}

-(void)setConsumer: (NSString *)consumer
{
    [self addURLTerm:@"consumer" equals:consumer];
}

-(void)setLastUUID: (NSString *)lastUUID
{
    [self addURLTerm:@"last" equals:lastUUID];    
}

-(void)setTime: (long)time
{
    NSMutableString *str = [NSMutableString new];
    [str appendFormat:@"%ld", time];
    [self addURLTerm:@"time" equals:str];
}

-(void)setPrev: (int)prev
{
    NSMutableString *str = [NSMutableString new];
    [str appendFormat:@"%d", prev];
    [self addURLTerm:@"prev" equals:str];
}

-(void)setNext: (int)next
{
    NSMutableString *str = [NSMutableString new];
    [str appendFormat:@"%d", next];
    [self addURLTerm:@"next" equals:str];
}

-(void)setLimit: (int)limit
{
    NSMutableString *str = [NSMutableString new];
    [str appendFormat:@"%d", limit];
    [self addURLTerm:@"limit" equals:str];
}

-(void)setPos: (NSString *)pos
{
    [self addURLTerm:@"pos" equals:pos];    
}

-(void)setUpdate: (BOOL)update
{
    if ( update )
    {
        [self addURLTerm:@"update" equals:@"true"];
    }
    else
    {
        [self addURLTerm:@"update" equals:@"false"];
    }
}

-(void)setSynchronized: (BOOL)synchronized
{
    if ( synchronized )
    {
        [self addURLTerm:@"synchronized" equals:@"true"];
    }
    else
    {
        [self addURLTerm:@"synchronized" equals:@"false"];
    }
}

-(void)addURLTerm: (NSString *)urlTerm equals:(NSString *)equals
{
    // ignore anything with a nil
    if ( !urlTerm ) return;
    if ( !equals ) return;

    // escape the strings
    NSString *escapedUrlTerm = [ApigeeHTTPManager escapeSpecials:urlTerm];
    NSString *escapedEquals = [ApigeeHTTPManager escapeSpecials:equals];

    // add it in
    if ( [self.m_urlTerms length] > 0 ) {
        // we already have some terms. Append an & before continuing
        [self.m_urlTerms appendFormat:@"&"];
        [self.m_urlTerms appendFormat:@"%@=%@", escapedUrlTerm, escapedEquals];
    } else if ( [urlTerm isEqualToString:@"ql"] ) {
        // this is a ql, so add it to m_requirements instead
        [self addRequirement: equals];
    } else  {
        // start the urlTerms string
        [self.m_urlTerms appendFormat:@"%@=%@", escapedUrlTerm, escapedEquals];
    }
}

-(void)addRequiredOperation: (NSString *)term op:(int)op valueStr:(NSString *)valueStr
{
    // disregard invalid values
    if ( !term ) return;
    if ( !valueStr ) return;
    
    NSString *opStr = [self getOpStr: op];
    if ( !opStr ) return; // nil opStr means they sent in an invalid op code
    
    // If the term belongs in the 'ql' param add it as a req. If it is 'limit'
    // or 'cursor' add it as a urlTerm
    if ([term isEqualToString:@"cursor"] || [term isEqualToString:@"limit"]) {
        [self addURLTerm:term equals:valueStr];
    } else if ([term isEqualToString:@"ql"]) {
        // If valueStr is a ql string, add it the m_requirements string
        [self addRequirement:valueStr];
    } else {
        // Add anything else to the requirement string
        NSMutableString *assembled = [NSMutableString new];
        [assembled appendFormat:@"%@%@'%@'", term, opStr, valueStr];
        [self addRequirement:assembled];
    }
}

-(void)addRequiredOperation: (NSString *)term op:(int)op valueInt:(int) valueInt
{
    // disregard invalid values
    if ( !term ) return;
    
    NSString *opStr = [self getOpStr: op];
    if ( !opStr ) return; // nil opStr means they sent in an invalid op code
    
    // assemble the requirement string
    NSMutableString *assembled = [NSMutableString new];
    [assembled appendFormat:@"%@ %@ %d", term, opStr, valueInt];
    
    // add it as a req
    [self addRequirement:assembled];
}

-(void)addRequiredContains: (NSString *)term value:(NSString *)value
{
    // disregard invalid values
    if ( !term ) return;
    if ( !value ) return;
    
    // assemble the requirement string
    NSMutableString *assembled = [NSMutableString new];
    [assembled appendFormat:@"%@ contains '%@'", term, value];
    
    // add it as a req
    [self addRequirement:assembled];
}

-(void)addRequiredIn:(NSString *)term low:(int)low high:(int)high
{
    // disregard invalid values
    if ( !term ) return;
    
    // assemble the requirement string
    NSMutableString *assembled = [NSMutableString new];
    [assembled appendFormat:@"%@ in %d,%d", term, low, high];
    
    // add it as a req
    [self addRequirement:assembled];    
}

-(void)addRequiredWithin:(NSString *)term latitude:(float)latitude longitude:(float)longitude distance:(float)distance;
{
    // disregard invalid values
    if ( !term ) return;
    
    // assemble the requirement string
    NSMutableString *assembled = [NSMutableString new];
    [assembled appendFormat:@"%@ within %f of %f,%f", term, distance, latitude, longitude];
    
    // add it as a req
    [self addRequirement:assembled];   
}

-(void)addRequiredWithinLocation:(NSString *)term location:(CLLocation *)location distance:(float)distance
{
    [self addRequiredWithin:term latitude:location.coordinate.latitude longitude:location.coordinate.longitude distance:distance];
}

-(void)addRequirement: (NSString *)requirement
{
    // add the URL-ready requirement to our list
    [self.m_requirements addObject:requirement];
}

-(NSString *)getURLAppend
{    
    // assemble a url append for all the requirements
    // prep a mutable string
    NSMutableString *ret = [NSMutableString new];
  
    // true if we've put anything in the string yet.
    BOOL bHasContent = NO;
    
    // start with the ql term
    if ( [self.m_requirements count] > 0 )
    {    
        // if we're here, there are queries
        // assemble a single string for the ql
        NSMutableString *ql = [NSMutableString new];
        for ( int i=0 ; i<[self.m_requirements count] ; i++ )
        {
            if ( i>0 )
            {
                // connect terms
                [ql appendFormat:@" and "];
            }
            [ql appendFormat:@"%@", [self.m_requirements objectAtIndex:i]];
        }
        
        // escape it
        NSString *escapedQL = [ApigeeHTTPManager escapeSpecials:ql];
        [ret appendFormat:@"ql=%@", escapedQL];
        bHasContent = YES;
    }

    if ( [self.m_urlTerms length] > 0 )
    {
        if ( bHasContent ) 
        {
            [ret appendFormat:@"&%@", self.m_urlTerms];
        }
        else 
        {
            [ret appendFormat:@"%@", self.m_urlTerms];
        }
        bHasContent = YES;
    }
    
    if ( !bHasContent )
    {
        // no content
        return @"";
    }
    
    // all prepared
    return ret;
}

// Internal function
 -(NSString *)getOpStr:(int)op
{
    switch (op)
    {
        case kApigeeQueryOperationEquals: return @"=";
        case kApigeeQueryOperationGreaterThan: return @">";
        case kApigeeQueryOperationGreaterThanOrEqualTo: return @">=";
        case kApigeeQueryOperationLessThan: return @"<";
        case kApigeeQueryOperationLessThanOrEqualTo: return @"<=";
    }
    return nil;
}

@end
