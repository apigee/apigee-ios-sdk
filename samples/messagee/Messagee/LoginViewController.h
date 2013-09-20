//
//  LoginViewController.h
//  Messagee
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) Client *client;

- (IBAction)registerButton:(id)sender;
- (IBAction)loginButton:(id)sender;

@end
