//
//  ApigeeCachedConfigUtil.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

@class ApigeeCompositeConfiguration;

#define kApigeeGetConfiguationFailed 100
#define kApigeeUpdateConfiguationFailed 101


@interface ApigeeCachedConfigUtil : NSObject

+ (NSString*)configFileName;
+ (BOOL) isCached;
+ (ApigeeCompositeConfiguration *) getConfiguration:(NSError **) error;
+ (BOOL) updateConfiguration:(NSData *) fileData error: (NSError **) error;

@end
