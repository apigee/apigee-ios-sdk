//
//  ApigeeMonitoringClient.m
//  ApigeeMonitoringClient
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <asl.h>

#include <time.h>
#include <objc/runtime.h>
#include <mach/mach.h>
#include <mach/mach_time.h>

#import "ApigeeCrashReporter.h"
#import "NSString+UUID.h"
#import "NSDate+Apigee.h"
#import "NSObject+ApigeeSBJson.h"
#import "ApigeeSystemLogger.h"
#import "ApigeeReachability.h"
#import "ApigeeOpenUDID.h"

#import "ApigeeSystemLogger.h"
#import "ApigeeLogger.h"
#import "ApigeeIntervalTimer.h"

#import "ApigeeLogEntry.h"
#import "ApigeeSessionMetrics.h"
#import "ApigeeCompositeConfiguration.h"

#import "ApigeeLogEntry+JSON.h"
#import "ApigeeNetworkEntry+JSON.h"
#import "ApigeeCompositeConfiguration+JSON.h"

#import "ApigeeQueue+NetworkMetrics.h"
#import "ApigeeCachedConfigUtil.h"
#import "ApigeeLocationService.h"
#import "ApigeeLogCompiler.h"
#import "ApigeeSessionMetricsCompiler.h"
#import "ApigeeMonitoringClient.h"
#import "ApigeeMonitoringOptions.h"

#import "ApigeeURLConnection.h"
#import "ApigeeFunctions.h"

#import "ApigeeCustomConfigParam.h"

#import "ApigeeAppIdentification.h"
#import "ApigeeDataClient.h"
#import "ApigeeClient.h"

static const int64_t kOneMillion = 1000 * 1000;
static mach_timebase_info_data_t s_timebase_info;


static ApigeeMonitoringClient *singletonInstance = nil;

static const BOOL kDefaultUploadCrashReports    = YES;
static const BOOL kDefaultInterceptNetworkCalls = YES;

static NSString* kApigeeMonitoringClientTag = @"MOBILE_AGENT";



@interface ApigeeMonitoringClient ()

@property (strong) NSString *appName;

@property (strong) ApigeeReachability *reachability;

@property (assign) aslclient client;

@property (strong) ApigeeIntervalTimer* timer;

@property (assign) BOOL swizzledNSURLConnection;
@property (assign) BOOL sentStartingSessionData;
@property (assign) BOOL isPartOfSample;
@property (assign) BOOL isInitialized;
@property (assign) BOOL isActive;

@property (strong) NSDate *startupTime;
@property (assign) uint64_t startupTimeMach;
@property (assign) uint64_t lastUploadTime;
@property (assign) uint64_t lastNetworkTransmissionTime;

@property (strong) NSMutableDictionary *dictCustomConfigKeysByCategory;
@property (strong) NSMutableDictionary *dictCustomConfigValuesByKey;
@property (strong) NSMutableDictionary *dictCustomConfigValuesByCategoryAndKey;

@property (strong) NSMutableArray *listListeners;

@property (unsafe_unretained) ApigeeAppIdentification *appIdentification;
@property (unsafe_unretained) ApigeeDataClient *dataClient;


- (BOOL) uploadEvents;
- (void) applyConfig;
- (BOOL) hasPendingCrashReports;
- (void) uploadCrashReports;
- (BOOL) enableCrashReporter:(NSError**) error;

@end

@implementation ApigeeMonitoringClient

@synthesize appName;

@synthesize reachability;

@synthesize client;
@synthesize timer;

@synthesize activeSettings;
@synthesize sentStartingSessionData;
@synthesize isInitialized;
@synthesize isActive;

@synthesize startupTime;
@synthesize startupTimeMach;
@synthesize lastUploadTime;
@synthesize lastNetworkTransmissionTime;

@synthesize appIdentification;
@synthesize dataClient;

// this method is sometimes handy for debugging
- (void)log:(NSString*)data toFile:(NSString*)fileName
{
#if TARGET_IPHONE_SIMULATOR
    NSString* fullFileName = [NSString stringWithFormat:@"/Users/ApigeeCorporation/%@", fileName];
    FILE* f = fopen([fullFileName UTF8String],"a+");
    if( f != NULL )
    {
        time_t lt = time(NULL);
        struct tm* ptr = localtime(&lt);
        
        NSString* appIdString = [NSString stringWithFormat:@"App: %d (%@/%@)",
                                 [self.activeSettings.instaOpsApplicationId intValue],
                                 self.activeSettings.orgName,
                                 self.activeSettings.appName];
        
        fprintf(f,"%s\n", [appIdString UTF8String]);
        fprintf(f,"Time: %s\n", asctime(ptr));
        
        fprintf(f,"%s\n", [data UTF8String]);
        fprintf(f,"=======================================================\n");
        fclose(f);
    }
#endif
}

+ (NSString*)sdkVersion
{
    return [ApigeeClient sdkVersion];
}


#pragma mark - Initialization and clean up

+ (id)sharedInstance
{
    // only returns non-nil pointer if it's been already created
    return singletonInstance;
}

