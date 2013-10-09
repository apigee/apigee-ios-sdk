//
//  ApigeeLogCompiler.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeActiveSettings.h"

@interface ApigeeLogCompiler : NSObject

+ (ApigeeLogCompiler *) systemCompiler;
+ (void) refreshUploadTimestamp;
+ (void) refreshUploadTimestamp:(NSDate*)lastLogTransmissionDate;
- (NSArray *) compileLogsForSettings:(ApigeeActiveSettings *) settings
                   autoPromoteErrors:(BOOL)autoPromoteErrors;

@end
