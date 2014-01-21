//
//  ApigeeCounterIncrement.h
//  ApigeeiOSSDK
//
//  Created by Paul Dardeau on 1/16/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApigeeCounterIncrement : NSObject

@property (strong, nonatomic) NSString* counterName;
@property (assign, nonatomic) NSUInteger counterIncrementValue;

- (id)initWithName:(NSString*)theCounterName
    incrementValue:(NSUInteger)theCounterIncrementValue;

@end
