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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.bookTitleText becomeFirstResponder];
}

-(IBAction)cancelBookCreate:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)createBook:(id)sender {
    NSString* bookTitle = bookTitleText.text;
    NSString* bookAuthor = bookAuthorText.text;
    
    if ([bookTitle length] > 0) {
        [[self delegate] addNewBook:@{@"title":bookTitle, @"author":bookAuthor}];
        [self dismissViewControllerAnimated:YES completion:^(){}];
    } else {
        UIAlertView* alert =
            [[UIAlertView alloc] initWithTitle:@"Error"
                                       message:@"Book title is required"
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
        [alert show];
    }
}

@end
