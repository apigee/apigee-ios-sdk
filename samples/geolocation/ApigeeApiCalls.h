//
//  ApigeeApiCalls.h
//  geolocation
//
//  Created by Alex Muramoto on 2/6/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ApigeeiOSSDK/Apigee.h>

@interface ApigeeApiCalls : NSObject
-(void) initializeSDK:(NSString*)orgInput;
-(NSDictionary*) startRequest:(NSString*)requestType;
+(void)setLocation:(double)latitude longitude:(double)longitude;
@end