- (void) dealloc
{
    singletonInstance = nil;
    NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
    
    [notifyCenter removeObserver:self
                         name:kReachabilityChangedNotification
                       object:nil];
    
    [notifyCenter removeObserver:self
                         name:UIApplicationDidEnterBackgroundNotification
                       object:nil];
    
    [notifyCenter removeObserver:self
                         name:UIApplicationDidReceiveMemoryWarningNotification
                       object:nil];
    
    [notifyCenter removeObserver:self
                         name:UIApplicationSignificantTimeChangeNotification
                       object:nil];
    
    [notifyCenter removeObserver:self
                         name:UIApplicationWillEnterForegroundNotification
                       object:nil];
    
    [notifyCenter removeObserver:self
                         name:UIApplicationWillResignActiveNotification
                       object:nil];
    
    [notifyCenter removeObserver:self
                         name:UIApplicationWillTerminateNotification
                       object:nil];
}

- (id) initWithAppIdentification: (ApigeeAppIdentification*) theAppIdentification
                      dataClient: (ApigeeDataClient*) theDataClient
{
    return [self initWithAppIdentification:theAppIdentification
                                dataClient:theDataClient
                            crashReporting:kDefaultUploadCrashReports
                     interceptNetworkCalls:kDefaultInterceptNetworkCalls];
}

- (id) initWithAppIdentification:(ApigeeAppIdentification*)theAppIdentification
                      dataClient:(ApigeeDataClient*)theDataClient
                         options:(ApigeeMonitoringOptions*)monitoringOptions
{
    BOOL crashReporting = monitoringOptions.crashReportingEnabled;
    BOOL interceptNetworkCalls = monitoringOptions.interceptNetworkCalls;
    id<ApigeeUploadListener> uploadListener = monitoringOptions.uploadListener;
    
    return [self initWithAppIdentification:theAppIdentification
                                dataClient:theDataClient
                            crashReporting:crashReporting
                     interceptNetworkCalls:interceptNetworkCalls
                            uploadListener:uploadListener];
}


- (id) initWithAppIdentification: (ApigeeAppIdentification*) theAppIdentification
                      dataClient: (ApigeeDataClient*) theDataClient
                  crashReporting: (BOOL) enabled
{
    return [self initWithAppIdentification:theAppIdentification
                                dataClient:theDataClient
                            crashReporting:enabled
                     interceptNetworkCalls:kDefaultInterceptNetworkCalls];
}

- (id) initWithAppIdentification: (ApigeeAppIdentification*) theAppIdentification
                      dataClient: (ApigeeDataClient*) theDataClient
                  crashReporting: (BOOL) crashReportingEnabled
           interceptNetworkCalls: (BOOL) interceptCalls
{
    return [self initWithAppIdentification:theAppIdentification
                                dataClient:theDataClient
                            crashReporting:crashReportingEnabled
                     interceptNetworkCalls:interceptCalls
                            uploadListener:nil];
}

- (id) initWithAppIdentification: (ApigeeAppIdentification*) theAppIdentification
                      dataClient: (ApigeeDataClient*) theDataClient
                  crashReporting: (BOOL) crashReportingEnabled
           interceptNetworkCalls: (BOOL) autoInterceptCalls
                  uploadListener: (id<ApigeeUploadListener>)uploadListener
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.appIdentification = theAppIdentification;
    self.dataClient = theDataClient;
    
    self.isActive = NO;
    self.isInitialized = NO;
    self.startupTimeMach = mach_absolute_time();
    self.startupTime = [NSDate date];
    
    // call to perform one-time initialization
    [self machTimeToDate:self.startupTimeMach];
    
    singletonInstance = self;
    
    
    self.swizzledNSURLConnection = NO;
    self.sentStartingSessionData = NO;
    
    NSDate *startLogSearchDate = [self.startupTime dateByAddingTimeInterval:-2.0];

    [ApigeeLogCompiler refreshUploadTimestamp:startLogSearchDate];
    
    self.timer = nil;
    self.lastUploadTime = 0;
    self.lastNetworkTransmissionTime = 0;
    
    self.appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    
    self.listListeners = [[NSMutableArray alloc] init];
    
    if( uploadListener != nil ) {
        [self.listListeners addObject:uploadListener];
    }
    
    self.dictCustomConfigKeysByCategory = [[NSMutableDictionary alloc] init];
    self.dictCustomConfigValuesByKey = [[NSMutableDictionary alloc] init];
    self.dictCustomConfigValuesByCategoryAndKey = [[NSMutableDictionary alloc] init];
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    
    self.reachability = [ApigeeReachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    [self reset];
    [self updateConfig];

    if (crashReportingEnabled) {
        
        // look for other crash reporters that may be present
        NSString* otherCrashReporterClasses =
            @"PLCrashReporter|BITCrashManager|BugSenseCrashController|Crittercism|KSCrash|CrashController";
        NSArray* listOtherCrashReporterClasses = [otherCrashReporterClasses componentsSeparatedByString:@"|"];
        
        for( NSString* crashReporterClass in listOtherCrashReporterClasses )
        {
            Class clsCrashReporter = NSClassFromString(crashReporterClass);
            if (nil != clsCrashReporter) {
                ApigeeLogWarn(kApigeeMonitoringClientTag, @"Multiple crash reporters detected");
                break;
            }
        }
        
        NSError *error = nil;
        
        if (![self enableCrashReporter:&error] || (nil !=error)) {
            ApigeeLogAssert(kApigeeMonitoringClientTag, @"Failed to start the crash reporter: %@", error);
        } else if ([self hasPendingCrashReports]){
            [self uploadCrashReports];
        }
    } else {
        ApigeeLogInfo(kApigeeMonitoringClientTag, @"Crash reporting disabled");
    }

    ApigeeLogInfo(kApigeeMonitoringClientTag, @"INIT_AGENT");

    [self applyConfig];
    
    if (autoInterceptCalls) {
        [self enableInterceptedNetworkingCalls];
    }
    
    return self;
}

