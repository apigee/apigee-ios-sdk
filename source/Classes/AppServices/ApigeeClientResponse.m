#import "ApigeeClientResponse.h"
#import "ApigeeDataClient.h"
#import "ApigeeEntity.h"
#import "ApigeeActivity.h"
#import "ApigeeDevice.h"
#import "ApigeeGroup.h"
#import "ApigeeMessage.h"
#import "ApigeeUser.h"
#import "ApigeeJsonUtils.h"

@implementation ApigeeClientResponse

@synthesize transactionID;
@synthesize transactionState;
@synthesize response;
@synthesize rawResponse;
@synthesize dataClient;
@synthesize action;
@synthesize organization;
@synthesize application;
@synthesize path;
@synthesize uri;
@synthesize error;
@synthesize errorDescription;
@synthesize errorCode;
@synthesize cursor;
@synthesize next;
@synthesize timestamp;
@synthesize entities;
@synthesize params;
@synthesize user;

- (id)initWithDataClient:(ApigeeDataClient*)theDataClient
{
    self = [super init];
    if ( self )
    {
        transactionID = -1;
        transactionState = -1;
        response = nil;
        rawResponse = nil;
        self.dataClient = theDataClient;
    }
    return self;
}

- (void)parse:(NSString*)serverResponse
{
    // uncommenting the following is sometimes helpful for debugging
    //NSLog( @"======== start server response ==========");
    //NSLog( @"%@", serverResponse);
    //NSLog( @"======== end server response ==========");

    //NSDictionary* replyDict = [serverResponse JSONValue];
    NSDictionary* replyDict = [ApigeeJsonUtils decode:serverResponse];
    
    self.action = [replyDict valueForKey:@"action"];
    self.organization = [replyDict valueForKey:@"organization"];
    self.application = [replyDict valueForKey:@"applicationName"];
    self.path = [replyDict valueForKey:@"path"];
    self.uri = [replyDict valueForKey:@"uri"];
    self.error = [replyDict valueForKey:@"error"];
    self.errorDescription = [replyDict valueForKey:@"error_description"];
    self.params = [replyDict valueForKey:@"params"];
    self.cursor = [replyDict valueForKey:@"cursor"];
    self.next = [replyDict valueForKey:@"next"];
    
    NSNumber* timestampObject = [replyDict valueForKey:@"timestamp"];
    if (timestampObject != nil) {
        self.timestamp = [timestampObject longLongValue];
    }
    
    NSArray* listEntities = [replyDict valueForKey:@"entities"];
    if (listEntities != nil) {
        NSMutableArray* theListEntities = [[NSMutableArray alloc] init];
        Class clsDictionary = [NSDictionary class];
        
        for (id entityObject in listEntities) {
            if ([entityObject isKindOfClass:clsDictionary]) {
                NSDictionary* dict = (NSDictionary*) entityObject;
                NSString* type = [dict valueForKey:@"type"];
                ApigeeEntity* entity = [self.dataClient createTypedEntity:type];
                entity.properties = [[NSMutableDictionary alloc] initWithDictionary:dict];
                [theListEntities addObject:entity];
            } else {
                NSLog( @"entity object is not a dictionary: %@", entityObject);
            }
        }
        self.entities = theListEntities;
    } else {
        self.entities = nil;
    }
}

- (NSUInteger)entityCount
{
    return [self.entities count];
}

- (ApigeeEntity*)firstEntity
{
    if ((self.entities != nil) && ([self.entities count] > 0)) {
        return [self.entities objectAtIndex:0];
    }
    
    return nil;
}

- (ApigeeEntity*)lastEntity
{
    if (self.entities != nil) {
        NSUInteger numEntities = [self.entities count];
        if (numEntities > 0) {
            return [self.entities objectAtIndex:numEntities-1];
        }
    }
    
    return nil;
}

- (BOOL)completedSuccessfully
{
    return( self.transactionState == kApigeeClientResponseSuccess );
}

@end
