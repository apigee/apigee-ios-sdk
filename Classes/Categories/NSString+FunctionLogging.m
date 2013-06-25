//
//  NSString+FunctionLogging.m
//  ApigeeiOSSDK
//
//  Created by jaminschubert on 10/14/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "NSString+FunctionLogging.h"

@implementation NSString (FunctionLogging)

- (BOOL) isBlock
{
    //NSRange range = [self rangeOfString:@"block_invoke"];
    return NO;
}

-(NSString *) actualFunction
{
    if (![self isBlock])
        return self;
    
    return @"";
}

@end
