//
//  ApigeeCustomConfigParam.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApigeeCustomConfigParam : NSObject

@property (assign, nonatomic) NSInteger paramId;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *value;

@end
