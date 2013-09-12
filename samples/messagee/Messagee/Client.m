//
//  Client.m
//  Messagee
//
//  Created by Rod Simpson on 12/27/12.
//  Copyright (c) 2012 Rod Simpson. All rights reserved.
//

#import "Client.h"
#import <ApigeeiOSSDK/ApigeeClient.h>
#import <ApigeeiOSSDK/ApigeeMonitoringOptions.h>

@implementation Client

@synthesize usergridClient, user;

- (id)init
{
    self = [super init];
    if (self) {
        
        //configure the org and app
        NSString * orgName = @"ApigeeOrg";
        NSString * appName = @"MessageeApp";
        NSString * baseURL = @"https://api.usergrid.com";
        
        ApigeeMonitoringOptions* monitoringOptions = [[ApigeeMonitoringOptions alloc] init];
        monitoringOptions.crashReportingEnabled = NO;
        monitoringOptions.monitoringEnabled = NO;

        ApigeeClient *apigeeClient =
            [[ApigeeClient alloc] initWithOrganizationId:orgName
                                           applicationId:appName
                                                 baseURL:baseURL
                                                 options:monitoringOptions];
        usergridClient = [apigeeClient dataClient];
        //[usergridClient setLogging:true]; //uncomment to see debug output in console window
    }
    return self;
}

