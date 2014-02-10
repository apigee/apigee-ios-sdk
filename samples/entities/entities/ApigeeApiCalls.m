//
//  ApigeeApiCalls.m
//  entities
//
//  Created by Alex Muramoto on 1/15/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

/* APIGEE iOS SDK Entity EXAMPLE APP
 
 This class handles our API requests. See the code comments
 for detailed info on how each request type works. */

#import "ApigeeApiCalls.h"
#import "ApigeeAppDelegate.h"
#import "ApigeeMenuViewController.h"
#import <ApigeeiOSSDK/Apigee.h>

@implementation ApigeeApiCalls

ApigeeDataClient *dataClient;
NSString *currentEntity;
    
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


/* Calls the API request based on what button the user tapped in ApigeeMenuViewController. */
-(NSDictionary*)startRequest:(NSString*)requestType {
    NSDictionary *response;
    if ([requestType isEqualToString:@"create"]) {
        response = [self createEntity];
    } else if ([requestType isEqualToString:@"retrieve"]) {
        response = [self retrieveEntity];
    } else if ([requestType isEqualToString:@"update"]) {
        response = [self updateEntity];
    } else if ([requestType isEqualToString:@"delete"]) {
        response = [self deleteEntity];
    }
    return response;
}

    
/* These are the methods for the actual API calls */

/* 1. Create a new entity
 To start, let's create a function to create an entity and save it on Apigee. */

-(NSDictionary*)createEntity {
    
    /* First, we specify the following properties for our new entity in an NSDictionary:
        
        - The type property associates your entity with a collection. When the entity
        is created, if the corresponding collection doesn't exist a new collection
        will automatically be created to hold any entities of the same type.
            
        Collection names are the pluralized version of the entity type,
        e.g. all entities of type book will be saved in the books collection.
            
        - Let's specify some custom properties for your entity. Properties are formatted
        as key-value pairs. We've started you off with three properties in addition
        to type, but you can add any properties you want. */
            
    NSMutableDictionary *entity = [[NSMutableDictionary alloc] init ];
    
    [entity setObject:@"book" forKey:@"type"]; //Required. New entity type to create
    [entity setObject:@"The Old Man and the Sea" forKey:@"title"];
    [entity setObject:@"5.50" forKey:@"price"];
    [entity setObject:@"USD" forKey:@"currency"];
    
    /* Next, we call the createEntity method to initiate the API call. Notice that
     we are calling createEntity from our ApigeeDataClient instance, so that the Apigee API
     knows what data store we want to work with. */
    
    ApigeeClientResponse *response = [dataClient createEntity:entity];
    
    @try {	    
        // Success
        
        // Retrieve the entity UUID from the response
        currentEntity = [[response firstEntity] uuid];
                
        // convert the ApigeeClientResponse to a JSON string to make it human-readable
        NSString *responseJSON = [self NSDictionarytoJSONString:response.response];
        
        // Save the response in an NSDictoinary and return it to the user
        NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:  currentEntity, @"uuid", responseJSON, @"fullResponse", @"Success! Here is the UUID of the entity we created:", @"resultMsg", nil];
        return response;
    }
    @catch (NSException * e) {
        // Fail
        return [NSDictionary dictionaryWithObjectsAndKeys:nil, @"uuid", @"Error! Did you enter the correct organization name?", @"fullResponse", @"", @"resultMsg", nil];
    }
}


/* 2. Retrieve an entity
 
 Now that we can create entities, let's define a function to retrieve them: */

-(NSDictionary*)retrieveEntity {
    
	/* - We specify the 'type' of the entity to be retrieved, 'book' in this case.
       - We also specify the 'UUID' property of the entity to be retrieved. In this case,
     we use currententity, which is the uuid of the entity we created earlier. */

	NSString *type = @"book";
    
    ApigeeClientResponse *response = [dataClient getEntity:type uuid:currentEntity];
	
	@try {
	    //success
        NSString *responseJSON = [self NSDictionarytoJSONString:response.response];
        NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:  currentEntity, @"uuid", responseJSON, @"fullResponse", @"Success! Here is the UUID of the entity we retrieved:", @"resultMsg", nil];
        
        return response;
	}
	
	@catch (NSException * e) {
	    //fail
        return [NSDictionary dictionaryWithObjectsAndKeys:nil, @"uuid", @"Error! Did you enter the correct organization name?", @"fullResponse", @"", @"resultMsg", nil];
	}
    
}


/* 3. Update/alter an entity
 
 We can easily add new properties to an entity or change existing properties by making a
 call to the Apigee API. Let's define a method to add a new property and update an existing
 property, then display the updated entity. */

-(NSDictionary*)updateEntity {
    
    /*
     - We specify the 'uuid' of the entity to be updated. In this case, we again use currentEntity.
     - In a NSMutableDictionary, we specify the following:
        - The type property of the entity. In this case, 'book'.
        - New properties to add to the entity. In this case, we'll add a property
          to show whether the book is available.
        - New values for existing properties. In this case, we are updating the 'price' property. */
    
    //Create an entity object
	NSMutableDictionary *updatedEntity = [[NSMutableDictionary alloc] init ];
	
	//Set entity properties to be updated
	[updatedEntity setObject:@"book" forKey:@"type"]; //Required - entity type
    [updatedEntity setObject:@"in-stock" forKey:@"availability"];
	[updatedEntity setObject:@"4.00" forKey:@"price"];
    
	//call updateEntity to initiate the API call
	ApigeeClientResponse *response = [dataClient updateEntity:currentEntity entity:updatedEntity];
    
    @try {
        //success
        
        NSString *responseJSON = [self NSDictionarytoJSONString:response.response];
        NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:  currentEntity, @"uuid", responseJSON, @"fullResponse", @"Success! Here is the UUID of the entity we updated:", @"resultMsg", nil];
        
        return response;
    }
    @catch (NSException * e) {
        //fail
        return [NSDictionary dictionaryWithObjectsAndKeys:nil, @"uuid", @"Error! Did you enter the correct organization name?", @"fullResponse", @"", @"resultMsg", nil];
    }
    
}

/* 4. Delete an entity
 
 Now that we've created, retrieved and updated our entity, let's delete it. This will
 permanently remove the entity from your data store. */

-(NSDictionary*)deleteEntity {
    
    /* - We only need to specify the 'type' and 'uuid' of the entity to be deleted so
         that the API knows what entity we are trying to delete. */

	NSString *type = @"book";
	
	//call removeEntity to initiate the API call
	ApigeeClientResponse *response = [dataClient removeEntity:type entityID:currentEntity];
	
	@try {
	    //success
        NSString *responseJSON = [self NSDictionarytoJSONString:response.response];
        NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:  currentEntity, @"uuid", responseJSON, @"fullResponse", @"Success! Here is the UUID of the entity we deleted:", @"resultMsg", nil];
        currentEntity = nil;
        return response;
	}
	@catch (NSException * e) {
	    //fail
        return [NSDictionary dictionaryWithObjectsAndKeys:nil, @"uuid", @"Error! Did you enter the correct organization name?", @"fullResponse", @"", nil];
	}
    
}
    
/* Just a little something to turn our API responses into pretty printed JSON */

-(NSString*)NSDictionarytoJSONString:(NSDictionary*)responseNSDictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseNSDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

+(NSString*) getCurrentEntity {
    return currentEntity;
}

@end
