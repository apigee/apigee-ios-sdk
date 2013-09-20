//
//  NewMessageViewController.m
//  Messagee
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "NewMessageViewController.h"
#import "TabBarController.h"

static NSString *kSegueMessagePosted = @"messagePostedSegue";


@implementation NewMessageViewController

@synthesize messageTextField;

@synthesize client = _client;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)flag {
    [super viewWillAppear:flag];
    [messageTextField becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [messageTextField becomeFirstResponder];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setMessageTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    [messageTextField resignFirstResponder]; 
    if ([segue.identifier isEqualToString:kSegueMessagePosted]){
        TabBarController *dvc = [segue destinationViewController];
        [dvc setClient:_client];
    }
}

- (IBAction)postMessage:(id)sender {
 
    NSString *errorTitle = nil;
    NSString *errorMesssage = nil;
    
    if (![[messageTextField text] isEqualToString:@""]) {
        
        [_client postMessage:[messageTextField text]
           completionHandler:^(ApigeeClientResponse *response){
               
               if( [response completedSuccessfully] ) {
                   //invoke segue back to message list
                   [self performSegueWithIdentifier:kSegueMessagePosted sender:self];
               } else {
                   NSString *errorTitle = @"Oops!";
                   NSString *errorMesssage = @"There was a problem posting the message - please try again.";

                   UIAlertView* alert =
                   [[UIAlertView alloc] initWithTitle:errorTitle
                                              message:errorMesssage
                                             delegate:nil
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil];
                   [alert show];
               }
            }];
        
    } else {
        errorTitle = @"Oops!";
        errorMesssage = @"The message was empty.";
    }

    if (errorTitle && errorMesssage) {
        UIAlertView* alert =
            [[UIAlertView alloc] initWithTitle:errorTitle
                                       message:errorMesssage
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
        [alert show];
    }
}

@end
