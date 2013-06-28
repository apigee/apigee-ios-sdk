//
//  NSString+FunctionLogging.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FunctionLogging)

- (BOOL) isBlock;
- (NSString *) actualFunction;

@end
