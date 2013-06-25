//
//  ApigeeUtils.h
//  ApigeeiOSSDK
//
//  Created by Paul Dardeau on 5/16/13.
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApigeeJsonUtils : NSObject

+ (NSString*)encode:(id)object;
+ (id)decode:(NSString*)json;

@end
