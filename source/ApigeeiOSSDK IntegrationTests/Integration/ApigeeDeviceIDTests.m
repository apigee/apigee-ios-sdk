//
//  ApigeeDeviceIDTests.m
//  ApigeeiOSSDK
//
//  Created by Robert Walsh on 12/15/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Apigee.h"
#import "ApigeeIntegrationTestsConstants.h"
#import "ApigeeSessionMetricsCompiler.h"

@interface ApigeeDeviceIDTests : XCTestCase

@end

@implementation ApigeeDeviceIDTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testMonitoringDeviceID {

    ApigeeClient* apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:kAPIOrgName
                                                                applicationId:kAPIAppID];

    ApigeeMonitoringClient* monitoringClient = [apigeeClient monitoringClient];

    NSString* dataClientDeviceID = [ApigeeDataClient getUniqueDeviceID];

    XCTAssertNotNil(dataClientDeviceID,@"[ApigeeDataClient getUniqueDeviceID] should never return nil");

    NSString* monitoringClientDeviceID = [monitoringClient apigeeDeviceId];

    XCTAssertEqualObjects(dataClientDeviceID, monitoringClientDeviceID,@"dataClientDeviceID and monitoringClientDeviceID should be equal.");
}

- (void)testMetricsDeviceID {

    ApigeeClient* apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:kAPIOrgName
                                                                applicationId:kAPIAppID];

    ApigeeMonitoringClient* monitoringClient = [apigeeClient monitoringClient];

    NSString* dataClientDeviceID = [ApigeeDataClient getUniqueDeviceID];

    XCTAssertNotNil(dataClientDeviceID,@"[ApigeeDataClient getUniqueDeviceID] should never return nil");

    ApigeeSessionMetrics *sessionMetrics = [[ApigeeSessionMetricsCompiler systemCompiler] compileMetricsForSettings:[monitoringClient activeSettings] isWiFi:YES];

    NSString* sessionMetricsDeviceID = [sessionMetrics deviceId];

    XCTAssertEqualObjects(dataClientDeviceID, sessionMetricsDeviceID,@"dataClientDeviceID and sessionMetricsDeviceID should be equal.");
}

- (void)testDeviceIDRequestHeader {

    ApigeeClient* apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:kAPIOrgName
                                                                applicationId:kAPIAppID];

    ApigeeMonitoringClient* monitoringClient = [apigeeClient monitoringClient];

    NSString* dataClientDeviceID = [ApigeeDataClient getUniqueDeviceID];

    XCTAssertNotNil(dataClientDeviceID,@"[ApigeeDataClient getUniqueDeviceID] should never return nil");

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
    [monitoringClient injectApigeeHttpHeaders:request];

    NSString* requestDeviceID = [request valueForHTTPHeaderField:@"X-Apigee-Device-Id"];

    XCTAssertEqualObjects(dataClientDeviceID, requestDeviceID,@"dataClientDeviceID and requestDeviceID should be equal.");
}

@end
