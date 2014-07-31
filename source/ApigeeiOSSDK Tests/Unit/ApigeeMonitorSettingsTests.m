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

@property (nonatomic,strong) ApigeeCompositeConfiguration* compositeConfiguration;

@end

@implementation ApigeeMonitorSettingsTests

-(BOOL)continueAfterFailure {
    return NO;
}

- (void)setUp {
    [super setUp];

    NSString* configPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"SampleData/apigeeMobileConfigSample.json" ofType:nil];

    NSData* configData = [NSData dataWithContentsOfFile:configPath];
    NSString* configJSONString = [[NSString alloc] initWithData:configData
                                                       encoding:NSUTF8StringEncoding];

    NSError* error = nil;
    self.compositeConfiguration = [ApigeeCachedConfigUtil parseConfiguration:configJSONString error:&error];
}

- (void)tearDown {
    self.compositeConfiguration = nil;
    [super tearDown];
}

- (void)test_sampleDefaultLevelSettings {

    XCTAssertNotNil([self compositeConfiguration], @"compositeConfiguration should not be nil.");

    ApigeeMonitorSettings* defaultSettings = [[self compositeConfiguration] defaultSettings];
    XCTAssertNotNil(defaultSettings, @"defaultSettings should not be nil.");
    XCTAssertEqualObjects([defaultSettings appConfigType], @"Default", @"appConfigType should be Default.");

    XCTAssertEqual([defaultSettings appConfigId], 0, @"appConfigId should be 0.");
    XCTAssertNil([defaultSettings description], @"description should be nil.");
    XCTAssertNil([defaultSettings lastModifiedDate], @"lastModifiedDate should be nil.");

    XCTAssertTrue([defaultSettings batteryStatusCaptureEnabled], @"batteryStatusCaptureEnabled should be true.");
    XCTAssertTrue([defaultSettings deviceIdCaptureEnabled], @"deviceIdCaptureEnabled should be true.");
    XCTAssertTrue([defaultSettings deviceModelCaptureEnabled], @"deviceModelCaptureEnabled should be true.");
    XCTAssertTrue([defaultSettings enableLogMonitoring], @"enableLogMonitoring should be true.");
    XCTAssertTrue([defaultSettings enableUploadWhenMobile], @"enableUploadWhenMobile should be true.");
    XCTAssertTrue([defaultSettings imeicaptureEnabled], @"imeicaptureEnabled should be true.");
    XCTAssertTrue([defaultSettings monitorAllUrls], @"monitorAllUrls should be true.");
    XCTAssertTrue([defaultSettings networkCarrierCaptureEnabled], @"networkCarrierCaptureEnabled should be true.");
    XCTAssertTrue([defaultSettings networkMonitoringEnabled], @"networkMonitoringEnabled should be true.");
    XCTAssertTrue([defaultSettings obfuscateDeviceId], @"obfuscateDeviceId should be true.");
    XCTAssertTrue([defaultSettings obfuscateIMEI], @"obfuscateIMEI should be true.");
    XCTAssertTrue([defaultSettings sessionDataCaptureEnabled], @"sessionDataCaptureEnabled should be true.");

    XCTAssertFalse([defaultSettings cachingEnabled], @"cachingEnabled should be false.");
    XCTAssertFalse([defaultSettings enableUploadWhenRoaming], @"enableUploadWhenRoaming should be false.");
    XCTAssertFalse([defaultSettings locationCaptureEnabled], @"locationCaptureEnabled should be false.");

    XCTAssertEqual([defaultSettings agentUploadIntervalInSeconds], 60, @"agentUploadIntervalInSeconds should be 60");
    XCTAssertEqual([defaultSettings locationCaptureResolution], 1, @"locationCaptureResolution should be 1");
    XCTAssertEqual([defaultSettings logLevelToMonitor], 3, @"logLevelToMonitor should be 3");
    XCTAssertEqual([defaultSettings samplingRate], 100, @"samplingRate should be 100");

    XCTAssertEqual([[defaultSettings urlRegex] count], 0, @"urlRegex should have 0 count.");
    XCTAssertEqual([[defaultSettings customConfigParams] count], 0, @"customConfigParams should have 0 count.");
}