#pragma mark - Property implementations

- (NSString*) apigeeDeviceId
{
    return [ApigeeOpenUDID value];
}

#pragma mark - System configuration

- (void) applyConfig
{
    // are we disabled?
    if (!self.activeSettings.monitoringDisabled) {
        
        self.isInitialized = YES;
        
        //coin flip for sample rate
        const uint32_t r = arc4random() % 100;
        
        if (r < self.activeSettings.samplingRate) {
            self.isPartOfSample = YES;
            self.isActive = YES;
            
            NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
            [notifyCenter addObserver:self
                             selector:@selector(networkChanged:)
                                 name:kReachabilityChangedNotification
                               object:nil];
            
            [notifyCenter addObserver:self
                             selector:@selector(applicationDidEnterBackground:)
                                 name:UIApplicationDidEnterBackgroundNotification
                               object:nil];
            
            [notifyCenter addObserver:self
                             selector:@selector(applicationDidReceiveMemoryWarning:)
                                 name:UIApplicationDidReceiveMemoryWarningNotification
                               object:nil];
            
            [notifyCenter addObserver:self
                             selector:@selector(applicationSignificantTimeChange:)
                                 name:UIApplicationSignificantTimeChangeNotification
                               object:nil];
            
            [notifyCenter addObserver:self
                             selector:@selector(applicationWillEnterForeground:)
                                 name:UIApplicationWillEnterForegroundNotification
                               object:nil];
            
            [notifyCenter addObserver:self
                             selector:@selector(applicationWillResignActive:)
                                 name:UIApplicationWillResignActiveNotification
                               object:nil];
            
            [notifyCenter addObserver:self
                             selector:@selector(applicationWillTerminate:)
                                 name:UIApplicationWillTerminateNotification
                               object:nil];
            
            ApigeeLogInfo(kApigeeMonitoringClientTag, @"Configuration values applied");
            
        } else {
            self.isPartOfSample = NO;
            
            if (self.timer) {
                [self.timer cancel];
                self.timer = nil;
            }
            
            SystemDebug(@"IO_Diagnostics",@"Device not chosen for sample");
        }
    } else {
        SystemDebug(@"IO_Diagnostics",@"Monitoring disabled");
    }
}

- (NSString*)baseServerURL
{
    NSString* baseServerURL = nil;
    NSString* baseURL = appIdentification.baseURL;
    
    if( [baseURL hasSuffix:@"/"] ) {
        baseServerURL = [NSString stringWithFormat:@"%@%@/%@",
                         baseURL,
                         appIdentification.organizationId,
                         appIdentification.applicationId];
    } else {
        baseServerURL = [NSString stringWithFormat:@"%@/%@/%@",
                         baseURL,
                         appIdentification.organizationId,
                         appIdentification.applicationId];
    }
    
    return baseServerURL;
}

- (NSString*)configDownloadURL
{
    return [NSString stringWithFormat:@"%@/apm/apigeeMobileConfig",
            [self baseServerURL]];
}

- (NSString*)retrieveConfigFromServer
{
    if( [self isDeviceNetworkConnected] ) {
        NSURL* url = [NSURL URLWithString:[self configDownloadURL]];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
        NSURLResponse* response = [[NSURLResponse alloc] init];
        NSError* error = nil;
    
        NSData* responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
    
        if( nil != responseData ) {
            return [[NSString alloc] initWithData:responseData
                                         encoding:NSUTF8StringEncoding];
        } else {
            if( error != nil ) {
                NSString* errorMsg = [NSString stringWithFormat:@"Error retrieving config from server: %@",
                                      [error localizedDescription]];
                ApigeeLogError(kApigeeMonitoringClientTag,errorMsg);
            } else {
                ApigeeLogError(kApigeeMonitoringClientTag,
                               @"Unable to retrieve config from server");
            }
            return nil;
        }
    } else {
        ApigeeLogDebug(kApigeeMonitoringClientTag, @"Unable to retrieve config from server, device not connected to network");
        return nil;
    }
}

