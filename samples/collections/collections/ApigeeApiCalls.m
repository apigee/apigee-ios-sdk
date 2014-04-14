//
//  ApigeeApiCalls.m
//  entities
//
//  Created by Alex Muramoto on 1/15/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

/* APIGEE iOS SDK COLLECTION EXAMPLE APP
 
 This class handles our API requests. See the code comments
 for detailed info on how each request type works.
 */

#import "ApigeeApiCalls.h"
#import "ApigeeAppDelegate.h"
#import "ApigeeMenuViewController.h"
#import <ApigeeiOSSDK/Apigee.h>

@implementation ApigeeApiCalls

ApigeeDataClient *dataClient;
ApigeeCollection *currentCollection;
NSString *orgName;
NSString *appName;

/* Initializes the SDK in the App Delegate by creating an instance of the ApigeeClient class.
 This also gives us an instance of the ApigeeDataClient class, which we use to send our
 organization and application name with our API requests. */

-(void)initializeSDK:(NSString*)orgInput {
    orgName = orgInput;
    appName = @"sandbox";
    ApigeeAppDelegate *appDelegate = (ApigeeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate initializeSDKInAppDelegate:appName forOrg:orgName];
    dataClient = appDelegate.dataClient;
}


/* These are the methods for the actual API calls */

/* 1. Create a new empty collection
 
 To start, let's create a function to create an empty collection and save it on Apigee. 
 To do this, we create an ApigeeeColleciton object. If the collection already exists, 
 the first 10 entities in it will be retrieved. */

-(NSDictionary*)createCollection {
    
    /* First, we specify the 'type' of the collection, then we create an instance of ApigeeCollection */
     
    NSString *type = @"book";

	currentCollection = [[ApigeeCollection alloc] init:dataClient type:type qs:nil];
    
    // extract the entities from the collection to display in-app
    NSArray *entities = [self getCollectionEntities:currentCollection];
    @try {
        // Success
        // Save the response in an NSDictionary and return it to the user
        NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:entities, @"entities", @"Success! Your collection was created. If it already existed, we'll display the entities in it below.", @"resultMsg", nil];
        return response;
    }
    @catch (NSException * e) {
        // Fail
        return [NSDictionary dictionaryWithObjectsAndKeys:nil, @"entities", @"Error! Did you enter the correct organization name?", @"resultMsg", nil];
    }
}

/* 2. Add entities to a collection
 
 Now we'll add some entities to our collection so that we have data to work with. 
 We're going to add a set of 4 entities using an NSArray.
 
 This method will add the array 4 times so that there's plenty of data in our collection
 to work with when we try out paging/cursors later. */

-(NSDictionary*)updateCollection {
    
    /* We start by defining the entities we want to create:
     - Specify the type of the entities you want to create
     - Declare a NSDictionary for each entity, and add properties to each */
    
    NSString *type = @"book";
    
    NSDictionary *entity1 = [NSDictionary dictionaryWithObjectsAndKeys:@"For Whom the Bell Tolls", @"title", type, @"type", nil];
    NSDictionary *entity2 = [NSDictionary dictionaryWithObjectsAndKeys:@"The Old Man and the Sea", @"title", type, @"type", nil];
    NSDictionary *entity3 = [NSDictionary dictionaryWithObjectsAndKeys:@"A Farewell to Arms", @"title", type, @"type", nil];
    NSDictionary *entity4 = [NSDictionary dictionaryWithObjectsAndKeys:@"The Sun Also Rises", @"title", type, @"type", nil];
    
    /* Next we add all our entities to an NSArray */
    NSArray *entityArray = [NSArray arrayWithObjects:entity1, entity2, entity3, entity4, nil];\
    
    // an array to hold the entities we added
    NSMutableArray *addedEntities = [[NSMutableArray alloc] init];
    
    /* Finally, we call the addEntity entity method on our ApigeeCollection to create the new entities.
       In this case, we are adding the array 5 times so that we have a good amount of data in our collection.*/
    for (int i = 0; i < 5; i++) {
        for (id entity in entityArray) {
            // This adds the entities to our local object, and initiates a POST to the API
            [currentCollection addEntity:entity];
            @try {
                // Success
                NSLog(@"%@",@"entity created");
                
                //add the entities to our array so we can display then to the user in-app
                [addedEntities addObjectsFromArray:[self getCollectionEntities:currentCollection]];
            }
            @catch (NSException * e) {
                // Fail
                NSLog(@"%@",@"entity not created");
            }
        }
    }
    
    // Save the response in an NSDictionary and return it to the user
    NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:addedEntities, @"entities", @"Success! Here are the titles and UUIDs of the entities that were added to the collection.", @"resultMsg", nil];
    return response;
    
}

/* 3. Retrieve a collection

Now that we have data in our collection, let's declare a function to retrieve it: */

