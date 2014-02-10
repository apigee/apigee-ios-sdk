//
//  ApigeeResultViewController.m
//  entities
//
//  Created by Alex Muramoto on 1/15/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

/* APIGEE iOS SDK ENTITY EXAMPLE APP

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
    NSString *responseNSDicitonary = [apiClass startRequest:self.action];
    
    // Get the result status message we set in ApigeeApiCalls.m
    NSString *resultMsg = [responseNSDicitonary valueForKey:@"resultMsg"];
    
    // Get the UUID of the entity we acted on from the API response
    NSString *responseUuid = [responseNSDicitonary valueForKey:@"uuid"];
    
    // Get the full JSON response
    NSString *fullResponse = [responseNSDicitonary valueForKey:@"fullResponse"];
    
    [self showResult:fullResponse message:resultMsg uuid:responseUuid];
}

// Concatenate the result message, entity UUID and full API response and display it in ApigeeResultViewController
- (void)showResult:(NSString*)apiResponse message:(NSString*)resultMsg uuid:(NSString*)responseUuid
{
    if (responseUuid == nil) {
        self.resultTextView.text = [NSString stringWithFormat:@"%@", resultMsg];
    } else {
        self.resultTextView.text = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", resultMsg, @"\n\n", responseUuid, @"\n\n", @"And here is the full API response:", @"\n\n", apiResponse];
    }
}

@end