- (void) updateConfig
{
    NSString* jsonConfig = [self retrieveConfigFromServer];
    if( jsonConfig != nil ) {
        
        BOOL willUpdateCacheFromServer = YES;  // until we find out otherwise
        
        NSDictionary* configDict = [jsonConfig JSONValue];
        if( configDict != nil ) {
            id lastModifedDate = [configDict valueForKey:@"lastModifiedDate"];
            if( lastModifedDate != nil ) {
                long long lastModifiedDateValue = 0;
            
                if( [lastModifedDate isKindOfClass:[NSString class]] ) {
                    NSString* lastModifiedDateAsString = (NSString*) lastModifedDate;
                    lastModifiedDateValue = [lastModifiedDateAsString longLongValue];
                } else if( [lastModifedDate isKindOfClass:[NSNumber class]] ) {
                    NSNumber* lastModifiedDateAsNumber = (NSNumber*) lastModifedDate;
                    lastModifiedDateValue = [lastModifiedDateAsNumber longLongValue];
                }
            
                if( lastModifiedDateValue > 0 ) {
                    NSDate* serverLastModifiedDate = [NSDate dateFromMilliseconds:lastModifiedDateValue];
                    
                    if( self.activeSettings && self.activeSettings.appLastModifiedDate ) {
                        if( ! [self.activeSettings.appLastModifiedDate isEqualToDate:serverLastModifiedDate] ) {
                            NSDate* laterConfigDate = [self.activeSettings.appLastModifiedDate laterDate:serverLastModifiedDate];
                            
                            // is configuration from server newer than what we currently have?
                            if( laterConfigDate == self.activeSettings.appLastModifiedDate  ) {
                                willUpdateCacheFromServer = NO;
                            }
                        } else {
                            // server config date and local config dates match -- no need to update
                            willUpdateCacheFromServer = NO;
                        }
                    }
                }
            }
        } else {
            SystemError(kApigeeMonitoringClientTag, @"parsing of config from server returned nil");
        }
        
        if( willUpdateCacheFromServer ) {
            [self saveConfig:jsonConfig];
        }
    } else {
        // request to read config from server failed
        SystemError(kApigeeMonitoringClientTag, @"Unable to read configuration from server");
    }
}

//note: this can be called by async background thread
- (void) reset
{
    @synchronized (self) {
        if (self.timer) {
            [self.timer cancel];
        }
        
#if !(TARGET_IPHONE_SIMULATOR)
        [[ApigeeLocationService defaultService] reset];
#endif
        
        NSError *error;
        ApigeeCompositeConfiguration* config = [ApigeeCachedConfigUtil getConfiguration:&error];
        
        if (!config) {
            SystemError(kApigeeMonitoringClientTag, @"Initializing configuration failed: %@", [error localizedDescription]);
            return;
        }
        
        
        //we always want these values to be set from what was passed during SDK initialization
        
        
        self.activeSettings = [[ApigeeActiveSettings alloc] initWithConfig:config];
        self.activeSettings.activeNetworkStatus = [self.reachability currentReachabilityStatus];
        
        // populate our internal dictionaries with custom config parameters
        [self.dictCustomConfigKeysByCategory removeAllObjects];
        [self.dictCustomConfigValuesByKey removeAllObjects];
        [self.dictCustomConfigValuesByCategoryAndKey removeAllObjects];
        
        NSArray *settings = self.activeSettings.customConfigParams;
        
        for (ApigeeCustomConfigParam *param in settings) {
            NSString *category = param.category;
            NSString *key = param.key;
            NSString *value = param.value;
            
            NSMutableArray *listKeysForCategory =
                [self.dictCustomConfigKeysByCategory valueForKey:category];
            
            if( nil == listKeysForCategory )
            {
                listKeysForCategory = [[NSMutableArray alloc] init];
                [self.dictCustomConfigKeysByCategory setValue:listKeysForCategory
                                                       forKey:category];
            }
            
            [listKeysForCategory addObject:key];
            
            [self.dictCustomConfigValuesByKey setValue:value forKey:key];
            
            NSString *combinedCategoryKey =
                [self dictionaryKeyForCategory:category
                                           key:key];
            [self.dictCustomConfigValuesByCategoryAndKey setValue:value
                                                          forKey:combinedCategoryKey];
        }

        if (self.activeSettings.monitoringDisabled) {
            return;
        }
        
#if !(TARGET_IPHONE_SIMULATOR)
        if (self.activeSettings.locationCaptureEnabled) {
            [[ApigeeLocationService defaultService] startScan];
        }
#endif
        
        self.timer = [[ApigeeIntervalTimer alloc] init];
        [self.timer fireOnInterval:self.activeSettings.agentUploadIntervalInSeconds
                            target:self
                          selector:@selector(timerFired)
                           repeats:NO];
    }
}

- (void)timerFired
{
    if (!self.isPartOfSample) {
        return;
    }
    
    self.timer = [[ApigeeIntervalTimer alloc] init];
    [self.timer fireOnInterval:self.activeSettings.agentUploadIntervalInSeconds
                        target:self
                      selector:@selector(timerFired)
                       repeats:NO];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        //[self performSelectorInBackground:@selector(uploadEvents) withObject:nil];
        [self uploadEvents];
    });
}

