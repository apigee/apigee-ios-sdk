//
//  APGNewBookViewController.h
//  Books
//
//  Created by Matthew Dobson on 6/13/13.
//  Copyright (c) 2013 Matthew Dobson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APGMasterViewController.h"

@interface APGNewBookViewController : UIViewController

@property (nonatomic, weak) id<MasterViewDelegate> delegate;

@property (nonatomic, retain) IBOutlet UITextField *bookTitleText;
@property (nonatomic, retain) IBOutlet UITextField *bookAuthorText;

@end