- (void)test_sampleDeviceLevelSettings {

    XCTAssertNotNil([self compositeConfiguration], @"compositeConfiguration should not be nil.");

    ApigeeMonitorSettings* deviceLevelSettings = [[self compositeConfiguration] deviceLevelSettings];
    XCTAssertNotNil(deviceLevelSettings, @"deviceLevelSettings should not be nil.");
    XCTAssertEqualObjects([deviceLevelSettings appConfigType], @"Beta", @"appConfigType should be Beta.");

    XCTAssertEqual([deviceLevelSettings appConfigId], 0, @"appConfigId should be 0.");
    XCTAssertNil([deviceLevelSettings description], @"description should be nil.");
    XCTAssertNil([deviceLevelSettings lastModifiedDate], @"lastModifiedDate should be nil.");

    XCTAssertTrue([deviceLevelSettings batteryStatusCaptureEnabled], @"batteryStatusCaptureEnabled should be true.");
    XCTAssertTrue([deviceLevelSettings deviceIdCaptureEnabled], @"deviceIdCaptureEnabled should be true.");
    XCTAssertTrue([deviceLevelSettings deviceModelCaptureEnabled], @"deviceModelCaptureEnabled should be true.");
    XCTAssertTrue([deviceLevelSettings enableLogMonitoring], @"enableLogMonitoring should be true.");
    XCTAssertTrue([deviceLevelSettings enableUploadWhenMobile], @"enableUploadWhenMobile should be true.");
    XCTAssertTrue([deviceLevelSettings imeicaptureEnabled], @"imeicaptureEnabled should be true.");
    XCTAssertTrue([deviceLevelSettings monitorAllUrls], @"monitorAllUrls should be true.");
    XCTAssertTrue([deviceLevelSettings networkCarrierCaptureEnabled], @"networkCarrierCaptureEnabled should be true.");
    XCTAssertTrue([deviceLevelSettings networkMonitoringEnabled], @"networkMonitoringEnabled should be true.");
    XCTAssertTrue([deviceLevelSettings obfuscateDeviceId], @"obfuscateDeviceId should be true.");
    XCTAssertTrue([deviceLevelSettings obfuscateIMEI], @"obfuscateIMEI should be true.");
    XCTAssertTrue([deviceLevelSettings sessionDataCaptureEnabled], @"sessionDataCaptureEnabled should be true.");

    XCTAssertFalse([deviceLevelSettings cachingEnabled], @"cachingEnabled should be false.");
    XCTAssertFalse([deviceLevelSettings enableUploadWhenRoaming], @"enableUploadWhenRoaming should be false.");
    XCTAssertFalse([deviceLevelSettings locationCaptureEnabled], @"locationCaptureEnabled should be false.");

    XCTAssertEqual([deviceLevelSettings agentUploadIntervalInSeconds], 60, @"agentUploadIntervalInSeconds should be 60");
    XCTAssertEqual([deviceLevelSettings locationCaptureResolution], 1, @"locationCaptureResolution should be 1");
    XCTAssertEqual([deviceLevelSettings logLevelToMonitor], 3, @"logLevelToMonitor should be 3");
    XCTAssertEqual([deviceLevelSettings samplingRate], 100, @"samplingRate should be 100");

    XCTAssertEqual([[deviceLevelSettings urlRegex] count], 0, @"deviceLevelSettings should have 0 count.");
    XCTAssertEqual([[deviceLevelSettings customConfigParams] count], 0, @"customConfigParams should have 0 count.");
}

- (void)test_sampleDeviceTypeSettings {

    XCTAssertNotNil([self compositeConfiguration], @"compositeConfiguration should not be nil.");

    ApigeeMonitorSettings* deviceTypeSettings = [[self compositeConfiguration] deviceTypeSettings];
    XCTAssertNotNil(deviceTypeSettings, @"deviceTypeSettings should not be nil.");
    XCTAssertEqualObjects([deviceTypeSettings appConfigType], @"Device", @"appConfigType should be Device.");

    XCTAssertEqual([deviceTypeSettings appConfigId], 0, @"appConfigId should be 0.");
    XCTAssertNil([deviceTypeSettings description], @"description should be nil.");
    XCTAssertNil([deviceTypeSettings lastModifiedDate], @"lastModifiedDate should be nil.");

    XCTAssertTrue([deviceTypeSettings batteryStatusCaptureEnabled], @"batteryStatusCaptureEnabled should be true.");
    XCTAssertTrue([deviceTypeSettings deviceIdCaptureEnabled], @"deviceIdCaptureEnabled should be true.");
    XCTAssertTrue([deviceTypeSettings deviceModelCaptureEnabled], @"deviceModelCaptureEnabled should be true.");
    XCTAssertTrue([deviceTypeSettings enableLogMonitoring], @"enableLogMonitoring should be true.");
    XCTAssertTrue([deviceTypeSettings enableUploadWhenMobile], @"enableUploadWhenMobile should be true.");
    XCTAssertTrue([deviceTypeSettings imeicaptureEnabled], @"imeicaptureEnabled should be true.");
    XCTAssertTrue([deviceTypeSettings monitorAllUrls], @"monitorAllUrls should be true.");
    XCTAssertTrue([deviceTypeSettings networkCarrierCaptureEnabled], @"networkCarrierCaptureEnabled should be true.");
    XCTAssertTrue([deviceTypeSettings networkMonitoringEnabled], @"networkMonitoringEnabled should be true.");
    XCTAssertTrue([deviceTypeSettings obfuscateDeviceId], @"obfuscateDeviceId should be true.");
    XCTAssertTrue([deviceTypeSettings obfuscateIMEI], @"obfuscateIMEI should be true.");
    XCTAssertTrue([deviceTypeSettings sessionDataCaptureEnabled], @"sessionDataCaptureEnabled should be true.");

    XCTAssertFalse([deviceTypeSettings cachingEnabled], @"cachingEnabled should be false.");
    XCTAssertFalse([deviceTypeSettings enableUploadWhenRoaming], @"enableUploadWhenRoaming should be false.");
    XCTAssertFalse([deviceTypeSettings locationCaptureEnabled], @"locationCaptureEnabled should be false.");

    XCTAssertEqual([deviceTypeSettings agentUploadIntervalInSeconds], 60, @"agentUploadIntervalInSeconds should be 60");
    XCTAssertEqual([deviceTypeSettings locationCaptureResolution], 1, @"locationCaptureResolution should be 1");
    XCTAssertEqual([deviceTypeSettings logLevelToMonitor], 3, @"logLevelToMonitor should be 3");
    XCTAssertEqual([deviceTypeSettings samplingRate], 100, @"samplingRate should be 100");

    XCTAssertEqual([[deviceTypeSettings urlRegex] count], 0, @"deviceLevelSettings should have 0 count.");
    XCTAssertEqual([[deviceTypeSettings customConfigParams] count], 0, @"customConfigParams should have 0 count.");
}

