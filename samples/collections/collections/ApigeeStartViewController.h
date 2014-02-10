//
//  ApigeeStartViewController.h
//  entities
//
//  Created by Alex Muramoto on 1/15/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApigeeApiCalls.h"

@interface ApigeeStartViewController : UIViewController
@property NSString *orgInput;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
@end
