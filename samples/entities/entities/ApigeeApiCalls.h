//
//  ApigeeApiCalls.h
//  entities
//
//  Created by Alex Muramoto on 1/15/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ApigeeiOSSDK/Apigee.h>
@interface ApigeeApiCalls : NSObject
    @property ApigeeDataClient *dataClient;
    @property NSString *action;
    -(void) initializeSDK:(NSString*)orgInput;
    -(NSString*) startRequest:(NSString*)requestType;
    +(NSString*) getCurrentEntity;
@end
