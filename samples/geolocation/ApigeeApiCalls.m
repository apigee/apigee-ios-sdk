//
//  ApigeeApiCalls.m
//  geolocation
//
//  Created by Alex Muramoto on 2/6/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

/* APIGEE iOS SDK GEOLOCATION EXAMPLE APP
 
 This class handles our API requests. See the code comments
 for detailed info on how each request type works. */

#import "ApigeeApiCalls.h"
#import "ApigeeAppDelegate.h"
#import <ApigeeiOSSDK/Apigee.h>

@implementation ApigeeApiCalls

double latitude;
double longitude;
ApigeeDataClient *dataClient;

/* Initializes the SDK in the App Delegate by creating an instance of the ApigeeClient class.
 This also gives us an instance of the ApigeeDataClient class, which we use to send our
 organization and application name with our API requests. */

-(void)initializeSDK:(NSString*)orgInput {
    NSString *orgName = orgInput;
    NSString *appName = @"sandbox";
    ApigeeAppDelegate *appDelegate = (ApigeeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate initializeSDKInAppDelegate:appName forOrg:orgName];
    dataClient = appDelegate.dataClient;
}

/* 1. Add entities to a collection
 
 Now we'll add some entities to a collection so that we have data to work with. In this case,
 we are going to add three entities that contain location data */

- (NSDictionary*)createEntities {
    
    /* We start by defining the entities we want to create:
     - Specify the type of the entities you want to create
     - Declare a NSMutableDictionary for each entity, and add properties to each. Since we are adding a nested
     "location" object with our entity coordinates, we create a separate "location" NSDictionary,
     then add it to our entity object. */
    
    NSString *type = @"store";
    
    // These are our entity objects
    NSMutableDictionary *entity1 = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *entity2 = [[NSMutableDictionary alloc] init];;
    NSMutableDictionary *entity3 = [[NSMutableDictionary alloc] init];;
    
    // These are our location objects that will be nested in our entity objects
    NSMutableDictionary *entity1_geo = [[NSMutableDictionary alloc] init];;
    NSMutableDictionary *entity2_geo = [[NSMutableDictionary alloc] init];;
    NSMutableDictionary *entity3_geo = [[NSMutableDictionary alloc] init];;
    
    // We automatically locate the entities 1, 5 and 10 miles from the user's current location
    [entity1_geo setObject:[NSNumber numberWithDouble:(latitude + .014492)] forKey:@"latitude"];
    [entity1_geo setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    [entity1 setObject:@"Home Depot" forKey:@"storeName"];
    [entity1 setObject:entity1_geo forKey:@"location"];
    [entity1 setObject:type forKey:@"type"];
    
    [entity2_geo setObject:[NSNumber numberWithDouble:(latitude + .068837)] forKey:@"latitude"];
    [entity2_geo setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    [entity2 setObject:@"Macy's" forKey:@"storeName"];
    [entity2 setObject:entity2_geo forKey:@"location"];
    [entity2 setObject:type forKey:@"type"];
    
    [entity3_geo setObject:[NSNumber numberWithDouble:(latitude + .14492)] forKey:@"latitude"];
    [entity3_geo setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    [entity3 setObject:@"Target" forKey:@"storeName"];
    [entity3 setObject:entity3_geo forKey:@"location"];
    [entity3 setObject:type forKey:@"type"];
    
    /* Next, we add all of our entities to an NSArray to make them easier to POST */
    NSMutableArray *storeArray = [[NSMutableArray alloc] init];
    [storeArray addObject:entity1];
    [storeArray addObject:entity2];
    [storeArray addObject:entity3];
    
    // an array to hold the entities we added
    NSMutableArray *addedEntities = [[NSMutableArray alloc] init];
    
    /* Then we call the createEntity method and pass in our type and entities
     to initiate the API call. */
    
    for (NSDictionary* entity in storeArray) {
        @try {
            // Success
            // extract the entities from the response and add them to our array so we can
            // display then to the user in-app
            ApigeeClientResponse * response = [dataClient createEntity:entity];
            [addedEntities addObjectsFromArray:[response entities]];
        } @catch (NSException *e) {
            // Fail
            return [NSDictionary dictionaryWithObjectsAndKeys:nil, @"entities", @"Error! Did you enter the correct organization name?", @"resultMsg", nil];
        }
    }
    NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:addedEntities, @"entities", @"Success! Your entities were created with location data. Here are the storeName, UUID, latitude and longitude properties of the entities we created.\n\nNotice how we automatically set their locations 1, 5 and 10 miles from your current location.", @"resultMsg", nil];
    return response;
}

/* 2. Retrieve entities by location
 
 Now that we have data in our collection, let's declare a method to retrieve it. To do this we pass in a query
 string that requests all entities within a set distance of a specific set of coordinates. */

- (NSDictionary*)retrieveEntities {
    
    /* To retrieve our entities we need to provide two arguments:
     - The entity type associated with the collection we want to retrieve
     - A query string to refine our result set. In this case, we are going to request
     all entities within 8047 meters (~5 miles) of the user's current position.
    
     The query string is an apigee-specific syntax in the following format, where distance
     must be specified in meters:
     
     "location within <distance> of <latitude>, <longitude>" */
    
    NSString *type = @"store";
    
    NSString *queryString = [NSString stringWithFormat:@"%@%@%@%@",@"location within 8047 of ",[NSString stringWithFormat:@"%f", latitude],@",",[NSString stringWithFormat:@"%f", longitude]];
    
    /* We call getEntities to initiate the API GET request */
    ApigeeClientResponse *response = [dataClient getEntities:type queryString:queryString];
    @try {
        // Success
        return [NSDictionary dictionaryWithObjectsAndKeys:[response entities], @"entities", @"Success! Your entities were retrieved. Notice how only the entities within our 8047 meter radius were returned.\n\nHere are the storeName, UUID, latitude and longitude properties of the entities we retrieved:", @"resultMsg", nil];
    }
    @catch (NSException *e) {
        //Fail
        return [NSDictionary dictionaryWithObjectsAndKeys:nil, @"entities", @"Error! Did you enter the correct organization name?", @"resultMsg", nil];
    }
}

// set the latitude and longitude vars. Called from ApigeeStartViewController when the user's location is retrieved
+(void)setLocation:(double)userLatitude longitude:(double)userLongitude
{
    latitude = userLatitude;
    longitude = userLongitude;
}

// Calls the API request based on what button the user tapped in ApigeeMenuViewController.
-(NSDictionary*)startRequest:(NSString*)requestType {
    NSDictionary *response;
    if ([requestType isEqualToString:@"create"]) {
        response = [self createEntities];
    } else if ([requestType isEqualToString:@"retrieve"]) {
        response = [self retrieveEntities];
    }    
    return response;
}

@end
