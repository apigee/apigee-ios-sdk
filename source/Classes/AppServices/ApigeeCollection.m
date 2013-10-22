//
//  ApigeeCollection.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeCollection.h"
#import "ApigeeClientResponse.h"
#import "ApigeeDataClient.h"
#import "ApigeeEntity.h"
#import "ApigeeQuery.h"

@implementation ApigeeCollection

@synthesize dataClient;
@synthesize type=_type;
@synthesize qs=_qs;
@synthesize list=_list;
@synthesize previous=_previous;
@synthesize next=_next;
@synthesize cursor=_cursor;

- (id)init:(ApigeeDataClient*)theDataClient type:(NSString*)type qs:(NSDictionary*)qs
{
    self = [super init];
    if( self )
    {
	    self.dataClient = theDataClient;
	    self.type = type;
	    
	    if( qs == nil )
	    {
	    	self.qs = [[NSMutableDictionary alloc] init];
	    }
	    else
	    {
	    	self.qs = [[NSMutableDictionary alloc] initWithDictionary:qs];
	    }
        
	    self.list = [[NSMutableArray alloc] init];
	    _iterator = -1;
        
	    self.previous = [[NSMutableArray alloc] init];
	    self.next = nil;
	    self.cursor = nil;
        
	    [self fetch];
    }
    
    return self;
}
    
- (ApigeeClientResponse*)fetch
{
    if (self.cursor != nil) {
        [self.qs setValue:self.cursor forKey:@"cursor"];
    }
    else if ( [self.qs valueForKey:@"cursor"]  != nil ) {
        [self.qs removeObjectForKey:@"cursor"];
    }
    
    ApigeeQuery* query = nil;
    
    if( [self.qs count] > 0 ) {
        query = [ApigeeQuery queryFromDictionary:self.qs];
    }
    
    ApigeeClientResponse* response = [self.dataClient getEntities:self.type
                                                            query:query];
    
    if ([response error] != nil) {
        [self.dataClient writeLog:@"Error getting collection."];
    } else {
        NSString* theCursor = [response cursor];
        NSUInteger count = [response entityCount];
        self.next = [response next];
        self.cursor = theCursor;
        
        [self saveCursor:theCursor];
        if ( count > 0 ) {
            [self resetEntityPointer];
            [self.list removeAllObjects];
            NSArray* retrievedEntities = [response entities];
            
            for( ApigeeEntity* retrievedEntity in retrievedEntities ) {
                if( retrievedEntity.uuid != nil ) {
                    retrievedEntity.type = self.type;
                    [self.list addObject:retrievedEntity];
                }
            }
        }
    }
    
    return response;
}
    
- (ApigeeEntity*)addEntity:(NSDictionary*)entityData
{
    ApigeeEntity* entity = nil;
    ApigeeClientResponse* response = [self.dataClient createEntity:entityData];
    
    if( (response != nil) && (response.transactionState == kApigeeClientResponseSuccess) ) {
        entity = [response firstEntity];
        if ((entity != nil) && ([[entity uuid] length] > 0)) {
            [self.list addObject:entity];
        }
    }
    
    return entity;
}
    
- (ApigeeClientResponse*)destroyEntity:(ApigeeEntity*)entity
{
    ApigeeClientResponse* response = [entity destroy];
    if ([response error] != nil) {
        [self.dataClient writeLog:@"Could not destroy entity."];
    } else {
        response = [self fetch];
    }
	    
    return response;
}
    
- (ApigeeClientResponse*)getEntityByUuid:(NSString*)uuid
{
    ApigeeEntity* entity = [self.dataClient createTypedEntity:self.type];
    entity.type = self.type;
    entity.uuid = uuid;
    return [entity fetch];
}
    
- (ApigeeEntity*)getFirstEntity
{
    return ([self.list count] > 0 ? [self.list objectAtIndex:0] : nil);
}
    
- (ApigeeEntity*)getLastEntity
{
    return ([self.list count] > 0 ? [self.list objectAtIndex:[self.list count]-1] : nil);
}

- (BOOL)hasNextEntity
{
    const int next = _iterator + 1;
    return ((next >= 0) && (next < [self.list count]));
}
    
- (BOOL)hasPrevEntity
{
    const int prev = _iterator - 1;
    return ((prev >= 0) && (prev < [self.list count]));
}
    
- (ApigeeEntity*)getNextEntity
{
    if ([self hasNextEntity]) {
        _iterator++;
		return [self.list objectAtIndex:_iterator];
    }
    return nil;
}
    
- (ApigeeEntity*)getPrevEntity
{
    if ([self hasPrevEntity]) {
        _iterator--;
        return [self.list objectAtIndex:_iterator];
    }
    return nil;
}
    
- (void)resetEntityPointer
{
    _iterator = -1;
}
    
- (void)saveCursor:(NSString*)cursor
{
    self.next = cursor;
}
    
- (void)resetPaging
{
    [self.previous removeAllObjects];
    self.next = nil;
    self.cursor = nil;
}
    
- (BOOL)hasNextPage
{
    return (self.next != nil);
}
    
- (BOOL)hasPrevPage
{
    return ([self.previous count] > 0);
}
    
- (ApigeeClientResponse*)getNextPage
{
    if ( [self hasNextPage] ) {
        [self.previous addObject:self.cursor];
		self.cursor = self.next;
        [self.list removeAllObjects];
        return [self fetch];
    }
    
    return nil;
}
    
- (ApigeeClientResponse*)getPrevPage
{
    if ( [self hasPrevPage] ) {
		self.next = nil;
        self.cursor = [self.previous lastObject];
        [self.previous removeLastObject];
        [self.list removeAllObjects];
        return [self fetch];
    }
        
    return nil;
}
    

@end
