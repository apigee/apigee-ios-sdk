//
//  NSData+Apigee.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Apigee)

+ (NSData*) timedDataWithContentsOfURL:(NSURL *) url options:(NSDataReadingOptions) readOptionsMask error:(NSError **) errorPtr;
+ (NSData*) timedDataWithContentsOfURL:(NSURL *) url;

- (NSData*) initWithTimedContentsOfURL:(NSURL *) url options:(NSDataReadingOptions) readOptionsMask error:(NSError **) errorPtr;
- (NSData*) initWithTimedContentsOfURL:(NSURL *) url;

- (BOOL) timedWriteToURL:(NSURL *) url atomically:(BOOL) atomically;
- (BOOL) timedWriteToURL:(NSURL *) url options:(NSDataWritingOptions) writeOptionsMask error:(NSError **) errorPtr;

@end
