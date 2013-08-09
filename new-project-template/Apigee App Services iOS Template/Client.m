//
//  Client.m
//  Apigee App Services iOS Template
//
//  This class allows you to connnect to a remote instance
//  of Apigee App Services / Usergrid
//
//  Created by Tim Anglade on 2/22/13.
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "Client.h"
#import <ApigeeiOSSDK/ApigeeClient.h>

@implementation Client

@synthesize usergridClient;


/*
    1. Set your account details in the app
     
    - Enter your orgName below — it’s the username you picked when you signed up at apigee.com
    - Keep the appName as “sandbox”: it’s a context we automatically created for you.
      It’s completely open by default, but don’t worry, other apps you create are not!         */
- (id)init {
    self = [super init];
    if (self) {
        
        //This init creates the ApigeeClient object that holds your account credentials.
        //We also call the dataClient object we need to access data methods in the App Services SDK.
        NSString * orgName = @"YOUR APIGEE.COM USERNAME";
        NSString * appName = @"sandbox";
        
        ApigeeClient *apigeeClient =
            [[ApigeeClient alloc] initWithOrganizationId:orgName
                                           applicationId:appName];
        
        dataClient = [apigeeClient dataClient];
        [usergridClient setLogging:true]; //comment to remove debug output from the console window
    }
    return self;
}


/*
    2. Set some details for your first object
    
    Great, we know where your account is now!
    Let’s try to create a book, save it on Apigee, and output it in the app.
 
    - Keep the type as “book”
    - Enter the title of your favorite book below, instead of “the old man and the sea”.       */
-(NSString*)postBook {
    
    NSMutableDictionary *entity = [[NSMutableDictionary alloc] init ];
    
    [entity setObject:@"book" forKey:@"type"];
    [entity setObject:@"the old man and the sea" forKey:@"title"];
    
    ApigeeClientResponse *response = [usergridClient createEntity:entity];

    
    @try { //success - show us our new book!
        NSLog(@"%@",response.response);
        NSArray * books = [response.response objectForKey:@"entities"];;
        return [books objectAtIndex:0];
    }
    @catch (NSException * e) { //error
        return @"false";
    }
}

/*
    3. Now run it!
 
    You’re good to go! In Xcode, just click “Run” in the toolbar.
    - In the menus, select Run > Run, or hit the green “play” button in your toolbar.
    - If everything is working as expected, you will get a visual confirmation in the app!      */


/*
    4. Congrats, you’re done!
 
    - You can try adding more properties after line 60 and reloading the app!
    - You can then see the admin view of this data by logging in at https://apigee.com/usergrid
    - Or you can go explore more advanced examples in our docs: http://apigee.com/docs/app-services */

@end

// Psst… You can add more of your own client functions to this file…
// See our Messagee’s Client.m file for more examples!
// It's included with this SDK in /samples/messagee/Messagee/Client.m
