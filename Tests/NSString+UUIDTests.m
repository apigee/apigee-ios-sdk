//
//  NSString+UUIDTests.m
//  InstaOpsAppMonitor
//
//  Created by jaminschubert on 10/13/12.
//  Copyright (c) 2012 InstaOps. All rights reserved.
//

#import "NSString+UUID.h"

@interface NSString_UUIDTests : GHTestCase

@end

@implementation NSString_UUIDTests

- (void) testGenerateUUIDAsString
{
    NSString *uuid = [NSString uuid];
    
    GHAssertNotNil(uuid, @"The generated uuid was nil");
    GHAssertEquals(36U, [uuid length], @"The generated uuid had a length of %d", [uuid length]);
}

@end
