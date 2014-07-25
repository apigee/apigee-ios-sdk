//
//  ApigeeMonitorSettingsTests.m
//  ApigeeiOSSDK
//
//  Created by Robert Walsh on 7/24/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ApigeeCompositeConfiguration.h"
#import "ApigeeCachedConfigUtil.h"
#import "ApigeeCompositeConfiguration+JSON.h"

@interface ApigeeMonitorSettingsTests : XCTestCase

@end

@implementation ApigeeMonitorSettingsTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_sample {

    NSString* configPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"SampleTestData/apigeeMobileConfigSample.json" ofType:nil];

    XCTAssertTrue([configPath length] > 0, @"config path should not have 0 length.");

    NSData* configData = [NSData dataWithContentsOfFile:configPath];
    NSString* configJSONString = [[NSString alloc] initWithData:configData
                                                       encoding:NSUTF8StringEncoding];

    XCTAssertTrue([configJSONString length] > 0, @"config path should not have 0 length.");

    NSError* error = nil;
    ApigeeCompositeConfiguration* compositeConfiguration = [ApigeeCachedConfigUtil parseConfiguration:configJSONString error:&error];

    XCTAssertNil(error, @"Error creating compositeConfiguration should be nil.  Description: %@.", [error description]);
    XCTAssertNotNil(compositeConfiguration, @"compositeConfiguration should not be nil.");

    ApigeeMonitorSettings* deviceLevelSettings = [compositeConfiguration deviceLevelSettings];
    XCTAssertNotNil(deviceLevelSettings, @"deviceLevelSettings should not be nil.");

    XCTAssertEqual([deviceLevelSettings appConfigId], 0, @"appConfigId should be 0.");
    XCTAssertEqualObjects([deviceLevelSettings appConfigType], @"Beta", @"appConfigType should be Beta.");
    XCTAssertNil([deviceLevelSettings description], @"description should be nil.");
    XCTAssertEqualObjects([deviceLevelSettings lastModifiedDate], [NSNull null], @"lastModifiedDate should be null.");
}

@end