- (NSData*)postString:(NSString*)postBody toUrl:(NSString*)urlAsString contentType:(NSString*)contentType
{
    NSURL* url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    
    if( [contentType length] > 0 ) {
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    }
    
    NSData* postData = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    NSString* postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:postData];
    
    NSURLResponse* response = nil;
    NSError* err = nil;
    
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&err];
    
    if( err != nil ) {
        ApigeeLogError(kApigeeMonitoringClientTag, [NSString stringWithFormat:@"%@",[err localizedDescription]]);
    }
    
    return responseData;
}

- (NSData*)postString:(NSString*)postBody toUrl:(NSString*)urlAsString
{
    return [self postString:postBody toUrl:urlAsString contentType:@"application/json; charset=utf-8"];
}

- (NSData*)putString:(NSString*)postBody toUrl:(NSString*)urlAsString contentType:(NSString*)contentType
{
    NSURL* url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"PUT"];
    
    if( [contentType length] > 0 ) {
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    }
    
    NSData* postData = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    NSString* postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:postData];
    
    NSURLResponse* response = nil;
    NSError* err = nil;
    
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&err];
    
    if( err != nil ) {
        ApigeeLogError(kApigeeMonitoringClientTag, [NSString stringWithFormat:@"%@",[err localizedDescription]]);
    }
    
    return responseData;
}

- (NSData*)putString:(NSString*)postBody toUrl:(NSString*)urlAsString
{
    return [self putString:postBody toUrl:urlAsString contentType:@"application/json; charset=utf-8"];
}


#pragma mark - Crash reporter

- (BOOL) hasPendingCrashReports
{
    return [[Apigee_PLCrashReporter sharedReporter] hasPendingCrashReport];
}

- (NSString*)crashReportUploadURL:(NSString*)crashFileName
{
    return [NSString stringWithFormat:@"%@/apm/crashLogs/%@",
            [self baseServerURL],
            crashFileName];
}

- (void) uploadCrashReports
{
    if (![self hasPendingCrashReports]) {
        return;
    }
    
    Apigee_PLCrashReporter* crashReporter = [Apigee_PLCrashReporter sharedReporter];
    NSError* error = nil;
    NSData* data = [crashReporter loadPendingCrashReportDataAndReturnError:&error];
    Apigee_PLCrashReport *report = [[Apigee_PLCrashReport alloc] initWithData:data error:&error];
    
    if (error) {
        SystemError(@"CrashReporter", @"Error loading crash report: %@", [error localizedDescription]);
        return;
    }
    
    NSString *log = [Apigee_PLCrashReportTextFormatter stringValueForCrashReport:report
                                                                  withTextFormat:Apigee_PLCrashReportTextFormatiOS];
    
    NSString* uuid = [NSString uuid];
    NSString* fileName = [NSString stringWithFormat:@"%@.crash", uuid];
    
    if( [self.listListeners count] > 0 ) {
        for( id<ApigeeUploadListener> listener in self.listListeners ) {
            if( [listener respondsToSelector:@selector(onUploadCrashReport:)] ) {
                [listener onUploadCrashReport:log];
            }
        }
    }
    
    NSData* crashReportUploadResponseData = [self putString:log
                                                       toUrl:[self crashReportUploadURL:fileName]
                                                 contentType:@"text/plain"];
    if( nil != crashReportUploadResponseData ) {
        NSString* crashReportUploadResponseAsString = [[NSString alloc] initWithData:crashReportUploadResponseData encoding:NSUTF8StringEncoding];
        [self sendCrashNotification:fileName];
        [crashReporter purgePendingCrashReport];
    } else {
        ApigeeLogAssert(@"Apigee Data Client",
                        @"There was an error with the request to upload the crash report");
    }
    
    [self uploadEvents];
}

- (BOOL) enableCrashReporter:(NSError**) error
{
    return [[Apigee_PLCrashReporter sharedReporter] enableCrashReporterAndReturnError:error];
}

#pragma mark - Internal implementations

- (void) networkChanged:(NSNotification *) notice
{
    self.activeSettings.activeNetworkStatus = [self.reachability currentReachabilityStatus];
}

- (void)populateClientMetricsEnvelope:(NSMutableDictionary*)clientMetricsEnvelope
{
    [clientMetricsEnvelope setObject:self.activeSettings.instaOpsApplicationId forKey:@"instaOpsApplicationId"];
    [clientMetricsEnvelope setObject:self.activeSettings.orgName forKey:@"orgName"];
    [clientMetricsEnvelope setObject:self.activeSettings.appName forKey:@"appName"];
    [clientMetricsEnvelope setObject:self.activeSettings.fullAppName forKey:@"fullAppName"];
    [clientMetricsEnvelope setObject:[NSDate unixTimestampAsString] forKey:@"timeStamp"];
}

- (NSString*)metricsUploadURL
{
    return [NSString stringWithFormat:@"%@/apm/apmMetrics",
            [self baseServerURL]];
}

