//
//  ApigeeResultViewController.h
//  entities
//
//  Created by Alex Muramoto on 1/15/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApigeeApiCalls.h"

@interface ApigeeResultViewController : UIViewController
@property NSString *action;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@end
