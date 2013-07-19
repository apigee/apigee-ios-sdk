//
//  ApigeeMonitoringClient.h
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeActiveSettings.h"
#import "ApigeeUploadListener.h"

@class ApigeeAppIdentification;
@class ApigeeDataClient;
@class ApigeeMonitoringOptions;


@interface ApigeeMonitoringClient : NSObject

@property (strong,readonly) NSString *apigeeDeviceId;

@property (strong, nonatomic) ApigeeActiveSettings *activeSettings;

+ (NSString*)sdkVersion;



/**
 Returns the shared instance of ApigeeMonitoringClient. This method is
 provided as a convenience method. Ideally, your app delegate should
 maintain a reference to the single instance of ApigeeMonitoringClient.
 
 @return instance of ApigeeMonitoringClient
 */
+ (id)sharedInstance;

/**
 Initializes ApigeeMonitoringClient which controls the Apigee mobile agent.
 @param appId the application id for your app (uniquely assigned by portal for each app)
 @param consumerKey the consumer key for your app (uniquely assigned by portal for each app)
 @param secretKey the secret key for your app (uniquely assigned by portal for each app)
 @return initialized instance of ApigeeMonitoringClient
 */
- (id) initWithAppIdentification:(ApigeeAppIdentification*)appIdentification
                      dataClient:(ApigeeDataClient*)dataClient;

- (id) initWithAppIdentification:(ApigeeAppIdentification*)appIdentification
                      dataClient:(ApigeeDataClient*)dataClient
                         options:(ApigeeMonitoringOptions*)monitoringOptions;

/**
 Initializes ApigeeMonitoringClient which controls the Apigee mobile agent.
 @param appId the application id for your app (uniquely assigned by portal for each app)
 @param consumerKey the consumer key for your app (uniquely assigned by portal for each app)
 @param secretKey the secret key for your app (uniquely assigned by portal for each app)
 @param crashReportingEnabled determines whether crash reports should be uploaded to server (allows you to opt-out of crash reports)
 @return initialized instance of ApigeeMonitoringClient
 */
- (id) initWithAppIdentification: (ApigeeAppIdentification*) appIdentification
                      dataClient: (ApigeeDataClient*) dataClient
                  crashReporting: (BOOL) crashReportingEnabled;

/**
 Initializes ApigeeMonitoringClient which controls the Apigee mobile agent.
 @param appId the application id for your app (uniquely assigned by portal for each app)
 @param consumerKey the consumer key for your app (uniquely assigned by portal for each app)
 @param secretKey the secret key for your app (uniquely assigned by portal for each app)
 @param environment the environment that your app belongs to (always use 'prod' here)
 @param crashReportingEnabled determines whether crash reports should be uploaded to server (allows you to opt-out)
 @param autoInterceptCalls determines whether automatic interception of network calls is enabled (allows you to opt-out)
 @return initialized instance of ApigeeMonitoringClient
 */
- (id) initWithAppIdentification: (ApigeeAppIdentification*) appIdentification
                      dataClient: (ApigeeDataClient*) dataClient
                  crashReporting: (BOOL) crashReportingEnabled
           interceptNetworkCalls: (BOOL) autoInterceptCalls;

/**
 Initializes ApigeeMonitoringClient which controls the Apigee mobile agent.
 @param appId the application id for your app (uniquely assigned by portal for each app)
 @param consumerKey the consumer key for your app (uniquely assigned by portal for each app)
 @param secretKey the secret key for your app (uniquely assigned by portal for each app)
 @param environment the environment that your app belongs to (always use 'prod' here)
 @param crashReportingEnabled determines whether crash reports should be uploaded to server (allows you to opt-out)
 @param autoInterceptCalls determines whether automatic interception of network calls is enabled (allows you to opt-out)
 @param uploadListener listener to be notified on upload of crash reports and metrics
 @return initialized instance of ApigeeMonitoringClient
 */
- (id) initWithAppIdentification: (ApigeeAppIdentification*) appIdentification
                      dataClient: (ApigeeDataClient*) dataClient
                  crashReporting: (BOOL) crashReportingEnabled
           interceptNetworkCalls: (BOOL) autoInterceptCalls
                  uploadListener: (id<ApigeeUploadListener>)uploadListener;