- (BOOL) uploadEvents
{
    @autoreleasepool {
        
        ApigeeNetworkStatus netStatus = self.activeSettings.activeNetworkStatus;
        
        // do we have network connectivity?
        if (Apigee_NotReachable == netStatus) {
            ApigeeLogVerbose(kApigeeMonitoringClientTag, @"Cannot upload events -- no network connectivity");
            return NO;  // no connectivity, can't upload
        }

        // not on WiFi?
        if (netStatus != Apigee_ReachableViaWiFi) {
            // should we not upload when mobile (not on wifi)?
            if (!self.activeSettings.enableUploadWhenMobile) {
                ApigeeLogVerbose(kApigeeMonitoringClientTag, @"Cannot upload events -- upload when on mobile network disallowed");
                return NO;
            }
        }
        
        NSArray *logEntries = [[ApigeeLogCompiler systemCompiler] compileLogsForSettings:self.activeSettings];
        
        NSArray *networkMetrics = [[ApigeeQueue networkMetricsQueue] dequeueAll];

        if (([logEntries count] == 0) &&
            ([networkMetrics count] == 0) &&
            self.sentStartingSessionData)
        {
            // no log entries, no network metrics, and we've already sent the
            // initial session data
            ApigeeLogVerbose(kApigeeMonitoringClientTag, @"Not uploading events -- nothing to send");
            return NO;
        }
        
        ApigeeSessionMetrics *sessionMetrics =
            [[ApigeeSessionMetricsCompiler systemCompiler] compileMetricsForSettings:self.activeSettings];
    
        NSMutableDictionary *clientMetricsEnvelope = [NSMutableDictionary dictionary];
        [self populateClientMetricsEnvelope:clientMetricsEnvelope];
        [clientMetricsEnvelope setObject:[ApigeeLogEntry toDictionaries:logEntries] forKey:@"logs"];
        [clientMetricsEnvelope setObject:[ApigeeNetworkEntry toDictionaries:networkMetrics] forKey:@"metrics"];
        [clientMetricsEnvelope setObject:[sessionMetrics asDictionary] forKey:@"sessionMetrics"];
    
        NSString *json = [clientMetricsEnvelope JSONRepresentation];
        
        if( self.listListeners && ([self.listListeners count] > 0) ) {
            for( id<ApigeeUploadListener> listener in self.listListeners ) {
                [listener onUploadMetrics:json];
            }
        }
        
        if( nil != [self postString:json
                       toUrl:[self metricsUploadURL]] ) {
            if (!self.sentStartingSessionData) {
                self.sentStartingSessionData = YES;
            }
            
            self.lastUploadTime = mach_absolute_time();
            
            //[ApigeeLogCompiler refreshUploadTimestamp];
            
            return YES;
        } else {
            return NO;
        }
    }
}

- (void) sendCrashNotification:(NSString *) fileName
{
    NSString* nowTimestamp = [NSDate unixTimestampAsString];
    
    ApigeeLogEntry *logEntry = [[ApigeeLogEntry alloc] init];
    logEntry.timeStamp = nowTimestamp;
    logEntry.tag = @"CRASH";
    logEntry.logMessage = fileName;
    logEntry.logLevel = @"A"; // assert

    ApigeeSessionMetrics *sessionMetrics = [[ApigeeSessionMetricsCompiler systemCompiler] compileMetricsForSettings:self.activeSettings];
    NSArray *logEntries = [NSArray arrayWithObject:logEntry];
    
    NSMutableDictionary *clientMetricsEnvelope = [NSMutableDictionary dictionary];
    [self populateClientMetricsEnvelope:clientMetricsEnvelope];
    
    [clientMetricsEnvelope setObject:[ApigeeLogEntry toDictionaries:logEntries] forKey:@"logs"];
    [clientMetricsEnvelope setObject:[NSArray array] forKey:@"metrics"];
    [clientMetricsEnvelope setObject:[sessionMetrics asDictionary] forKey:@"sessionMetrics"];
    
    NSString *json = [clientMetricsEnvelope JSONRepresentation];
    
    if( nil != [self postString:json
                   toUrl:[self metricsUploadURL]] ) {
        self.lastUploadTime = mach_absolute_time();
        SystemAssert(@"Crash Log", @"Crash notification sent for %@", fileName);
    }    
}

- (void) saveConfig:(NSString *) json
{
    if ([json length] == 0) {
        SystemError(kApigeeMonitoringClientTag, @"We have no json to deserialize.");
        return;
    }
    
    NSError *error = nil;
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    [ApigeeCachedConfigUtil updateConfiguration:data error:&error];
    
    if (error) {
        SystemError(kApigeeMonitoringClientTag, @"Error updating cached config file: %@", [error localizedDescription]);
        return;
    }
    
    [self reset];
}

- (BOOL) swizzleClass:(Class) targetClass
          classMethod:(SEL) originalSelector
     replacementClass:(Class) swizzleClass
replacementClassMethod:(SEL) replacementSelector
{
    Method origMethod = class_getClassMethod(targetClass, originalSelector);
    Method newMethod = class_getClassMethod(swizzleClass, replacementSelector);
    method_exchangeImplementations(origMethod, newMethod);
    return YES;
}

