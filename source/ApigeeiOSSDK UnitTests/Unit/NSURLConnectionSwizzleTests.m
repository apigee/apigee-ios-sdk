//
//  NSURLConnectionSwizzleTests.m
//  ApigeeiOSSDK
//
//  Created by Robert Walsh on 11/26/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "NSURLConnection+Apigee.h"
#import "ApigeeNSURLConnectionDataDelegateInterceptor.h"

/*!
 @class NSURLConnectionSwizzleTests
 @abstract The NSURLConnectionSwizzleTests test case is used to test that the swizzling of NSURL connections are set up properly.
 */
@interface NSURLConnection (ApigeePrivateSwizzleMethods)

void NSURLConnection_apigeeSendAsynchronousRequestQueueCompletionHandler(id self,SEL _cmd,NSURLRequest* request,NSOperationQueue* queue,NSURLConnectionAsyncRequestCompletionHandler handler);
NSData* NSURLConnection_apigeeSendSynchronousRequestReturningResponseError(id self,SEL _cmd,NSURLRequest* request,NSURLResponse** response,NSError** error);
NSURLConnection* NSURLConnection_apigeeConnectionWithRequestDelegate(id self,SEL _cmd,NSURLRequest* request,id delegate);
id NSURLConnection_apigeeInitWithRequestDelegateStartImmediately(id self,SEL _cmd,NSURLRequest* request,id delegate,BOOL startImmediately);
id NSURLConnection_apigeeInitWithRequestDelegate(id self,SEL _cmd,NSURLRequest* request,id delegate);
void NSURLConnection_apigeeStart(id self,SEL _cmd);

@end

@interface NSURLConnectionSwizzleTests : XCTestCase

@end

@implementation NSURLConnectionSwizzleTests

/*!
 @abstract Tests the swizzling of the NSURLConnection class.
 */