-(NSDictionary*)retrieveCollection {
    
    /* To retrieve our collection we specify the 'type' of the collection we want to retrieve,
       then pass it to the getCollection method. */
    
    NSString *type = @"books";
    
    // initiates the API GET request and returns an ApigeeCollection object
    ApigeeQuery *query = [[ApigeeQuery alloc] init];
	currentCollection = [dataClient getCollection:type usingQuery:query];
    
    // extract the entities from the collection to display in-app
    NSArray *entities = [self getCollectionEntities:currentCollection];
    
    @try {
        // Success
        
        // Save the response in an NSDictionary and return it to the user
        NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:entities, @"entities", @"Success! Here are the titles and UUIDs of the first 10 entities in your collection:", @"resultMsg", nil];
        return response;
    }
    @catch (NSException * e) {
        // Fail
        return [NSDictionary dictionaryWithObjectsAndKeys:nil, @"entities", @"Error! Did you enter the correct organization name?", @"resultMsg", nil];
    }
}

/* 4. Using cursors (paging through a collection)
 
 By default, the Apigee API only returns the first 10 entities in a collection.
 This is why our retrieveCollection method from step 3 only gave us back the first
 10 entities in our collection.
 
 To get the next 10 results, we send a new GET request that references the
 'cursor' property of the previous response by using the getNextPage of the Apigee SDK. */

-(NSDictionary*)pageCollection {
    
    /* All we need to do is call getNextPage, which will automatically send the cursor in our
       ApigeeCollection object as a parameter of our API GET request to retrieve the next
       result set. */
    [currentCollection getNextPage];
    
    // extract the entities from the collection to display in-app
    NSArray *entities = [self getCollectionEntities:currentCollection];
    
    @try {
        // Success
        
        // Save the response in an NSDictionary and return it to the user
        NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:entities, @"entities", @"Success! Here are the titles and UUIDs of the next set of entities in your collection. 10 entities will be retrieved at a time.", @"resultMsg", nil];
        return response;
    }
    @catch (NSException * e) {
        // Fail
        return [NSDictionary dictionaryWithObjectsAndKeys:nil, @"entities", @"Error! Did you enter the correct organization name?", @"resultMsg", nil];
    }

}

/* 5. Delete a collection

At this time, it is not possible to delete a collection, but you can delete entities from a
collection, including performing batch deletes. Please be aware that removing entities from
a collection will delete the entities from your data store. */

-(NSDictionary*)deleteCollection {
    
    /* There is currently no dedicated method for batch deleting entities from a collection, so we will
       call the apiRequest method, which allows us to form our own API request 
     
       To do this we specify the following:
            - The full URL for the request, including our org name, app name and a query string
            - The HTTP request type. In this case DELETE
            - Any additional data to send with the request. In this case, we set this to nil */
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@",@"https://api.usergrid.com/",orgName,@"/",appName,@"/books/?limit=5"];
	NSString *op = @"DELETE";
	NSString *opData = nil;
	
	/* Next we call apiRequest to initiate the API call */
	ApigeeClientResponse *response = [dataClient apiRequest: url operation: op data: opData];
    
    // extract the entities from the collection to display in-app
    NSArray *entities = [self getClientResponseEntities:response];
    
    @try {
        // Success
        
        // Save the response in an NSDictionary and return it to the user
        NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:entities, @"entities", @"Success! Here are the titles and UUIDs of the five entities we deleted from the collection:", @"resultMsg", nil];
        return response;
    }
    @catch (NSException * e) {
        // Fail
        return [NSDictionary dictionaryWithObjectsAndKeys:nil, @"entities", @"Error! Did you enter the correct organization name?", @"resultMsg", nil];
    }
}


/* Calls the API request based on what button the user tapped in ApigeeMenuViewController. */
-(NSDictionary*)startRequest:(NSString*)requestType {
    NSDictionary *response;
    if ([requestType isEqualToString:@"create"]) {
        response = [self createCollection];
    } else if ([requestType isEqualToString:@"update"]) {
        response = [self updateCollection];
    } else if ([requestType isEqualToString:@"retrieve"]) {
        response = [self retrieveCollection];
    } else if ([requestType isEqualToString:@"page"]) {
        response = [self pageCollection];
    } else if ([requestType isEqualToString:@"delete"]) {
        response = [self deleteCollection];
    }
    return response;
}

/*** These methods are just for formatting the response **/

// Retrieve the title and uuid of all the entities in an ApigeeCollection
- (NSArray*)getCollectionEntities:(ApigeeCollection*)collection
{
    NSMutableArray *entities = [[NSMutableArray alloc]init];
    ApigeeEntity *entity;
    [collection resetEntityPointer];
    while([collection hasNextEntity]) {
        entity = [collection getNextEntity];
        [entities addObject:entity];
    }
    return entities;
}

// Retrieve the title and uuid of all the entities in an ApigeeClientResponse
- (NSArray*)getClientResponseEntities:(ApigeeClientResponse*)response
{
    NSArray* entities = [response entities];
    
    return entities;
}

/* Just a little something to turn our API responses into pretty printed JSON */

-(NSString*)entityToJSONString:(ApigeeEntity*)entity {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:entity
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

+(BOOL)issetCurrentCollection {
    if (currentCollection != nil){
        return YES;
    } else {
        return NO;
    }
}

@end
