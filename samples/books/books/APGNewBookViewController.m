//
//  APGNewBookViewController.m
//  Books
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "APGNewBookViewController.h"

@implementation APGNewBookViewController

@synthesize bookTitleText;
@synthesize bookAuthorText;
@synthesize delegate;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

-(IBAction)createBook:(id)sender {
    [[self delegate] addNewBook:@{@"title": bookTitleText.text, @"author": bookAuthorText.text}];
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

@end
