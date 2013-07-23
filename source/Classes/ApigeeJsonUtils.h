//
//  ApigeeUtils.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApigeeJsonUtils : NSObject

+ (NSString*)encode:(id)object;
+ (id)decode:(NSString*)json;

@end
