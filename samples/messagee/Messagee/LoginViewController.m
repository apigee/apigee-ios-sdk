//
//  LoginViewController.m
//  Messagee
//
//  Created by Rod Simpson on 12/27/12.
//  Copyright (c) 2012 Rod Simpson. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "TabBarController.h"

static NSString *kSegueLogin = @"loginSeque";
static NSString *kSegueRegister = @"registerSeque";

@implementation LoginViewController

@synthesize client = _client;


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
   
    if ([segue.identifier isEqualToString:kSegueLogin]){
        TabBarController *dvc = [segue destinationViewController];
        [dvc setClient:_client];
    }
    else if ([segue.identifier isEqualToString:kSegueRegister]){
        RegisterViewController *dvc = [segue destinationViewController];
        [dvc setClient:_client];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _client = [[Client alloc] init];
}

- (IBAction)registerButton:(id)sender {
    [self performSegueWithIdentifier:kSegueRegister
                              sender:_client];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textFieldView {
    [textFieldView resignFirstResponder];
    return YES;
}

- (void)loginSuccess {
    [self performSegueWithIdentifier:kSegueLogin
                              sender:self];
}

- (void)loginFailure {
    //pop an alert saying the login failed
    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Login Failed?"
                                   message:@"Did you type your username and password correctly?"
                                  delegate:self
                         cancelButtonTitle:@"Try Again"
                         otherButtonTitles:nil];
    [alert show];
}

- (IBAction)loginButton:(id)sender {

    //get the username and password from the text fields
    NSString *username = [_usernameField text];
    NSString *password = [_passwordField text];
    
    if (([username length] > 0) && ([password length] > 0)) {
        
        // attempt the user login on a background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,NULL),
                       ^(void) {
                           if ([_client login:username withPassword:password]){
                               [self performSelectorOnMainThread:@selector(loginSuccess)
                                                      withObject:nil
                                                   waitUntilDone:NO];
                           } else {
                               [self performSelectorOnMainThread:@selector(loginFailure)
                                                      withObject:nil
                                                   waitUntilDone:NO];
                           }
                       });
    } else {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Missing Credentials"
                                   message:@"Username and/or Password is missing"
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
    }
}

@end
