//
//  RegisterViewController.m
//  Messagee
//
//  Created by Rod Simpson on 12/28/12.
//  Copyright (c) 2012 Rod Simpson. All rights reserved.
//

#import "RegisterViewController.h"
#import "TabBarController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

@synthesize currentTextField;
@synthesize keyboardIsShown;
@synthesize scrollView;
@synthesize usernameField;
@synthesize nameField;
@synthesize emailField;
@synthesize passwordField;
@synthesize rePasswordField;
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

- (void)viewDidLoad
{    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [super viewWillAppear:animated];
}

- (void)textFieldDidBeginEditing:(UITextField *)textFieldView {
    currentTextField = textFieldView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textFieldView {
    [textFieldView resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textFieldView {
    currentTextField = nil;
    [textFieldView resignFirstResponder];
}

- (void)keyboardDidShow:(NSNotification *) notification {
    if (keyboardIsShown) return;
    NSDictionary* info = [notification userInfo];
    
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    
    CGRect viewFrame = [scrollView frame];
    viewFrame.size.height -= keyboardRect.size.height;
    scrollView.frame = viewFrame;
    
    CGRect textFieldRect = [currentTextField frame];
    [scrollView scrollRectToVisible:textFieldRect animated:YES];
    keyboardIsShown = YES;
}

- (void)keyboardDidHide:(NSNotification *) notification {
    NSDictionary* info = [notification userInfo];
    
    NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    
    CGRect viewFrame = [scrollView frame];
    viewFrame.size.height += keyboardRect.size.height;
    
    scrollView.frame = viewFrame;
    keyboardIsShown = NO;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"regsiterSuccessSeque"]){
        TabBarController *dvc = [segue destinationViewController];
        [dvc setClient:_client];
    }
    
}

- (IBAction)registerButton:(id)sender {
    //get the username and password from the text fields
    NSString *username = [usernameField text];
    NSString *name = [nameField text];
    NSString *email = [emailField text];
    NSString *password = [passwordField text];
    NSString *rePassword = [rePasswordField text];
    
    if (![password isEqualToString:rePassword]) {
        //pop an alert saying the login failed
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password error." message:@"The passwords do not match?" delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
        [alert show];
    } else {
        if ([_client createUser:username
                      withName:name
                     withEmail:email
                  withPassword:password]){
            [self performSegueWithIdentifier:@"regsiterSuccessSeque" sender:_client];
        } else {
            //pop an alert saying the login failed
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account not created?" message:@"Did you type your username and password correctly?" delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
            [alert show];
        }
    }
}

@end
