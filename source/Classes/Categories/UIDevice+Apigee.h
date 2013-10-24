//
//  UIDevice+Apigee.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @internal
 */
@interface UIDevice (Apigee)

+ (NSString *) platformStringRaw;
+ (NSString *) platformStringDescriptive;

@end
