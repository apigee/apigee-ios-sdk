//
//  ViewController.m
//  Apigee App Services iOS Template
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

NSString *rawResponse;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _client = [[Client alloc] init];
    
    rawResponse = [[_client postBook] description];
    
    if ([rawResponse isEqual:@"false"]){
        _textView.text = @"Could not create the book.\n\nDid you enter your orgName (username) correctly on line 30 of Client.m?";
    } else {
        _textView.text = [@"Success! Here is the the object we stored; notice the timestamps and unique id we created for you\n\n" stringByAppendingString:rawResponse];
    }
}


@end
