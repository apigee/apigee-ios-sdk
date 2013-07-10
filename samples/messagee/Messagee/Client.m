//
//  Client.m
//  Messagee
//
//  Created by Rod Simpson on 12/27/12.
//  Copyright (c) 2012 Rod Simpson. All rights reserved.
//

#import "Client.h"
#import <ApigeeiOSSDK/ApigeeClient.h>

@implementation Client

@synthesize usergridClient, user;

- (id)init
{
    self = [super init];
    if (self) {
        
        //configure the org and app
        NSString * orgName = @"ApigeeOrg";
        NSString * appName = @"MessageeApp";

        ApigeeClient *apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:orgName applicationId:appName];
        //make new client
        usergridClient = [apigeeClient dataClient];
        //[usergridClient setLogging:true]; //uncomment to see debug output in console window
    }
    return self;
}

-(bool)login:(NSString*)username withPassword:(NSString*)password {
    
    //uncomment the below for easy testing (just click login)
    //username = @"myuser";
    //password = @"mypass";
    
    //then log the user in
    //UGClientResponse *response =
    [usergridClient logInUser:username password:password];
    user = [usergridClient getLoggedInUser];
    
    if (user.username){
        return true;
    } else {
        return false;
    }
    
}

-(bool)createUser:(NSString*)username
         withName:(NSString*)name
        withEmail:(NSString*)email
     withPassword:(NSString*)password{

    
    ApigeeClientResponse *response = [usergridClient addUser:username email:email name:name password:password];
    if (response.transactionState == 0) {
        return [self login:username withPassword:password];
    }
    return false;
}

-(NSArray*)getFollowing {
        
    ApigeeQuery *query = [[ApigeeQuery alloc] init];
    [query addURLTerm:@"limit" equals:@"30"];
    ApigeeClientResponse *response = [usergridClient getEntityConnections: @"users" connectorID:@"me" connectionType:@"following" query:query];

    NSArray * following = [response.response objectForKey:@"entities"];

    return following;
    
}

-(bool)followUser:(NSString*)username{
    
    ApigeeClientResponse *response =
        [usergridClient connectEntities:@"users"
                        connectorID:@"me"
                        connectionType:@"following"
                        connecteeType:@"users"
                        connecteeID:username];
    
    if (response.transactionState == 0) {
        return true;
    }
    return false;
    
}


-(NSArray*)getMessages {
    
    NSString *username = [user username];
    
    ApigeeQuery *query = [[ApigeeQuery alloc] init];
    [query addURLTerm:@"limit" equals:@"30"];
    ApigeeClientResponse *response = [usergridClient getActivityFeedForUser:username query:query];
    
    NSArray *messages = [response.response objectForKey:@"entities"];

    return messages;
    
}

-(bool)postMessage:(NSString*)message {
    
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
    
    NSMutableDictionary *activity = [[NSMutableDictionary alloc] init ];
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
    [activity setValue:actor forKey:@"actor"];
    [activity setObject:@"post" forKey:@"verb"];
    [activity setObject:message forKey:@"content"];
    [activity setObject:lat forKey:@"lat"];
    [activity setObject:lon forKey:@"lon"];

    ApigeeClientResponse *response = [usergridClient postUserActivity:uuid activity:activity];
    
    if (response.transactionState == 0) {
        return true;
    }
    return false;
}


@end
