//
//  APGNewBookViewController.h
//  Books
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APGMasterViewController.h"

@interface APGNewBookViewController : UIViewController

@property (nonatomic, weak) id<MasterViewDelegate> delegate;

@property (nonatomic, retain) IBOutlet UITextField *bookTitleText;
@property (nonatomic, retain) IBOutlet UITextField *bookAuthorText;

@end
