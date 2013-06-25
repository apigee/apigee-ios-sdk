//
//  UIDevice+Apigee.h
//  ApigeeAppMonitor
//
//  Created by Paul Dardeau on 11/19/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Apigee)

+ (NSString *) platformStringRaw;
+ (NSString *) platformStringDescriptive;

@end
