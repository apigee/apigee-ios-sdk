//
//  UsersApiClient.m
//  UsersAndGroups
//
//  Created by Steve Traut on 1/16/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "UsersApiClient.h"
#import "UsersAppDelegate.h"

@implementation UsersApiClient

@synthesize apigeeClient, dataClient, monitoringClient;

- (id)initWithApigeeClient:(ApigeeClient *)client
{
    self = [super init];
    if (self)
    {
        //Instantiate ApigeeClient to initialize the SDK
        apigeeClient = client;
        
        //Retrieve instances of ApigeeClient.monitoringClient and ApigeeClient.dataClient
        monitoringClient = [apigeeClient monitoringClient]; //used to call App Monitoring methods
        dataClient = [apigeeClient dataClient]; //used to call data methods
    }
    return self;
}

- (id)init
{
    self = [super init];
    return self;
}

/**
 * Loads the list of users from the application.
 */
- (NSMutableArray *)loadUserData
{
    __block NSMutableArray *users;
    
    // Get users from the application with an async SDK method.
    [[apigeeClient dataClient] getUsers:
     nil completionHandler:^(ApigeeClientResponse *result){
         
         // If the request was successful, assign the resulting list
         // to an array that will be used to display in the UI.
         if (result.transactionState == kApigeeClientResponseSuccess) {
             users = result.response[@"entities"];
         } else
         {
             users = [[NSMutableArray alloc] init];
         }
     }];
    return users;
}

/**
 * Adds a new user to the application. This method is called
 * from the "add user" view when the user clicks the Add button.
 */
- (BOOL)addUser:(NSString *)userName
           name:(NSString *)name
          email:(NSString *)email
       password:(NSString *)password
{
    __block BOOL userAdded;
    // Use the received values to add a new user with an async SDK method.
    [[self.apigeeClient dataClient] addUser:userName
                                      email:email
                                       name:name
                                   password:password
                          completionHandler:^(ApigeeClientResponse *response) {
                              if (response.transactionState == kApigeeClientResponseSuccess)
                              {
                                  userAdded = YES;
                              }
                              userAdded = NO;
                          }];
    return userAdded;
}

- (BOOL)addGroup:(NSString *)name
            path:(NSString *)path
{
    __block BOOL groupAdded = NO;

    [[self.apigeeClient dataClient] createGroup:path
                                groupTitle:name
                         completionHandler:^(ApigeeClientResponse *response)
     {
         if (response.transactionState == kApigeeClientResponseSuccess)
         {
             groupAdded = YES;
         }
     }];
    return groupAdded;
}

/**
 * Adds the current user to the selected group.
 */
- (BOOL)addUserToGroup:(NSString *)userName
                  path:(NSString *)selectedGroup
{
    __block BOOL userAddedToGroup = NO;
    
    // Add the user through a call to an SDK method.
    [[self.apigeeClient dataClient] addUserToGroup:userName group:selectedGroup
                            completionHandler:^(ApigeeClientResponse *response)
     {
         if (response.transactionState == kApigeeClientResponseSuccess) {
             
             // If the attempt was successful.
             userAddedToGroup = YES;
         }
     }];
    return userAddedToGroup;
}

/**
 * Loads the list of groups the current user is
 * already in.
 */
- (NSMutableArray *)loadGroupsForUser:(NSString *)userName
{
    __block NSMutableArray *groupsForUser = [[NSMutableArray alloc] init];
    
    // Get the group list by calling an SDK method.
    [[self.apigeeClient dataClient] getGroupsForUser:userName
                              completionHandler:^(ApigeeClientResponse *result){
                                  if (result.transactionState == kApigeeClientResponseSuccess) {
                                      // If request was successful, load the group list
                                      // into an array for display in the UI.
                                      groupsForUser = result.response[@"entities"];
                                  }
                              }];
    return groupsForUser;
}

/**
 * Loads the full list of groups in the app.
 */
- (NSMutableArray *)loadAllGroups
{
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    // Get the collection of groups by calling an SDK method.
    ApigeeCollection *groupsCollection =
    [[self.apigeeClient dataClient] getCollection:@"groups"];
    
    if ([groupsCollection hasNextEntity])
    {
        // If there are groups in the return value,
        // load the list into an array for display in the UI.
        ApigeeClientResponse *result = [groupsCollection fetch];
        groups = result.response[@"entities"];
    }
    return groups;
}

@end
