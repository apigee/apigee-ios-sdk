//
//  ApigeeResultViewController.m
//  geolocation
//
//  Created by Alex Muramoto on 2/6/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

/* APIGEE iOS SDK GEOLOCATION EXAMPLE APP
 
 This ViewController calls the API method selected by the user in ApigeeMenuViewController
 and displays the result. */

#import "ApigeeResultViewController.h"
#import "ApigeeMenuViewController.h"
#import "ApigeeApiCalls.h"

@interface ApigeeResultViewController ()

@end

@implementation ApigeeResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    ApigeeApiCalls *apiClass = [[ApigeeApiCalls alloc] init];
    
    // Call startRequest from the ApigeeApiCalls class to make the actual API request
    NSDictionary *responseNSDicitonary = [apiClass startRequest:self.action];
    
    // Get the result status message we set in ApigeeApiCalls.m
    NSString *resultMsg = [responseNSDicitonary valueForKey:@"resultMsg"];
    
    // Get the entities from the response
    NSArray *entities = [responseNSDicitonary valueForKey:@"entities"];
    
    [self showResult:entities message:resultMsg];
}


// Display the result message and UUIDs of the entities returned
- (void)showResult:(NSArray*)entities message:(NSString*)resultMsg
{
    self.resultTextView.text = [self.resultTextView.text stringByAppendingFormat:@"%@%@", resultMsg, @"\n\n"];
    for( ApigeeEntity* entity in entities ) {
        
        NSString *storeName = [entity getStringProperty:@"storeName"];
        NSString *uuid = [entity uuid];
        NSString *latitude= [[[[entity properties] valueForKey:@"location"]valueForKey:@"latitude"] stringValue];
        NSString *longitude = [[[[entity properties] valueForKey:@"location"]valueForKey:@"longitude"] stringValue];
        
        self.resultTextView.text = [self.resultTextView.text stringByAppendingFormat:@"%@%@%@%@%@%@%@%@", storeName, @"\n", uuid, @"\n", latitude, @",", longitude, @"\n\n"];
    }
}

@end