/**
 Answers the question of whether the device session is participating in the sampling
 of metrics. An app configuration of 100% would cause this method to always return YES,
 while an app configuration of 100% would cause this method to always return NO.
 Intermediate values of sampling percentage will cause a random YES/NO to be returned
 with a probability equal to the sampling percentage configured for the app.
 @return boolean indicating whether device session is participating in metrics sampling
 */
- (BOOL)isParticipatingInSample;

/**
 Answers the question of whether the device is currently connected to a network
 (either WiFi or cellular).
 @return boolean indicating whether device currently has network connectivity
 */
- (BOOL)isDeviceNetworkConnected;

/**
 Retrieves all customer configuration parameter keys that belong to the
 specified category.
 @param category the category whose keys are desired
 @return array of keys belonging to category, or nil if no keys exist
 */
- (NSArray*)customConfigPropertyKeysForCategory:(NSString*)category;

/**
 Retrieves the value for the specified custom configuration parameter.
 @param key the key name for the desired custom configuration parameter
 @return value associated with key, or nil if no property exists
 */
- (NSString*)customConfigPropertyValueForKey:(NSString*)key;

/**
 Retrieves the value for the specified custom configuration parameter.
 @param key the key name for the desired custom configuration parameter
 @param categoryName the category for the desired custom configuration parameter
 @return value associated with key and category, or nil if no property exists
 */
- (NSString*)customConfigPropertyValueForKey:(NSString *)key
                                 forCategory:(NSString*)categoryName;

/**
 Forces device metrics to be uploaded.
 @return boolean indicating whether metrics were able to be uploaded
 */
- (BOOL)uploadAnalytics;

/**
 Forces update (re-read) of configuration information.
 @return boolean indicating whether the re-read of configuration parameters
 was successful
 */
- (BOOL)refreshConfiguration;

- (BOOL)addUploadListener:(id<ApigeeUploadListener>)uploadListener;
- (BOOL)removeUploadListener:(id<ApigeeUploadListener>)uploadListener;

/**
 Records a successful network call.
 @param url the url accessed
 @param startTime the time when the call was initiated
 @param endTime the time when the call completed
 @return boolean indicating whether the recording was made or not
 */
- (BOOL)recordNetworkSuccessForUrl:(NSString*)url
                         startTime:(NSDate*)startTime
                           endTime:(NSDate*)endTime;

/**
 Records a failed network call.
 @param url the url accessed
 @param startTime the time when the call was initiated
 @param endTime the time when the call failed
 @param errorDescription description of the error encountered
 @return boolean indicating whether the recording was made or not
 */
- (BOOL)recordNetworkFailureForUrl:(NSString*)url
                         startTime:(NSDate*)startTime
                           endTime:(NSDate*)endTime
                             error:(NSString*)errorDescription;

/**
 Retrieves the base URL path used by mobile analytics
 @return string indicating base URL path used by mobile analytics
 */
- (NSString*)baseURLPath;

/** The following methods are advanced methods intended to be used in
   conjunction with our C API. They would not be needed for a typical
   Objective-C application. */

/**
 Retrieves the time that the mobile agent was initialized (i.e., startup time)
 @return date object representing mobile agent startup time
 */
- (NSDate*)timeStartup;

/**
 Retrieves the Mach time that the mobile agent was initialized (i.e., startup time)
 @return Mach time in billionths of a second representing mobile agent startup time
 */
- (uint64_t)timeStartupMach;

/**
 Retrieves the Mach time that the mobile agent last uploaded metrics to portal
 @return Mach time in billionths of a second representing time of last metrics upload (or 0 if no upload has occurred)
 */
- (uint64_t)timeLastUpload;

/**
 Retrieves the Mach time that the mobile agent last recognized a network transmission
 @return Mach time in billionths of a second representing time of last network transmission (or 0 if none has occurred)
 */
- (uint64_t)timeLastNetworkTransmission;

/**
 Converts a Mach time to an NSDate object
 @param mach_time the Mach time (in billionths of a second) to convert
 @return the Mach time represented as an NSDate
 */
- (NSDate*)machTimeToDate:(uint64_t)mach_time;

/*
- (void) updateLastNetworkTransmissionTime:(NSString*) networkTransmissionTime;
*/

@end
