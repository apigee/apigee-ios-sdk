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
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *retrieveButton;
@property (weak, nonatomic) IBOutlet UIButton *pageButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@end
