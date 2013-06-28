//
//  ApigeeDefaultiOSLog.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApigeeLogger.h"

@interface ApigeeDefaultiOSLog : NSObject <ApigeeLogger>

- (void)verbose:(NSString*)tag message:(NSString*)msg;
- (void)verbose:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;
- (void)verbose:(NSString*)tag message:(NSString*)msg error:(NSError*)e;

- (void)debug:(NSString*)tag message:(NSString*)msg;
- (void)debug:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;
- (void)debug:(NSString*)tag message:(NSString*)msg error:(NSError*)e;

- (void)info:(NSString*)tag message:(NSString*)msg;
- (void)info:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;
- (void)info:(NSString*)tag message:(NSString*)msg error:(NSError*)e;

- (void)warn:(NSString*)tag message:(NSString*)msg;
- (void)warn:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;
- (void)warn:(NSString*)tag message:(NSString*)msg error:(NSError*)e;

- (void)error:(NSString*)tag message:(NSString*)msg;
- (void)error:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;
- (void)error:(NSString*)tag message:(NSString*)msg error:(NSError*)e;

- (void)assert:(NSString*)tag message:(NSString*)msg;
- (void)assert:(NSString*)tag message:(NSString*)msg exception:(NSException*)e;
- (void)assert:(NSString*)tag message:(NSString*)msg error:(NSError*)e;

@end
