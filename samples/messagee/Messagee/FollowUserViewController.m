//
//  FollowUserViewController.m
//  Messagee
//
//  Created by Rod Simpson on 12/28/12.
//  Copyright (c) 2012 Rod Simpson. All rights reserved.
//

#import "FollowUserViewController.h"
#import "TabBarController.h"

@interface FollowUserViewController ()

@end

@implementation FollowUserViewController

@synthesize usernameField;
@synthesize client = _client;

UIViewController *sender;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [usernameField becomeFirstResponder];
	// Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)flag {
    [super viewWillAppear:flag];
    [usernameField becomeFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    [usernameField resignFirstResponder]; 
    if ([segue.identifier isEqualToString:@"returnToFollowing"]){
        TabBarController *dvc = [segue destinationViewController];
        [dvc setClient:_client];
        [dvc setNextViewToFollowing];
    }
    
}

- (IBAction)followButton:(id)sender {

    NSString * errorTitle;
    NSString * errorMesssage;
    if (![[usernameField text] isEqualToString:@""]) {
        
        if ([_client followUser:[usernameField text]]) {
            //invoke segue back to message list
            return [self performSegueWithIdentifier:@"returnToFollowing" sender:self];
        } else {
            errorTitle = @"Oops!";
            errorMesssage = @"There was a problem following that user - check the username!";
        }
        
    } else {
        errorTitle = @"Oops!";
        errorMesssage = @"The user field was empty.";
    }
    
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:errorTitle
                          message:errorMesssage
                          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    
}


@end
