//
//  NSString+FunctionLogging.h
//  InstaOpsAppMonitor
//
//  Created by jaminschubert on 10/14/12.
//  Copyright (c) 2012 InstaOps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FunctionLogging)

- (BOOL) isBlock;
- (NSString *) actualFunction;

@end
