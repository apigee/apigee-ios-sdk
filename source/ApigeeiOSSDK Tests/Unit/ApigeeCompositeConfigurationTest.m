//
//  ApigeeCompositeConfigurationTest.m
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
#import "NSDate+Apigee.h"

@interface ApigeeCompositeConfigurationTest : XCTestCase

@end

@implementation ApigeeCompositeConfigurationTest

-(BOOL)continueAfterFailure {
    return NO;
}

- (void)test_sample {

    NSString* configPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"SampleData/apigeeMobileConfigSample.json" ofType:nil];

    XCTAssertTrue([configPath length] > 0, @"config path should not have 0 length.");

    NSData* configData = [NSData dataWithContentsOfFile:configPath];
    NSString* configJSONString = [[NSString alloc] initWithData:configData
                                                       encoding:NSUTF8StringEncoding];

    XCTAssertTrue([configJSONString length] > 0, @"config path should not have 0 length.");

    NSError* error = nil;
    ApigeeCompositeConfiguration* compositeConfiguration = [ApigeeCachedConfigUtil parseConfiguration:configJSONString error:&error];

    XCTAssertNil(error, @"Error creating compositeConfiguration should be nil.  Description: %@.", [error description]);
    XCTAssertNotNil(compositeConfiguration, @"compositeConfiguration should not be nil.");

    XCTAssertEqualObjects([compositeConfiguration createdDate], [NSDate dateFromMilliseconds:1403562108260], @"createdDate is not equal.");
    XCTAssertEqualObjects([compositeConfiguration lastModifiedDate], [NSDate dateFromMilliseconds:1403562108260], @"lastModifiedDate is not equal.");

    XCTAssertEqualObjects([compositeConfiguration instaOpsApplicationId], [NSNumber numberWithInt:21493], @"instaOpsApplicationId is not correct");
    XCTAssertEqualObjects([compositeConfiguration orgName], @"rwalsh", @"orgName is not correct.");
    XCTAssertEqualObjects([compositeConfiguration appName], @"sdk.demo", @"appName is not correct.");
    XCTAssertEqualObjects([compositeConfiguration fullAppName], @"rwalsh_sdkdemo", @"fullAppName is not correct.");
    XCTAssertEqualObjects([compositeConfiguration appOwner], @"rwalsh@apigee.com", @"appOwner is not correct.");

    XCTAssertEqualObjects([compositeConfiguration googleId], [NSNull null], @"googleId should be null.");
    XCTAssertEqualObjects([compositeConfiguration appleId], [NSNull null], @"appleId should be null.");
    XCTAssertEqualObjects([compositeConfiguration description], [NSNull null], @"description should be null.");
    XCTAssertEqualObjects([compositeConfiguration environment], @"ug-max-prod", @"environment is not correct.");
    XCTAssertEqualObjects([compositeConfiguration customUploadUrl], [NSNull null], @"customUploadUrl should be null.");

    XCTAssertFalse([compositeConfiguration monitoringDisabled], @"monitoringDisabled should be false.");
    XCTAssertFalse([compositeConfiguration deleted], @"deleted should be false.");
    XCTAssertFalse([compositeConfiguration deviceLevelOverrideEnabled], @"deviceLevelOverrideEnabled should be false.");
    XCTAssertFalse([compositeConfiguration deviceTypeOverrideEnabled], @"deviceTypeOverrideEnabled should be false.");
    XCTAssertFalse([compositeConfiguration ABTestingOverrideEnabled], @"ABTestingOverrideEnabled should be false.");

    XCTAssertNotNil([compositeConfiguration defaultSettings], @"defaultSettings should not be nil");
    XCTAssertNotNil([compositeConfiguration deviceTypeSettings], @"deviceTypeSettings should not be nil");
    XCTAssertNotNil([compositeConfiguration deviceLevelSettings], @"deviceLevelSettings should not be nil");
    XCTAssertNotNil([compositeConfiguration abTestingSettings], @"abTestingSettings should not be nil");

    XCTAssertEqualObjects([compositeConfiguration abtestingPercentage], [NSNumber numberWithInt:0], @"abtestingPercentage is not equal.");

    XCTAssertEqual([[compositeConfiguration appConfigOverrideFilters] count], 0, @"appConfigOverrideFilters should have 0 filters.");
    XCTAssertEqual([[compositeConfiguration deviceNumberFilters] count], 0, @"deviceNumberFilters should have 0 filters.");
    XCTAssertEqual([[compositeConfiguration deviceIdFilters] count], 0, @"deviceIdFilters should have 0 filters.");
    XCTAssertEqual([[compositeConfiguration deviceModelRegexFilters] count], 0, @"deviceModelRegexFilters should have 0 filters.");
    XCTAssertEqual([[compositeConfiguration devicePlatformRegexFilters] count], 0, @"devicePlatformRegexFilters should have 0 filters.");
    XCTAssertEqual([[compositeConfiguration networkTypeRegexFilters] count], 0, @"networkTypeRegexFilters should have 0 filters.");
    XCTAssertEqual([[compositeConfiguration networkOperatorRegexFilters] count], 0, @"networkOperatorRegexFilters should have 0 filters.");
}

@end