- (void)testSwizzle {

    // Get the NSURLConnection methods that will be swizzled.
    Method sendSynchRequestReturningResponseErrorMethod = class_getClassMethod([NSURLConnection class],@selector(sendSynchronousRequest:returningResponse:error:));
    Method sendAsyncRequestQueueCompletionHandlerMethod = class_getClassMethod([NSURLConnection class],@selector(sendAsynchronousRequest:queue:completionHandler:));
    Method connectionWithRequestDelegateMethod = class_getClassMethod([NSURLConnection class],@selector(connectionWithRequest:delegate:));
    Method initWithRequestDelegateStartImmediatelyMethod = class_getInstanceMethod([NSURLConnection class],@selector(initWithRequest:delegate:startImmediately:));
    Method initWithRequestDelegateMethod = class_getInstanceMethod([NSURLConnection class],@selector(initWithRequest:delegate:));
    Method startMethod = class_getInstanceMethod([NSURLConnection class],@selector(start));

    // Get the original implementations of the methods
    IMP sendSynchRequestReturningResponseErrorOriginalIMP = method_getImplementation(sendSynchRequestReturningResponseErrorMethod);
    IMP sendAsyncRequestQueueCompletionHandlerOriginalIMP = method_getImplementation(sendAsyncRequestQueueCompletionHandlerMethod);
    IMP connectionWithRequestDelegateOriginalIMP = method_getImplementation(connectionWithRequestDelegateMethod);
    IMP initWithRequestDelegateStartImmediatelyOriginalIMP = method_getImplementation(initWithRequestDelegateStartImmediatelyMethod);
    IMP initWithRequestDelegateOriginalIMP = method_getImplementation(initWithRequestDelegateMethod);
    IMP startOriginalIMP = method_getImplementation(startMethod);

    // Get the override implementations of the methods
    IMP sendSynchRequestReturningResponseErrorOverrideIMP = (IMP)NSURLConnection_apigeeSendSynchronousRequestReturningResponseError;
    IMP sendAsyncRequestQueueCompletionHandlerOverrideIMP = (IMP)NSURLConnection_apigeeSendAsynchronousRequestQueueCompletionHandler;
    IMP connectionWithRequestDelegateOverrideIMP = (IMP)NSURLConnection_apigeeConnectionWithRequestDelegate;
    IMP initWithRequestDelegateStartImmediatelyOverrideIMP = (IMP)NSURLConnection_apigeeInitWithRequestDelegateStartImmediately;
    IMP initWithRequestDelegateOverrideIMP = (IMP)NSURLConnection_apigeeInitWithRequestDelegate;
    IMP startOverrideIMP = (IMP)NSURLConnection_apigeeStart;

    // Swizzle the methods and test to make sure it succeeded and doesn't do so more than once.
    BOOL methodsSwizzled = [NSURLConnection apigeeSwizzlingSetup];
    XCTAssertTrue(methodsSwizzled, @"apigeeSwizzlingSetup should have successfully swizzled.");

    // Get the now swizzled implementation of the methods.
    IMP sendSynchRequestReturningResponseErrorSwizzledIMP = method_getImplementation(sendSynchRequestReturningResponseErrorMethod);
    IMP sendAsyncRequestQueueCompletionHandlerSwizzledIMP = method_getImplementation(sendAsyncRequestQueueCompletionHandlerMethod);
    IMP connectionWithRequestDelegateSwizzledIMP = method_getImplementation(connectionWithRequestDelegateMethod);
    IMP initWithRequestDelegateStartImmediatelySwizzledIMP = method_getImplementation(initWithRequestDelegateStartImmediatelyMethod);
    IMP initWithRequestDelegateSwizzledIMP = method_getImplementation(initWithRequestDelegateMethod);
    IMP startSwizzledIMP = method_getImplementation(startMethod);

    // Assert that the original and the swizzled implementations are not equal.
    XCTAssertNotEqual(sendSynchRequestReturningResponseErrorOriginalIMP, sendSynchRequestReturningResponseErrorSwizzledIMP,@"sendSynchronousRequest:returningResponse:error: original and swizzled implementations should not be equal.");
    XCTAssertNotEqual(sendAsyncRequestQueueCompletionHandlerOriginalIMP, sendAsyncRequestQueueCompletionHandlerSwizzledIMP,@"sendAsynchronousRequest:queue:completionHandler: original and swizzled implementations should not be equal.");
    XCTAssertNotEqual(connectionWithRequestDelegateOriginalIMP, connectionWithRequestDelegateSwizzledIMP,@"connectionWithRequest:delegate: original and swizzled implementations should not be equal.");
    XCTAssertNotEqual(initWithRequestDelegateStartImmediatelyOriginalIMP, initWithRequestDelegateStartImmediatelySwizzledIMP,@"initWithRequest:delegate:startImmediately: original and swizzled implementations should not be equal.");
    XCTAssertNotEqual(initWithRequestDelegateOriginalIMP, initWithRequestDelegateSwizzledIMP,@"initWithRequest:delegate: original and swizzled implementations should not be equal.");
    XCTAssertNotEqual(startOriginalIMP, startSwizzledIMP,@"start original and swizzled implementations should not be equal.");

    // Assert that the override and the swizzled implementations are equal.
    XCTAssertEqual(sendSynchRequestReturningResponseErrorOverrideIMP, sendSynchRequestReturningResponseErrorSwizzledIMP,@"sendSynchronousRequest:returningResponse:error: override and swizzled implementations should be equal.");
    XCTAssertEqual(sendAsyncRequestQueueCompletionHandlerOverrideIMP, sendAsyncRequestQueueCompletionHandlerSwizzledIMP,@"sendAsynchronousRequest:queue:completionHandler: override and swizzled implementations should be equal.");
    XCTAssertEqual(connectionWithRequestDelegateOverrideIMP, connectionWithRequestDelegateSwizzledIMP,@"connectionWithRequest:delegate: override and swizzled implementations should be equal.");
    XCTAssertEqual(initWithRequestDelegateStartImmediatelyOverrideIMP, initWithRequestDelegateStartImmediatelySwizzledIMP,@"initWithRequest:delegate:startImmediately: override and swizzled implementations should be equal.");
    XCTAssertEqual(initWithRequestDelegateOverrideIMP, initWithRequestDelegateSwizzledIMP,@"initWithRequest:delegate: override and swizzled implementations should be equal.");
    XCTAssertEqual(startOverrideIMP, startSwizzledIMP,@"start override and swizzled implementations should be equal.");
}

@end
