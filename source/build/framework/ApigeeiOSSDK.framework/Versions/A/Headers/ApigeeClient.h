//
//  ApigeeClient.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApigeeDataClient;
@class ApigeeMonitoringClient;
@class ApigeeAppIdentification;
@class ApigeeMonitoringOptions;

@interface ApigeeClient : NSObject
{
    ApigeeDataClient* _dataClient;
    ApigeeMonitoringClient* _monitoringClient;
    ApigeeAppIdentification* _appIdentification;
    NSString* _loggedInUser;
}

- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId;

- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId
                     baseURL:(NSString*)baseURL;

- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId
                     options:(ApigeeMonitoringOptions*)monitoringOptions;

- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId
                     baseURL:(NSString*)baseURL
                     options:(ApigeeMonitoringOptions*)monitoringOptions;


- (ApigeeDataClient*)dataClient;
- (ApigeeMonitoringClient*)monitoringClient;
- (ApigeeAppIdentification*)appIdentification;
- (NSString*)loggedInUser;

+ (NSString*)sdkVersion;

@end