-(BOOL)login:(NSString*)username withPassword:(NSString*)password {
    
    ApigeeClientResponse *response =
        [usergridClient logInUser:username password:password];
    if ([response completedSuccessfully]) {
        user = [usergridClient getLoggedInUser];
    
        if (user.username){
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

-(void)login:(NSString*)username
withPassword:(NSString*)password
completionHandler:(void (^)(BOOL loginSucceeded))completionBlock
{
    [usergridClient logInUser:username
                     password:password
            completionHandler:^(ApigeeClientResponse *response) {
                if (completionBlock) {
                    completionBlock([response completedSuccessfully]);
                }
            }];
}


-(BOOL)createUser:(NSString*)username
         withName:(NSString*)name
        withEmail:(NSString*)email
     withPassword:(NSString*)password{

    ApigeeClientResponse *response =
        [usergridClient addUser:username
                          email:email
                           name:name
                       password:password];
    if ([response completedSuccessfully]) {
        return [self login:username withPassword:password];
    }
    return NO;
}

-(void)createUser:(NSString*)username
         withName:(NSString*)name
        withEmail:(NSString*)email
     withPassword:(NSString*)password
completionHandler:(void (^)(BOOL userCreatedAndLoggedIn))completionBlock
{
    __block Client *weakSelf = self;

    [usergridClient addUser:username
                      email:email
                       name:name
                   password:password
     completionHandler:^(ApigeeClientResponse *response) {
         if ([response completedSuccessfully]) {
             [weakSelf login:username
                withPassword:password
           completionHandler:completionBlock];
             weakSelf = nil;
         } else {
             if (completionBlock) {
                 completionBlock(NO);
             }
         }
     }];
}

-(NSArray*)getFollowing {
        
    ApigeeQuery *query = [[ApigeeQuery alloc] init];
    [query addURLTerm:@"limit" equals:@"30"];
    ApigeeClientResponse *response =
        [usergridClient getEntityConnections:@"users"
                                 connectorID:@"me"
                              connectionType:@"following"
                                       query:query];

    return [response.response objectForKey:@"entities"];
}

-(void)getFollowing:(void (^)(NSArray *following))completionBlock {
    ApigeeQuery *query = [[ApigeeQuery alloc] init];
    [query addURLTerm:@"limit" equals:@"30"];
    [usergridClient getEntityConnections:@"users"
                             connectorID:@"me"
                          connectionType:@"following"
                                   query:query
     completionHandler:^(ApigeeClientResponse *response) {
         if (completionBlock) {
             if ([response completedSuccessfully]) {
                 completionBlock([response.response objectForKey:@"entities"]);
             } else {
                 completionBlock(nil);
             }
         }
     }];
}

-(BOOL)followUser:(NSString*)username{
    
    ApigeeClientResponse *response =
        [usergridClient connectEntities:@"users"
                        connectorID:@"me"
                        connectionType:@"following"
                        connecteeType:@"users"
                        connecteeID:username];
    return [response completedSuccessfully];
}

-(void)followUser:(NSString*)username completionHandler:(void (^)(ApigeeClientResponse *response))completionBlock
{
    [usergridClient connectEntities:@"users"
                        connectorID:@"me"
                     connectionType:@"following"
                      connecteeType:@"users"
                        connecteeID:username
                  completionHandler:completionBlock];
}

-(NSArray*)getMessages {
    
    ApigeeQuery *query = [[ApigeeQuery alloc] init];
    [query addURLTerm:@"limit" equals:@"30"];
    ApigeeClientResponse *response =
        [usergridClient getActivityFeedForUser:[user username]
                                         query:query];
    
    return [response.response objectForKey:@"entities"];
}

-(void)getMessages:(void (^)(NSArray *messages))completionBlock {
    ApigeeQuery *query = [[ApigeeQuery alloc] init];
    [query addURLTerm:@"limit" equals:@"30"];
    [usergridClient getActivityFeedForUser:[user username]
                                     query:query
     completionHandler:^(ApigeeClientResponse *response) {
         if (completionBlock) {
             if ([response completedSuccessfully]) {
                 completionBlock([response.response objectForKey:@"entities"]);
             } else {
                 completionBlock(nil);
             }
         }
     }];
}

-(void)populateMessageActivityProperties:(NSMutableDictionary*)activityProperties
                                 message:(NSString*)message
{
    /*
     //we are trying to build a json object that looks like this:
     {
     "actor" : {
     "displayName" :"myusername",
     "uuid" : "myuserid",
     "username" : "myusername",
     "email" : "myemail",
     "picture": "http://path/to/picture",
     "image" : {
     "duration" : 0,
     "height" : 80,
     "url" : "http://www.gravatar.com/avatar/",
     "width" : 80
     },
     },
     "verb" : "post",
     "content" : content,
     "lat" : 48.856614,
     "lon" : 2.352222
     }
     */
    
    NSMutableDictionary *actor = [[NSMutableDictionary alloc] init];
    
    NSString *username = [user username];
    NSString *email = [user email];
    NSString *uuid = [user uuid];
    NSString *picture = [user picture];
    NSString *lat = @"48.856614"; //todo: get coords from the phone
    NSString *lon = @"2.352222f";
    
    // actor
    [actor setObject:username forKey:@"displayName"];
    [actor setObject:uuid forKey:@"uuid"];
    [actor setObject:username forKey:@"username"];
    [actor setObject:email forKey:@"email"];
    [actor setObject:picture forKey:@"picture"];
    
    // activity
    [activityProperties setValue:actor forKey:@"actor"];
    [activityProperties setObject:@"post" forKey:@"verb"];
    [activityProperties setObject:message forKey:@"content"];
    [activityProperties setObject:lat forKey:@"lat"];
    [activityProperties setObject:lon forKey:@"lon"];
}

-(BOOL)postMessage:(NSString*)message {
    
    NSMutableDictionary *activityProperties = [[NSMutableDictionary alloc] init];
    [self populateMessageActivityProperties:activityProperties
                                    message:message];

    ApigeeClientResponse *response =
        [usergridClient postUserActivity:[user uuid]
                              properties:activityProperties];
    
    return [response completedSuccessfully];
}

-(void)postMessage:(NSString*)message
 completionHandler:(void (^)(ApigeeClientResponse *response))completionBlock
{
    NSMutableDictionary *activityProperties = [[NSMutableDictionary alloc] init];
    [self populateMessageActivityProperties:activityProperties
                                    message:message];
    
    [usergridClient postUserActivity:[user uuid]
                          properties:activityProperties
                   completionHandler:completionBlock];
}

@end