- (BOOL) swizzleClass:(Class) targetClass
       instanceMethod:(SEL) originalSelector
     replacementClass:(Class) swizzleClass
replacementInstanceMethod:(SEL) replacementSelector
{
    Method origMethod = class_getInstanceMethod(targetClass, originalSelector);
    Method newMethod = class_getInstanceMethod(swizzleClass, replacementSelector);
    method_exchangeImplementations(origMethod, newMethod);
    return YES;
}

- (void) enableInterceptedNetworkingCalls
{
    if (!self.activeSettings.monitoringDisabled && !self.swizzledNSURLConnection) {

        Class clsNSURLConnection = [NSURLConnection class];
    
        [self swizzleClass:clsNSURLConnection
               classMethod:@selector(sendSynchronousRequest:returningResponse:error:)
          replacementClass:clsNSURLConnection
    replacementClassMethod:@selector(swzSendSynchronousRequest:returningResponse:error:)];

        [self swizzleClass:clsNSURLConnection
               classMethod:@selector(connectionWithRequest:delegate:)
          replacementClass:clsNSURLConnection
    replacementClassMethod:@selector(swzConnectionWithRequest:delegate:)];

        [self swizzleClass:clsNSURLConnection
            instanceMethod:@selector(initWithRequest:delegate:startImmediately:)
          replacementClass:clsNSURLConnection
 replacementInstanceMethod:@selector(initSwzWithRequest:delegate:startImmediately:)];
    
        [self swizzleClass:clsNSURLConnection
            instanceMethod:@selector(start)
          replacementClass:clsNSURLConnection
 replacementInstanceMethod:@selector(swzStart)];
    
        self.swizzledNSURLConnection = YES;
    }
}

- (BOOL) isNSURLConnectionIntercepted
{
    return self.swizzledNSURLConnection;
}

- (NSDate*)timeStartup
{
    return self.startupTime;
}

- (uint64_t)timeStartupMach
{
    return self.startupTimeMach;
}

- (uint64_t)timeLastUpload
{
    return self.lastUploadTime;
}

- (uint64_t)timeLastNetworkTransmission
{
    return self.lastNetworkTransmissionTime;
}

- (NSDate*)machTimeToDate:(uint64_t)mach_time
{
    const uint64_t startupMachTime = self.timeStartupMach;
    const uint64_t elapsedMachTime = mach_time - startupMachTime;
        
    if (s_timebase_info.denom == 0) {
        (void) mach_timebase_info(&s_timebase_info);
    }
        
    // mach_absolute_time() returns billionth of seconds,
    // so divide by one million to get milliseconds
    const double elapsedMillis = (elapsedMachTime * s_timebase_info.numer) /
                                    (kOneMillion * s_timebase_info.denom);
        
    const NSTimeInterval timeInterval = elapsedMillis / 1000;
        
    return [self.timeStartup dateByAddingTimeInterval:timeInterval];
}

- (uint64_t)dateToMachTime:(NSDate*)date
{
    // calculate elapsed time (in seconds) from date argument from our startup time
    NSTimeInterval intervalElapsedSeconds = [date timeIntervalSinceDate:self.timeStartup];
    const double elapsedMillis = intervalElapsedSeconds * 1000;
    const uint64_t elapsedMachTime = (elapsedMillis *
                                      (kOneMillion * s_timebase_info.denom)) /
                                        s_timebase_info.numer;
    return self.timeStartupMach + elapsedMachTime;
}

- (BOOL)isParticipatingInSample
{
    return self.isPartOfSample;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    // turn off our timer if we have one
    if (self.timer) {
        [self.timer cancel];
        self.timer = nil;
    }
}

- (void)applicationDidReceiveMemoryWarning:(NSNotification *)notification
{
    ApigeeLogDebug(kApigeeMonitoringClientTag, @"app received memory warning");
    
    // throw away any performance metrics that we have to reduce the
    // memory footprint
    [[ApigeeQueue networkMetricsQueue] removeAllObjects];
}

