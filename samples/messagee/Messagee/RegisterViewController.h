//
//  RegisterViewController.h
//  Messagee
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client.h"

@interface RegisterViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) Client *client;
@property (nonatomic, strong) UITextField *currentTextField;
@property BOOL keyboardIsShown;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordField;

- (IBAction)registerButton:(id)sender;

@end
