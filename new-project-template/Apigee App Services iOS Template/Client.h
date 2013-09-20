//
//  Client.h
//  Apigee App Services iOS Template
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApigeeDataClient;


@interface Client : NSObject

@property (nonatomic, strong) ApigeeDataClient *usergridClient;

-(NSString*)postBook;



@end