- (void)test_sampleABTestingSettings {

    XCTAssertNotNil([self compositeConfiguration], @"compositeConfiguration should not be nil.");

    ApigeeMonitorSettings* abTestingSettings = [[self compositeConfiguration] abTestingSettings];
    XCTAssertNotNil(abTestingSettings, @"abTestingSettings should not be nil.");
    XCTAssertEqualObjects([abTestingSettings appConfigType], @"A/B", @"appConfigType should be A/B.");

    XCTAssertEqual([abTestingSettings appConfigId], 0, @"appConfigId should be 0.");
    XCTAssertNil([abTestingSettings description], @"description should be nil.");
    XCTAssertNil([abTestingSettings lastModifiedDate], @"lastModifiedDate should be nil.");

    XCTAssertTrue([abTestingSettings batteryStatusCaptureEnabled], @"batteryStatusCaptureEnabled should be true.");
    XCTAssertTrue([abTestingSettings deviceIdCaptureEnabled], @"deviceIdCaptureEnabled should be true.");
    XCTAssertTrue([abTestingSettings deviceModelCaptureEnabled], @"deviceModelCaptureEnabled should be true.");
    XCTAssertTrue([abTestingSettings enableLogMonitoring], @"enableLogMonitoring should be true.");
    XCTAssertTrue([abTestingSettings enableUploadWhenMobile], @"enableUploadWhenMobile should be true.");
    XCTAssertTrue([abTestingSettings imeicaptureEnabled], @"imeicaptureEnabled should be true.");
    XCTAssertTrue([abTestingSettings monitorAllUrls], @"monitorAllUrls should be true.");
    XCTAssertTrue([abTestingSettings networkCarrierCaptureEnabled], @"networkCarrierCaptureEnabled should be true.");
    XCTAssertTrue([abTestingSettings networkMonitoringEnabled], @"networkMonitoringEnabled should be true.");
    XCTAssertTrue([abTestingSettings obfuscateDeviceId], @"obfuscateDeviceId should be true.");
    XCTAssertTrue([abTestingSettings obfuscateIMEI], @"obfuscateIMEI should be true.");
    XCTAssertTrue([abTestingSettings sessionDataCaptureEnabled], @"sessionDataCaptureEnabled should be true.");

    XCTAssertFalse([abTestingSettings cachingEnabled], @"cachingEnabled should be false.");
    XCTAssertFalse([abTestingSettings enableUploadWhenRoaming], @"enableUploadWhenRoaming should be false.");
    XCTAssertFalse([abTestingSettings locationCaptureEnabled], @"locationCaptureEnabled should be false.");

    XCTAssertEqual([abTestingSettings agentUploadIntervalInSeconds], 60, @"agentUploadIntervalInSeconds should be 60");
    XCTAssertEqual([abTestingSettings locationCaptureResolution], 1, @"locationCaptureResolution should be 1");
    XCTAssertEqual([abTestingSettings logLevelToMonitor], 3, @"logLevelToMonitor should be 3");
    XCTAssertEqual([abTestingSettings samplingRate], 100, @"samplingRate should be 100");

    XCTAssertEqual([[abTestingSettings urlRegex] count], 0, @"deviceLevelSettings should have 0 count.");
    XCTAssertEqual([[abTestingSettings customConfigParams] count], 0, @"customConfigParams should have 0 count.");
}

@end
