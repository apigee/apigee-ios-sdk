//
//  ApigeeResultViewController.m
//  entities
//
//  Created by Alex Muramoto on 1/15/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

/* APIGEE iOS SDK COLLECTION EXAMPLE APP
 
 This ViewController calls the API method selected by the user in ApigeeMenuViewController
 and displays the result. */

#import "ApigeeResultViewController.h"
#import "ApigeeMenuViewController.h"

@implementation ApigeeResultViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    ApigeeApiCalls *apiClass = [[ApigeeApiCalls alloc] init];
    
    // Call startRequest from the ApigeeApiCalls class to make the actual API request
    NSDictionary *responseNSDicitonary = [apiClass startRequest:self.action];
    
    // Get the result status message we set in ApigeeApiCalls.m
    NSString *resultMsg = [responseNSDicitonary valueForKey:@"resultMsg"];
    
    // Get the full JSON response
    NSArray *entities = [responseNSDicitonary valueForKey:@"entities"];
    
    [self showResult:entities message:resultMsg];
}

// Display the result message, and the titles and UUIDs of the entities returned
- (void)showResult:(NSArray*)entities message:(NSString*)resultMsg
{
    self.resultTextView.text = [self.resultTextView.text stringByAppendingFormat:@"%@%@", resultMsg, @"\n\n"];
    for( ApigeeEntity* entity in entities ) {
        self.resultTextView.text = [self.resultTextView.text stringByAppendingFormat:@"%@%@%@%@%@%@", @"Title:", [entity getStringProperty:@"title"], @"\n", @"UUID:", [entity uuid], @"\n\n"];
    }
}

@end
