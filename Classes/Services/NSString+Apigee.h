//
//  NSString+Apigee.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Apigee)

+ (NSString*) stringWithTimedContentsOfURL:(NSURL *) url encoding:(NSStringEncoding) enc error:(NSError **) error;
+ (NSString*) stringWithTimedContentsOfURL:(NSURL *) url usedEncoding:(NSStringEncoding *) enc error:(NSError **) error;

- (id) initWithTimedContentsOfURL:(NSURL *) url encoding:(NSStringEncoding) enc error:(NSError **) error;
- (id) initWithTimedContentsOfURL:(NSURL *) url usedEncoding:(NSStringEncoding *) enc error:(NSError **) error;
- (BOOL) timedWriteToURL:(NSURL *) url atomically:(BOOL) useAuxiliaryFile encoding:(NSStringEncoding) enc error:(NSError **) error;

// convenience methods
- (BOOL) containsString:(NSString *)substringToLookFor;

@end
