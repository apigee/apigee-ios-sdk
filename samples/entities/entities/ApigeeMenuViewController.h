//
//  ApigeeMenuViewController.h
//  entities
//
//  Created by Alex Muramoto on 1/15/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApigeeApiCalls.h"

@interface ApigeeMenuViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *introText;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIButton *retrieveButton;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
- (void)activateButtons;
- (void)disableButtons;
@end