- (void)applicationSignificantTimeChange:(NSNotification *)notification
{
    //TODO: is there anything we need to do on this notification??
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    // is monitoring not disabled?
    if (!self.activeSettings.monitoringDisabled) {
        // re-establish our timer
        self.timer = [[ApigeeIntervalTimer alloc] init];
        [self.timer fireOnInterval:self.activeSettings.agentUploadIntervalInSeconds
                            target:self
                          selector:@selector(timerFired)
                           repeats:NO];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    // turn off our timer if we have one
    if (self.timer) {
        [self.timer cancel];
        self.timer = nil;
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    // turn off our timer if we have one
    if (self.timer) {
        [self.timer cancel];
        self.timer = nil;
    }
}

- (BOOL)isDeviceNetworkConnected
{
    if (self.activeSettings) {
        return (Apigee_NotReachable != self.activeSettings.activeNetworkStatus);
    }
    
    return NO;
}

- (NSString*)dictionaryKeyForCategory:(NSString*)categoryName key:(NSString*)keyName
{
    return [NSString stringWithFormat:@"%@:%@", categoryName, keyName];
}

- (NSArray*)customConfigPropertyKeysForCategory:(NSString*)category
{
    return [self.dictCustomConfigKeysByCategory valueForKey:category];
}

- (NSString*)customConfigPropertyValueForKey:(NSString*)key
{
    return [self.dictCustomConfigValuesByKey valueForKey:key];
}

- (NSString*)customConfigPropertyValueForKey:(NSString *)key
                                 forCategory:(NSString*)categoryName
{
    NSString *dictKey = [self dictionaryKeyForCategory:categoryName key:key];
    return [self.dictCustomConfigValuesByCategoryAndKey valueForKey:dictKey];
}

- (BOOL)uploadAnalytics
{
    BOOL analyticsUploaded = NO;
    
    if(self.isInitialized && self.isActive)
    {
        // are we currently connected to network?
        if( [self isDeviceNetworkConnected] ) {
            ApigeeLogInfo(kApigeeMonitoringClientTag, @"Manually uploading analytics now");
            analyticsUploaded = [self uploadEvents];
        } else {
            ApigeeLogInfo(kApigeeMonitoringClientTag, @"uploadAnalytics called, device not connected to network");
        }
    } else {
        ApigeeLogInfo(kApigeeMonitoringClientTag, @"Configuration was not able to initialize. Not initiating analytics send loop");
    }
    
    return analyticsUploaded;
}

- (BOOL)refreshConfiguration
{
    BOOL configurationUpdated = NO;
    
    if(self.isInitialized && self.isActive)
    {
        // are we currently connected to network?
        if( [self isDeviceNetworkConnected] ) {
            ApigeeLogInfo(kApigeeMonitoringClientTag, @"Manually refreshing configuration now");
            [self reset];
            [self updateConfig];
            [self applyConfig];
            configurationUpdated = YES;
        } else {
            ApigeeLogInfo(kApigeeMonitoringClientTag, @"refreshConfiguration called, device not connected to network");
        }
    } else {
        ApigeeLogInfo(kApigeeMonitoringClientTag, @"Configuration was not able to initialize. Unable to refresh.");
    }
    
    return configurationUpdated;
}

- (BOOL)recordNetworkSuccessForUrl:(NSString*)url
                         startTime:(NSDate*)startTime
                           endTime:(NSDate*)endTime
{
    BOOL metricsRecorded = NO;
    
    if(self.isInitialized && self.isActive)
    {
        ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
        [entry populateWithURLString:url];
        [entry populateStartTime:startTime ended:endTime];
    
        [ApigeeQueue recordNetworkEntry:entry];
        
        metricsRecorded = YES;
    } else {
        ApigeeLogWarn(kApigeeMonitoringClientTag, @"Unable to record network metrics. Agent not initialized or active");
    }
    
    return metricsRecorded;
}

- (BOOL)recordNetworkFailureForUrl:(NSString*)url
                         startTime:(NSDate*)startTime
                           endTime:(NSDate*)endTime
                             error:(NSString*)errorDescription
{
    BOOL metricsRecorded = NO;
    
    if(self.isInitialized && self.isActive)
    {
        ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
        [entry populateWithURLString:url];
        [entry populateStartTime:startTime ended:endTime];
    
        // error occurred
        entry.numErrors = @"1";
        entry.transactionDetails = errorDescription;
    
        [ApigeeQueue recordNetworkEntry:entry];
        
        metricsRecorded = YES;
    } else {
        ApigeeLogWarn(kApigeeMonitoringClientTag, @"Unable to record network metrics. Agent not initialized or active");
    }
    
    return metricsRecorded;
}

- (NSString*)baseURLPath
{
    return [NSString stringWithFormat:@"%@/apm/",
            [self baseServerURL]];
}

- (BOOL)addUploadListener:(id<ApigeeUploadListener>)uploadListener
{
    BOOL listenerAdded = NO;
    
    if( self.listListeners ) {
        [self.listListeners addObject:uploadListener];
        listenerAdded = YES;
    }
    
    return listenerAdded;
}

- (BOOL)removeUploadListener:(id<ApigeeUploadListener>)uploadListener
{
    BOOL listenerRemoved = NO;
    
    if( self.listListeners ) {
        if( [self.listListeners containsObject:uploadListener] ) {
            [self.listListeners removeObject:uploadListener];
            listenerRemoved = YES;
        }
    }
    
    return listenerRemoved;
}

@end


@implementation ApigeeMonitoringClient (NetworkActivityTracking)

- (void) updateLastNetworkTransmissionTime:(NSString*) networkTransmissionTime
{
    if ([networkTransmissionTime length] > 0) {
        // the time is represented in milliseconds as a string
        
        // get the value as a 64-bit integer
        int64_t msNetworkTransTime = [networkTransmissionTime longLongValue];
        
        // convert that to an NSDate
        NSDate *dateNetworkTransTime = [NSDate dateFromMilliseconds:msNetworkTransTime];
        
        //NSLog(@"updating last network transmission time to %@", dateNetworkTransTime);
        
        // convert date to mach time
        uint64_t machTime = [self dateToMachTime:dateNetworkTransTime];
        
        self.lastNetworkTransmissionTime = machTime;
    }
}

@end

