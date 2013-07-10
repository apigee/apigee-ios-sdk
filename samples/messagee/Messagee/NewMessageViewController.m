//
//  NewMessageViewController.m
//  Messagee
//
//  Created by Rod Simpson on 12/28/12.
//  Copyright (c) 2012 Rod Simpson. All rights reserved.
//

#import "NewMessageViewController.h"
#import "TabBarController.h"

@interface NewMessageViewController ()

@end

@implementation NewMessageViewController

@synthesize messageTextField;

@synthesize client = _client;

- (void)setClient:(Client *)c {
    _client = c;
}

- (Client *)client {
    return _client;
}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    [messageTextField resignFirstResponder]; 
    if ([segue.identifier isEqualToString:@"messagePostedSegue"]){
        TabBarController *dvc = [segue destinationViewController];
        [dvc setClient:_client];
    }
    
}

- (IBAction)postMessage:(id)sender {
 
    NSString * errorTitle;
    NSString * errorMesssage;
    if (![[messageTextField text] isEqualToString:@""]) {
        
        if ([_client postMessage:[messageTextField text]]) {
            //invoke segue back to message list
            return [self performSegueWithIdentifier:@"messagePostedSegue" sender:self];
        } else {
            errorTitle = @"Oops!";
            errorMesssage = @"There was a problem posting the message - please try again.";
        }
        
    } else {
        errorTitle = @"Oops!";
        errorMesssage = @"The message was empty.";
    }

    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:errorTitle
                          message:errorMesssage
                          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];


}
@end
