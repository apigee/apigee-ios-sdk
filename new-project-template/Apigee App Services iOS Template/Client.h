//
//  Client.h
//  Apigee App Services iOS Template
//
//  Created by Tim Anglade on 2/22/13.
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ApigeeiOSSDK/ApigeeDataClient.h>


@interface Client : NSObject

@property (nonatomic, strong) ApigeeDataClient *usergridClient;

-(NSString*)postBook;



@end
