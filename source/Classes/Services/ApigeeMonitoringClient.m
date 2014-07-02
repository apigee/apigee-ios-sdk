/*
 * Copyright 2014 Apigee Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <asl.h>

#include <time.h>
#include <objc/runtime.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>

#import "ApigeeCrashReporter.h"
#import "NSString+UUID.h"
#import "NSDate+Apigee.h"
#import "ApigeeSystemLogger.h"
#import "ApigeeReachability.h"
#import "ApigeeOpenUDID.h"

#import "ApigeeSystemLogger.h"
#import "ApigeeLogger.h"
#import "ApigeeIntervalTimer.h"

#import "ApigeeLogEntry.h"
#import "ApigeeNetworkEntry.h"
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
#import "ApigeeJsonUtils.h"

#import "ApigeeNSURLSessionSupport.h"
#import "ApigeeNSURLSessionDataTaskInfo.h"

#import "ApigeeUIEventManager.h"
#import "ApigeeUIEventScreenVisibility.h"
#import "ApigeeUIEventButtonPress.h"
#import "ApigeeUIEventSegmentSelected.h"
#import "ApigeeUIEventSwitchToggled.h"
#import "NSURLConnection+Apigee.h"



static ApigeeMonitoringClient *singletonInstance = nil;

static const BOOL kDefaultUploadCrashReports    = YES;
static const BOOL kDefaultInterceptNetworkCalls = YES;

static NSString* kApigeeMonitoringClientTag = @"MOBILE_AGENT";


static bool AmIBeingDebugged(void)
{
    int                 mib[4];
    struct kinfo_proc   info;
    
    info.kp_proc.p_flag = 0;
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    
    size_t size = sizeof(info);
    const int rc = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    
    if ( rc == 0 ) {
        // We're being debugged if the P_TRACED flag is set.
        return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
    } else {
        return false;
    }
}




@interface ApigeeMonitoringClient ()

@property (strong) NSString *appName;

@property (strong) ApigeeReachability *reachability;

@property (assign) aslclient client;

@property (strong) ApigeeIntervalTimer* timer;

@property (assign) BOOL swizzledNSURLConnection;
@property (assign) BOOL swizzledNSURLSession;
@property (assign) BOOL sentStartingSessionData;
@property (assign) BOOL isPartOfSample;
@property (assign) BOOL isInitialized;
@property (assign) BOOL isActive;

@property (strong) NSDate *startupTime;
@property (assign) CFTimeInterval startupTimeSeconds;
@property (assign) CFTimeInterval lastUploadTime;
@property (assign) CFTimeInterval lastNetworkTransmissionTime;

@property (strong) NSMutableDictionary *dictCustomConfigKeysByCategory;
@property (strong) NSMutableDictionary *dictCustomConfigValuesByKey;
@property (strong) NSMutableDictionary *dictCustomConfigValuesByCategoryAndKey;

@property (strong) NSMutableArray *listListeners;


@property (strong) ApigeeDataClient *dataClient;

@property (strong) NSMutableDictionary *dictRegisteredDataTasks;
@property (strong) NSRecursiveLock *lockDataTasks;

@property (assign) BOOL autoPromoteLoggedErrors;
@property (assign) BOOL crashReportingEnabled;
@property (assign) BOOL autoInterceptNetworkCalls;
@property (assign) BOOL interceptNSURLSessionCalls;
@property (assign) BOOL showDebuggingInfo;
@property (assign) BOOL crashReporterInitialized;
@property (assign) BOOL monitoringPaused;
@property (assign) BOOL locationServicesStarted;
@property (copy, nonatomic) NSString* customUploadUrl;
@property (assign, nonatomic) BOOL alwaysUploadCrashReports;

@property (assign, nonatomic) ApigeeNetworkStatus activeNetworkStatus;


- (void) retrieveCachedConfig;
- (BOOL) retrieveServerConfig;
- (void) populateCustomConfigData;
- (BOOL) isMonitoringDisabled;
- (void) startMonitoring;
- (BOOL) uploadEvents;
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
@synthesize startupTimeSeconds;
@synthesize lastUploadTime;
@synthesize lastNetworkTransmissionTime;

@synthesize appIdentification;
@synthesize dataClient;

@synthesize autoPromoteLoggedErrors;
@synthesize crashReportingEnabled;
@synthesize autoInterceptNetworkCalls;
@synthesize interceptNSURLSessionCalls;
@synthesize showDebuggingInfo;
@synthesize crashReporterInitialized;
@synthesize monitoringPaused;
@synthesize locationServicesStarted;
@synthesize activeNetworkStatus;
@synthesize alwaysUploadCrashReports;

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

- (void)checkReachability
{
    self.activeNetworkStatus = [self.reachability currentReachabilityStatus];
    if (self.activeSettings) {
        self.activeSettings.activeNetworkStatus = self.activeNetworkStatus;
    }
}

- (BOOL)isAbleToSendDataToServer
{
    if (self.activeSettings) {
        return (self.activeSettings.instaOpsApplicationId != nil) &&
                ([self.activeSettings.orgName length] > 0) &&
                ([self.activeSettings.appName length] > 0);
    }
    
    return NO;
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
                                   options:nil];
}

- (id) initWithAppIdentification:(ApigeeAppIdentification*)theAppIdentification
                      dataClient:(ApigeeDataClient*)theDataClient
                  crashReporting: (BOOL) isCrashReportingEnabled
           interceptNetworkCalls: (BOOL) autoInterceptCalls
                  uploadListener: (id<ApigeeUploadListener>)uploadListener
{
    ApigeeMonitoringOptions* options = [[ApigeeMonitoringOptions alloc] init];
    options.crashReportingEnabled = isCrashReportingEnabled;
    options.interceptNetworkCalls = autoInterceptCalls;
    options.uploadListener = uploadListener;
    
    return [self initWithAppIdentification:theAppIdentification
                                dataClient:theDataClient
                                   options:options];
}


- (id) initWithAppIdentification: (ApigeeAppIdentification*) theAppIdentification
                      dataClient: (ApigeeDataClient*) theDataClient
                  crashReporting: (BOOL) enabled
{
    ApigeeMonitoringOptions* options = [[ApigeeMonitoringOptions alloc] init];
    options.crashReportingEnabled = enabled;
    options.interceptNetworkCalls = kDefaultInterceptNetworkCalls;
    options.uploadListener = nil;

    return [self initWithAppIdentification:theAppIdentification
                                dataClient:theDataClient
                                   options:options];
}

- (id) initWithAppIdentification: (ApigeeAppIdentification*) theAppIdentification
                      dataClient: (ApigeeDataClient*) theDataClient
                  crashReporting: (BOOL) isCrashReportingEnabled
           interceptNetworkCalls: (BOOL) interceptCalls
{
    ApigeeMonitoringOptions* options = [[ApigeeMonitoringOptions alloc] init];
    options.crashReportingEnabled = isCrashReportingEnabled;
    options.interceptNetworkCalls = interceptCalls;
    options.uploadListener = nil;

    return [self initWithAppIdentification:theAppIdentification
                                dataClient:theDataClient
                                   options:options];
}

- (id) initWithAppIdentification: (ApigeeAppIdentification*) theAppIdentification
                      dataClient: (ApigeeDataClient*) theDataClient
                         options:(ApigeeMonitoringOptions*)monitoringOptions

{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    BOOL performAutomaticUIEventTracking = NO;
    
    self.crashReportingEnabled = YES;
    self.autoInterceptNetworkCalls = YES;
    self.showDebuggingInfo = NO;
    id<ApigeeUploadListener> uploadListener = nil;
    
    if( monitoringOptions ) {
        self.crashReportingEnabled = monitoringOptions.crashReportingEnabled;
        self.autoInterceptNetworkCalls = monitoringOptions.interceptNetworkCalls;
        uploadListener = monitoringOptions.uploadListener;
        self.autoPromoteLoggedErrors = monitoringOptions.autoPromoteLoggedErrors;
        self.interceptNSURLSessionCalls = monitoringOptions.interceptNSURLSessionCalls;
        self.showDebuggingInfo = monitoringOptions.showDebuggingInfo;
        self.customUploadUrl = monitoringOptions.customUploadUrl;
        performAutomaticUIEventTracking = monitoringOptions.performAutomaticUIEventTracking;
        self.alwaysUploadCrashReports = monitoringOptions.alwaysUploadCrashReports;
    } else {
        self.autoPromoteLoggedErrors = YES;
        self.interceptNSURLSessionCalls = NO;
        self.alwaysUploadCrashReports = YES;
    }
    
    self.appIdentification = theAppIdentification;
    self.dataClient = theDataClient;
    
    self.isActive = NO;
    self.isInitialized = NO;
    self.monitoringPaused = NO;
    self.locationServicesStarted = NO;
    self.crashReporterInitialized = NO;
    self.startupTimeSeconds = CACurrentMediaTime();
    self.startupTime = [NSDate date];
    
    singletonInstance = self;
    
    self.lockDataTasks = [[NSRecursiveLock alloc] init];
    self.dictRegisteredDataTasks = [[NSMutableDictionary alloc] init];
    
    
    self.swizzledNSURLConnection = NO;
    self.swizzledNSURLSession = NO;
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
    
    if (performAutomaticUIEventTracking) {
        ApigeeUIEventManager* uiEventManager = [ApigeeUIEventManager sharedInstance];
        [uiEventManager setUpApigeeSwizzling];
        [uiEventManager addUIEventListener:self];
    }
    
    self.reachability = [ApigeeReachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    [self checkReachability];
    
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

    // fire off the remainder of our startup logic asynchronously so we
    // don't block the UI
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self retrieveCachedConfig];
        [self retrieveServerConfig];
        if (![self isMonitoringDisabled]) {
            [self startMonitoring];
        }
    });
    
    return self;
}

- (void)printDebugMessage:(NSString*)debugMessage
{
    if (self.showDebuggingInfo) {
        NSLog(@"%@", debugMessage);
    }
}

- (void)recordNetworkEntry:(ApigeeNetworkEntry*)entry
{
    if (![self monitoringPaused]) {
        if (self.showDebuggingInfo) {
            [self printDebugMessage:@"recording network entry:"];
            [entry debugPrint];
        }
    
        [ApigeeQueue recordNetworkEntry:entry];
    } else {
        NSLog(@"Not recording network metrics -- paused");
    }
}

- (void) injectApigeeHttpHeaders :(NSMutableURLRequest*) mutableRequest;
{
     //ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    [mutableRequest addValue: [[self appIdentification] organizationId] forHTTPHeaderField:@"X-Apigee-Client-Org-Name"];
    [mutableRequest addValue: [[self appIdentification] applicationId] forHTTPHeaderField:@"X-Apigee-Client-App-Name"];
    [mutableRequest addValue: [self apigeeDeviceId ] forHTTPHeaderField:@"X-Apigee-Device-Id"];
    [mutableRequest addValue: [[NSUserDefaults standardUserDefaults] objectForKey:@"kApigeeSessionIdKey"] forHTTPHeaderField:@"X-Apigee-Session-Id"];
    [mutableRequest addValue: [NSString  uuid] forHTTPHeaderField:@"X-Apigee-Client-Request-Id"];
}


- (void) retrieveCachedConfig
{
    NSError *error;
    ApigeeCompositeConfiguration* config =
        [ApigeeCachedConfigUtil getConfiguration:&error];
        
    if (config) {
        self.activeSettings = [[ApigeeActiveSettings alloc] initWithConfig:config];
    }
}

- (BOOL) retrieveServerConfig
{
    BOOL retrievalOfServerConfigSucceeded = NO;
    
    if (self.showDebuggingInfo) {
        [self printDebugMessage:@"retrieving configuration from server"];
    }
    
    NSString* jsonConfig = [self retrieveConfigFromServer];
    if( jsonConfig != nil ) {
        
        BOOL willUpdateCacheFromServer = YES;  // until we find out otherwise
        
        NSDictionary* configDict = [ApigeeJsonUtils decode:jsonConfig];
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
                    
                    retrievalOfServerConfigSucceeded = YES;
                    
                    NSDate* serverLastModifiedDate = [NSDate dateFromMilliseconds:lastModifiedDateValue];
                    
                    if (self.showDebuggingInfo) {
                        [self printDebugMessage:[NSString stringWithFormat:@"lastModifiedDate = %@",
                                                 serverLastModifiedDate]];
                    }
                    
                    if( self.activeSettings && self.activeSettings.appLastModifiedDate ) {
                        if (self.showDebuggingInfo) {
                            [self printDebugMessage:[NSString stringWithFormat:@"cache lastModifiedDate = %@",
                                                     self.activeSettings.appLastModifiedDate]];
                        }
                        
                        if( ! [self.activeSettings.appLastModifiedDate isEqualToDate:serverLastModifiedDate] ) {
                            NSDate* laterConfigDate = [self.activeSettings.appLastModifiedDate laterDate:serverLastModifiedDate];
                            
                            // is configuration from server newer than what we currently have?
                            if( laterConfigDate == self.activeSettings.appLastModifiedDate  ) {
                                willUpdateCacheFromServer = NO;
                                
                                if (self.showDebuggingInfo) {
                                    [self printDebugMessage:@"lastModifiedDate value for cache is more recent -- not updating cache"];
                                }
                            } else {
                                if (self.showDebuggingInfo) {
                                    [self printDebugMessage:@"lastModifiedDate value from server is more recent -- updating cache"];
                                }
                            }
                        } else {
                            // server config date and local config dates match -- no need to update
                            willUpdateCacheFromServer = NO;
                            
                            if (self.showDebuggingInfo) {
                                [self printDebugMessage:@"lastModifiedDate values for server and cache match -- not updating cache"];
                            }
                        }
                    }
                } else {
                    if (self.showDebuggingInfo) {
                        [self printDebugMessage:[NSString stringWithFormat:@"unrecognized value for lastModifiedDate '%@'", lastModifedDate]];
                    }
                }
            } else {
                if (self.showDebuggingInfo) {
                    [self printDebugMessage:@"server config does not contain 'lastModifiedDate'"];
                }
            }
        } else {
            SystemError(kApigeeMonitoringClientTag, @"parsing of config from server returned nil");
        }
        
        if( willUpdateCacheFromServer ) {
            [self saveConfig:jsonConfig];
            NSError* error = nil;
            ApigeeCompositeConfiguration* config =
                [ApigeeCachedConfigUtil parseConfiguration:jsonConfig
                                                     error:&error];
            if (config) {
                self.activeSettings =
                    [[ApigeeActiveSettings alloc] initWithConfig:config];
            }
        }
    } else {
        // request to read config from server failed
        SystemError(kApigeeMonitoringClientTag, @"Unable to read configuration from server");
    }
    
    return retrievalOfServerConfigSucceeded;
}

- (BOOL) isMonitoringDisabled
{
    return (self.activeSettings && self.activeSettings.monitoringDisabled);
}

- (void) populateCustomConfigData
{
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
}

- (void)setUpCrashReporting
{
    if (AmIBeingDebugged()) {
        self.crashReportingEnabled = NO;
        ApigeeLogWarnMessage(kApigeeMonitoringClientTag, @"Disabling crash reporting under debugger");
    }
    
    if (self.crashReportingEnabled) {
        
        // look for other crash reporters that may be present
        NSString* otherCrashReporterClasses =
        @"PLCrashReporter|BITCrashManager|BugSenseCrashController|Crittercism|KSCrash|CrashController";
        NSArray* listOtherCrashReporterClasses = [otherCrashReporterClasses componentsSeparatedByString:@"|"];
        
        for( NSString* crashReporterClass in listOtherCrashReporterClasses )
        {
            Class clsCrashReporter = NSClassFromString(crashReporterClass);
            if (nil != clsCrashReporter) {
                ApigeeLogWarnMessage(kApigeeMonitoringClientTag, @"Multiple crash reporters detected");
                break;
            }
        }
        
        if( ! self.crashReporterInitialized ) {
            NSError *error = nil;

            if (![self enableCrashReporter:&error] || (nil !=error)) {
                ApigeeLogAssert(kApigeeMonitoringClientTag, @"Failed to start the crash reporter: %@", error);
            } else {
                self.crashReporterInitialized = YES;
            }
        }
        
        if (self.crashReporterInitialized) {
            if ([self hasPendingCrashReports]) {
                [self uploadCrashReports];
            }
        }

    } else {
        ApigeeLogInfoMessage(kApigeeMonitoringClientTag, @"Crash reporting disabled");
    }
}

- (void)cancelTimer
{
    if (self.timer) {
        [self.timer cancel];
        self.timer = nil;
    }
}

- (void)establishTimer
{
    self.timer = [[ApigeeIntervalTimer alloc] init];
    [self.timer fireOnInterval:self.activeSettings.agentUploadIntervalInSeconds
                        target:self
                      selector:@selector(timerFired)
                       repeats:NO];
}

- (void)startMonitoring
{
    @synchronized (self) {
        
        // clean up any existing stuff that may be left over from
        // earlier monitoring
        [self cancelTimer];
        
#if !(TARGET_IPHONE_SIMULATOR)
        if (self.activeSettings.locationCaptureEnabled && self.locationServicesStarted) {
            [[ApigeeLocationService defaultService] stopScan];
            self.locationServicesStarted = NO;
        }
#endif
        
        if ([self isMonitoringDisabled]) {
            SystemDebug(@"IO_Diagnostics",@"Monitoring disabled");
            return;
        }

        if (!self.activeSettings) {
            ApigeeLogErrorMessage(kApigeeMonitoringClientTag,@"No configuration available. Cannot start monitoring");
            return;
        }
        
        
        // Will monitoring be active for this device?
        
        //coin flip for sample rate
        const uint32_t r = arc4random_uniform(100);
        
        if (self.showDebuggingInfo) {
            NSString* debugMsg =
            [NSString stringWithFormat:@"configuration sampling rate=%ld",
             (long)self.activeSettings.samplingRate];
            [self printDebugMessage:debugMsg];
            debugMsg = [NSString stringWithFormat:@"coin flip result = %d",
                        r];
            [self printDebugMessage:debugMsg];
        }
        
        if (r < self.activeSettings.samplingRate) {
            self.isPartOfSample = YES;
            self.isActive = YES;
            ApigeeLogInfoMessage(kApigeeMonitoringClientTag, @"Configuration values applied");
        } else {
            self.isPartOfSample = NO;
            SystemDebug(@"IO_Diagnostics",@"Device not chosen for sample");
        }

        
        if ((isActive && self.isPartOfSample) || self.alwaysUploadCrashReports) {
            [self setUpCrashReporting];

            if (isActive && self.isPartOfSample) {
                // if we've never sent any data to server, do so now
                if (!self.sentStartingSessionData) {
                    [self timerFired];
                
                    if (autoInterceptNetworkCalls) {
                        [self enableInterceptedNetworkingCalls];
                    }
                } else {
                    [self establishTimer];
                }

// location capture is only available on real device
#if !(TARGET_IPHONE_SIMULATOR)
                if (self.activeSettings.locationCaptureEnabled) {
                    self.locationServicesStarted = YES;
                    [[ApigeeLocationService defaultService] startScan];
                }
#endif
                
            }
        }
        
        self.isInitialized = YES;
    }
    
    ApigeeLogInfoMessage(kApigeeMonitoringClientTag, @"INIT_AGENT");
}

#pragma mark - Property implementations

- (NSString*) apigeeDeviceId
{
    return [ApigeeOpenUDID value];
}

#pragma mark - System configuration

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
        
        if (self.showDebuggingInfo) {
            NSString* debugMsg = [NSString stringWithFormat:@"attempting to retrieve configuration from %@",
                                  [self configDownloadURL]];
            [self printDebugMessage:debugMsg];
        }
    
        NSData* responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
    
        if( nil != responseData ) {
            NSString* responseDataAsString = [[NSString alloc] initWithData:responseData
                                         encoding:NSUTF8StringEncoding];
            
            if (self.showDebuggingInfo) {
                [self printDebugMessage:@"configuration retrieved from server:"];
                [self printDebugMessage:responseDataAsString];
            }
            
            return responseDataAsString;
        } else {
            if( error != nil ) {
                NSString* errorMsg = [NSString stringWithFormat:@"Error retrieving config from server: %@",
                                      [error localizedDescription]];
                ApigeeLogErrorMessage(kApigeeMonitoringClientTag,errorMsg);
            } else {
                ApigeeLogErrorMessage(kApigeeMonitoringClientTag,
                               @"Unable to retrieve config from server");
            }
            return nil;
        }
    } else {
        ApigeeLogDebugMessage(kApigeeMonitoringClientTag, @"Unable to retrieve config from server, device not connected to network");
        return nil;
    }
}

- (void)timerFired
{
    if (self.monitoringPaused) {
        return;
    }
    
    if (!self.isPartOfSample) {
        return;
    }
    
    if (![self isAbleToSendDataToServer]) {
        ApigeeLogDebugMessage(kApigeeMonitoringClientTag, @"missing app identification - unable to send data to server");
        ApigeeLogDebugMessage(kApigeeMonitoringClientTag, @"attempting to retrieve configuration from server");
        [self retrieveServerConfig];
    }
    
    [self establishTimer];
    
    if ([self isAbleToSendDataToServer]) {
        dispatch_queue_t queue =
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            if (self.showDebuggingInfo) {
                [self printDebugMessage:@"attempting to upload data to server"];
            }
        
            [self uploadEvents];
        });
    } else {
        ApigeeLogDebugMessage(kApigeeMonitoringClientTag, @"unable to send data to server - no app identification");
    }
}

- (NSData*)postString:(NSString*)postBody toUrl:(NSString*)urlAsString contentType:(NSString*)contentType
{
    NSURL* url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    
    if( [contentType length] > 0 ) {
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    }
    
    if (self.showDebuggingInfo) {
        NSString* debugMsg = [NSString stringWithFormat:@"attempting to POST to %@",
                              urlAsString];
        [self printDebugMessage:debugMsg];
        [self printDebugMessage:postBody];
    }
    
    NSData* postData = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    NSString* postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:postData];
    
    NSURLResponse* response = nil;
    NSError* err = nil;
    
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&err];
    
    if( err != nil ) {
        ApigeeLogError(kApigeeMonitoringClientTag, @"%@",[err localizedDescription]);
    } else {
        if (self.showDebuggingInfo) {
            NSString* responseDataAsString =
                [[NSString alloc] initWithData:responseData
                                      encoding:NSUTF8StringEncoding];
            [self printDebugMessage:@"server response:"];
            [self printDebugMessage:responseDataAsString];
        }
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
    
    if (self.showDebuggingInfo) {
        NSString* debugMsg = [NSString stringWithFormat:@"attempting to PUT to %@",
                              urlAsString];
        [self printDebugMessage:debugMsg];
        [self printDebugMessage:postBody];
    }
    
    NSData* postData = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    NSString* postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:postData];
    
    NSURLResponse* response = nil;
    NSError* err = nil;
    
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&err];
    
    if( err != nil ) {
        ApigeeLogError(kApigeeMonitoringClientTag, @"%@",[err localizedDescription]);
    } else {
        if (self.showDebuggingInfo) {
            NSString* responseDataAsString =
                [[NSString alloc] initWithData:responseData
                                      encoding:NSUTF8StringEncoding];
            [self printDebugMessage:@"server response:"];
            [self printDebugMessage:responseDataAsString];
        }
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
    BOOL haveCrashReport = [[ApigeePLCrashReporter sharedReporter] hasPendingCrashReport];
    
    if (self.showDebuggingInfo) {
        [self printDebugMessage:@"crash report found from prior session"];
    }
    
    return haveCrashReport;
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
    
    if (![self isAbleToSendDataToServer]) {
        ApigeeLogDebugMessage(kApigeeMonitoringClientTag, @"missing app identification - unable to send data to server");
        return;
    }
    
    ApigeePLCrashReporter* crashReporter = [ApigeePLCrashReporter sharedReporter];
    NSError* error = nil;
    NSData* data = [crashReporter loadPendingCrashReportDataAndReturnError:&error];
    ApigeePLCrashReport *report = [[ApigeePLCrashReport alloc] initWithData:data error:&error];
    
    if (error) {
        SystemError(@"CrashReporter", @"Error loading crash report: %@", [error localizedDescription]);
        return;
    }
    
    NSString *log = [ApigeePLCrashReportTextFormatter stringValueForCrashReport:report
                                                                  withTextFormat:ApigeePLCrashReportTextFormatiOS];
    
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
        if ([self sendCrashNotification:fileName]) {
            [self printDebugMessage:@"crash report uploaded to server"];
            [crashReporter purgePendingCrashReport];
            [self printDebugMessage:@"crash report deleted from device"];
        } else {
            [self printDebugMessage:@"error: unable to upload crash report"];
        }
    } else {
        ApigeeLogAssertMessage(kApigeeMonitoringClientTag,
                        @"There was an error with the request to upload the crash report");
    }
}

- (BOOL) enableCrashReporter:(NSError**) error
{
    return [[ApigeePLCrashReporter sharedReporter] enableCrashReporterAndReturnError:error];
}

#pragma mark - Internal implementations

- (void) networkChanged:(NSNotification *) notice
{
    if (self.showDebuggingInfo) {
        [self printDebugMessage:@"network status changed"];
    }

    [self checkReachability];
    
    // do we have network connectivity?
    if ([self isDeviceNetworkConnected] && !self.isInitialized) {
        NSLog(@"uninitialized monitoring client. now have internet connectivity");
        NSLog(@"attempting initialization");
        if ([NSThread isMainThread]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if ([self retrieveServerConfig]) {
                    [self startMonitoring];
                }
            });
        } else {
            if ([self retrieveServerConfig]) {
                [self startMonitoring];
            }
        }
    }
}

- (BOOL)populateClientMetricsEnvelope:(NSMutableDictionary*)clientMetricsEnvelope
{
    if (self.activeSettings) {
        if (self.activeSettings.instaOpsApplicationId) {
            [clientMetricsEnvelope setObject:self.activeSettings.instaOpsApplicationId
                                      forKey:@"instaOpsApplicationId"];
        } else {
            ApigeeLogErrorMessage(kApigeeMonitoringClientTag, @"missing value for instaOpsApplicationId");
            return NO;
        }
        
        if (self.activeSettings.orgName) {
            [clientMetricsEnvelope setObject:self.activeSettings.orgName
                                      forKey:@"orgName"];
        } else {
            ApigeeLogErrorMessage(kApigeeMonitoringClientTag, @"missing value for orgName");
            return NO;
        }
        
        if (self.activeSettings.appName) {
            [clientMetricsEnvelope setObject:self.activeSettings.appName
                                      forKey:@"appName"];
        } else {
            ApigeeLogErrorMessage(kApigeeMonitoringClientTag, @"missing value for appName");
            return NO;
        }
        
        if (self.activeSettings.fullAppName) {
            [clientMetricsEnvelope setObject:self.activeSettings.fullAppName
                                      forKey:@"fullAppName"];
        }
    }
    
    [clientMetricsEnvelope setObject:[NSDate unixTimestampAsString] forKey:@"timeStamp"];
    
    return YES;
}

- (NSString*)metricsUploadURL
{
    return [NSString stringWithFormat:@"%@/apm/apmMetrics",
            [self baseServerURL]];
}

- (BOOL) uploadEvents
{
    @autoreleasepool {
        
        if (!self.activeSettings) {
            ApigeeLogWarnMessage(kApigeeMonitoringClientTag,@"activeSettings is nil, abandoning upload");
            return NO;
        }
        
        if (![self isAbleToSendDataToServer]) {
            ApigeeLogWarnMessage(kApigeeMonitoringClientTag, @"missing app identification fields needed to send data to server");
            return NO;
        }
        
        [self checkReachability];
        ApigeeNetworkStatus netStatus = self.activeNetworkStatus;
        
        // do we have network connectivity?
        if (Apigee_NotReachable == netStatus) {
            ApigeeLogVerboseMessage(kApigeeMonitoringClientTag, @"Cannot upload events -- no network connectivity");
            return NO;  // no connectivity, can't upload
        }

        // not on WiFi?
        if (netStatus != Apigee_ReachableViaWiFi) {
            // should we not upload when mobile (not on wifi)?
            if (!self.activeSettings.enableUploadWhenMobile) {
                ApigeeLogVerboseMessage(kApigeeMonitoringClientTag, @"Cannot upload events -- upload when on mobile network disallowed");
                return NO;
            }
        }
        
        NSArray *logEntries = [[ApigeeLogCompiler systemCompiler] compileLogsForSettings:self.activeSettings
                               autoPromoteErrors:self.autoPromoteLoggedErrors];
        
        NSArray *networkMetrics = [[ApigeeQueue networkMetricsQueue] dequeueAll];

        if (([logEntries count] == 0) &&
            ([networkMetrics count] == 0) &&
            self.sentStartingSessionData)
        {
            // no log entries, no network metrics, and we've already sent the
            // initial session data
            ApigeeLogVerboseMessage(kApigeeMonitoringClientTag, @"Not uploading events -- nothing to send");
            return NO;
        }
        
        BOOL isWiFi = (self.activeNetworkStatus == Apigee_ReachableViaWiFi);

        ApigeeSessionMetrics *sessionMetrics =
            [[ApigeeSessionMetricsCompiler systemCompiler] compileMetricsForSettings:self.activeSettings
                                                                              isWiFi:isWiFi];
    
        NSMutableDictionary *clientMetricsEnvelope = [NSMutableDictionary dictionary];
        if (![self populateClientMetricsEnvelope:clientMetricsEnvelope]) {
            ApigeeLogWarnMessage(kApigeeMonitoringClientTag, @"Unable to populate client metrics envelope");
            return NO;
        }

        NSError* error = nil;

        NSArray* networkMetricsList = [ApigeeNetworkEntry toDictionaries:networkMetrics];
        
        //NSString* jsonNetworkMetrics = [ApigeeJsonUtils encode:networkMetricsList error:&error];
        //ApigeeLogVerboseMessage(@"DEBUG", jsonNetworkMetrics);
        
        
        [clientMetricsEnvelope setObject:[ApigeeLogEntry toDictionaries:logEntries] forKey:@"logs"];
        [clientMetricsEnvelope setObject:networkMetricsList forKey:@"metrics"];
        [clientMetricsEnvelope setObject:[sessionMetrics asDictionary] forKey:@"sessionMetrics"];
    
        NSString *json = [ApigeeJsonUtils encode:clientMetricsEnvelope error:&error];
        
        //ApigeeLogVerboseMessage(@"DEBUG",json);
        
        if( json != nil ) {
            BOOL reachedServerSuccessfully = NO;
            
            NSData* responseData = nil;
            
            if ([self.customUploadUrl length] > 0) {
                responseData = [self postString:json
                                          toUrl:self.customUploadUrl];
            } else {
                responseData = [self postString:json
                                          toUrl:[self metricsUploadURL]];
            }
            
            if( (nil != responseData) && ([responseData length] > 0) ) {
                
                NSString *responseDataAsString =
                    [[NSString alloc] initWithData:responseData
                                          encoding:NSUTF8StringEncoding];
                NSDictionary *jsonResponse =
                    [ApigeeJsonUtils decode:responseDataAsString];
                
                NSString* serverResponseMessage =
                    [jsonResponse valueForKey:@"message"];
                NSString* lowerResponseMessage = [serverResponseMessage lowercaseString];
                if ([lowerResponseMessage hasPrefix:@"successfully sent"]) {
                    reachedServerSuccessfully = YES;
                    
                    ApigeeLogVerboseMessage(kApigeeMonitoringClientTag,responseDataAsString);
                    
                    if (!self.sentStartingSessionData) {
                        self.sentStartingSessionData = YES;
                    }

                    // let our listeners know
                    if( self.listListeners && ([self.listListeners count] > 0) ) {
                        for( id<ApigeeUploadListener> listener in self.listListeners ) {
                            [listener onUploadMetrics:json];
                        }
                    }

                } else {
                    NSString* errorMessage = [NSString stringWithFormat:@"error: %@",
                                              responseDataAsString];
                    ApigeeLogVerboseMessage(kApigeeMonitoringClientTag,errorMessage);
                }
            
                self.lastUploadTime = CACurrentMediaTime();
            
                //[ApigeeLogCompiler refreshUploadTimestamp];
            
                return reachedServerSuccessfully;
            } else {
                NSLog(@"error: unable to send data to server");
                return NO;
            }
        } else {
            NSLog( @"error: unable to encode metrics to json, not sending to server. %@", clientMetricsEnvelope );
            if( error != nil ) {
                NSLog( @"error: %@", [error localizedDescription]);
            } else {
                NSLog( @"no error given");
            }
            return NO;
        }
    }
}

- (BOOL) sendCrashNotification:(NSString *) fileName
{
    if (![self isAbleToSendDataToServer]) {
        ApigeeLogWarnMessage(kApigeeMonitoringClientTag, @"missing app identification fields needed to send data to server");
        return NO;
    }

    NSString* nowTimestamp = [NSDate unixTimestampAsString];
    
    ApigeeLogEntry *logEntry = [[ApigeeLogEntry alloc] init];
    logEntry.timeStamp = nowTimestamp;
    logEntry.tag = @"CRASH";
    logEntry.logMessage = fileName;
    logEntry.logLevel = @"A"; // assert
    
    [self checkReachability];
    
    BOOL isWiFi = (self.activeNetworkStatus == Apigee_ReachableViaWiFi);

    ApigeeSessionMetrics *sessionMetrics =
        [[ApigeeSessionMetricsCompiler systemCompiler] compileMetricsForSettings:self.activeSettings
                                                                          isWiFi:isWiFi];
    NSArray *logEntries = [NSArray arrayWithObject:logEntry];

    NSMutableDictionary *clientMetricsEnvelope = [NSMutableDictionary dictionary];
    
    if (![self populateClientMetricsEnvelope:clientMetricsEnvelope]) {
        ApigeeLogWarnMessage(kApigeeMonitoringClientTag, @"Unable to populate client metrics envelope");
        return NO;
    }
    
    [clientMetricsEnvelope setObject:[ApigeeLogEntry toDictionaries:logEntries] forKey:@"logs"];
    [clientMetricsEnvelope setObject:[sessionMetrics asDictionary] forKey:@"sessionMetrics"];

    NSError* error = nil;
    NSString *json = [ApigeeJsonUtils encode:clientMetricsEnvelope error:&error];
    
    if (json != nil) {
        if( nil != [self postString:json
                              toUrl:[self metricsUploadURL]] ) {
            self.lastUploadTime = CACurrentMediaTime();
            SystemAssert(@"Crash Log", @"Crash notification sent for %@", fileName);
            return YES;
        }
    } else {
        NSLog( @"error: unable to encode crash notification to JSON. %@", clientMetricsEnvelope );
        if (error != nil) {
            NSLog( @"error: encoding crash report payload: %@", [error localizedDescription]);
        } else {
            NSLog( @"no error given");
        }
    }
    
    return NO;
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
}

- (void) enableInterceptedNetworkingCalls
{
    if (!self.activeSettings.monitoringDisabled && !self.swizzledNSURLConnection) {

        if (self.showDebuggingInfo) {
            [self printDebugMessage:@"swizzling NSURLConnection methods"];
        }
        
        [NSURLConnection apigeeSwizzlingSetup];
    
        self.swizzledNSURLConnection = YES;
        
        if (self.interceptNSURLSessionCalls) {
        
            // swizzle NSURLSession if we're on iOS 7.0 or later
            Class clsNSURLSession = NSClassFromString(@"NSURLSession");
        
            if( clsNSURLSession != nil )  // iOS 7.0 or later?
            {
                if (self.showDebuggingInfo) {
                    [self printDebugMessage:@"swizzling NSURLSession methods"];
                }
                
                self.swizzledNSURLSession =
                    [ApigeeNSURLSessionSupport setupAtStartup];
            }
        }
    }
}

- (BOOL) isNSURLConnectionIntercepted
{
    return self.swizzledNSURLConnection;
}

- (NSDate*)timeStartup
{
    if (self.isInitialized) {
        return self.startupTime;
    } else {
        return nil;
    }
}

- (CFTimeInterval)timeStartupSeconds
{
    if (self.isInitialized) {
        return self.startupTimeSeconds;
    } else {
        return 0;
    }
}

- (CFTimeInterval)timeLastUpload
{
    if (self.isInitialized) {
        return self.lastUploadTime;
    } else {
        return 0;
    }
}

- (CFTimeInterval)timeLastNetworkTransmission
{
    if (self.isInitialized) {
        return self.lastNetworkTransmissionTime;
    } else {
        return 0;
    }
}

- (BOOL)isParticipatingInSample
{
    if (self.isInitialized) {
        return self.isPartOfSample;
    } else {
        return NO;  // at least not yet
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    // turn off our timer if we have one
    [self cancelTimer];
}

- (void)applicationDidReceiveMemoryWarning:(NSNotification *)notification
{
    if (self.isInitialized) {
        ApigeeLogDebugMessage(kApigeeMonitoringClientTag, @"app received memory warning");
    
        // throw away any performance metrics that we have to reduce the
        // memory footprint
        [[ApigeeQueue networkMetricsQueue] removeAllObjects];
    }
}

- (void)applicationSignificantTimeChange:(NSNotification *)notification
{
    //TODO: is there anything we need to do on this notification??
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    if (self.isInitialized) {
        // is monitoring not disabled?
        if (!self.activeSettings.monitoringDisabled) {
            // re-establish our timer
            [self establishTimer];
        }
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    // Having location services (capture location) on somehow causes
    // this method to be called and shuts down our uploads to the
    // server. Canceling of our timer is being commented out -- we
    // still have other lifecycle methods that are called when app
    // is put in background.
    
    // turn off our timer if we have one
    //[self cancelTimer];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    // turn off our timer if we have one
    [self cancelTimer];
}

- (BOOL)isDeviceNetworkConnected
{
    return (Apigee_NotReachable != self.activeNetworkStatus);
}

- (NSString*)dictionaryKeyForCategory:(NSString*)categoryName key:(NSString*)keyName
{
    return [NSString stringWithFormat:@"%@:%@", categoryName, keyName];
}

- (NSArray*)customConfigPropertyKeysForCategory:(NSString*)category
{
    if (self.isInitialized) {
        return [self.dictCustomConfigKeysByCategory valueForKey:category];
    } else {
        return nil;
    }
}

- (NSString*)customConfigPropertyValueForKey:(NSString*)key
{
    if (self.isInitialized) {
        return [self.dictCustomConfigValuesByKey valueForKey:key];
    } else {
        return nil;
    }
}

- (NSString*)customConfigPropertyValueForKey:(NSString *)key
                                 forCategory:(NSString*)categoryName
{
    if (self.isInitialized) {
        NSString *dictKey = [self dictionaryKeyForCategory:categoryName key:key];
        return [self.dictCustomConfigValuesByCategoryAndKey valueForKey:dictKey];
    } else {
        return nil;
    }
}

- (BOOL)uploadMetrics
{
    BOOL metricsUploaded = NO;
    
    if(self.isInitialized && self.isActive)
    {
        // are we currently connected to network?
        if( [self isDeviceNetworkConnected] ) {
            ApigeeLogInfoMessage(kApigeeMonitoringClientTag, @"Manually uploading metrics now");
            metricsUploaded = [self uploadEvents];
        } else {
            ApigeeLogInfoMessage(kApigeeMonitoringClientTag, @"uploadMetrics called, device not connected to network");
        }
    } else {
        ApigeeLogInfoMessage(kApigeeMonitoringClientTag, @"Configuration was not able to initialize. Not uploading metrics.");
    }
    
    return metricsUploaded;
}

- (void)asyncUploadMetrics:(void (^)(BOOL))completionHandler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue,^{
        BOOL uploadSucceeded = [self uploadMetrics];
        
        if( completionHandler ) {
            dispatch_async(dispatch_get_main_queue(),^{
                completionHandler(uploadSucceeded);
            });
        }
    });
}

- (BOOL)refreshConfiguration
{
    BOOL configurationUpdated = NO;
    
    if(self.isInitialized && self.isActive)
    {
        // are we currently connected to network?
        if( [self isDeviceNetworkConnected] ) {
            ApigeeLogInfoMessage(kApigeeMonitoringClientTag, @"Manually refreshing configuration now");
            if ([self retrieveServerConfig]) {
                ApigeeLogDebugMessage(kApigeeMonitoringClientTag, @"Configuration retrieved, applying new configuration");
                [self startMonitoring];
                configurationUpdated = YES;
            } else {
                ApigeeLogDebugMessage(kApigeeMonitoringClientTag, @"Unable to retrieve configuration from server");
            }
        } else {
            ApigeeLogDebugMessage(kApigeeMonitoringClientTag, @"refreshConfiguration called, device not connected to network");
        }
    } else {
        ApigeeLogDebugMessage(kApigeeMonitoringClientTag, @"Configuration was not able to initialize. Unable to refresh.");
    }
    
    return configurationUpdated;
}

- (void)asyncRefreshConfiguration:(void (^)(BOOL))completionHandler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue,^{
        BOOL refreshSucceeded = [self refreshConfiguration];
        
        if( completionHandler ) {
            dispatch_async(dispatch_get_main_queue(),^{
                completionHandler(refreshSucceeded);
            });
        }
    });
}

- (BOOL)recordNetworkSuccessForUrl:(NSString*)url
                         startTime:(uint64_t)startTime
                           endTime:(uint64_t)endTime
{
    BOOL metricsRecorded = NO;
    
    if(self.isInitialized && self.isActive)
    {
        if (![self isPaused]) {
            ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
            [entry populateWithURLString:url];
            [entry populateStartTime:startTime ended:endTime];
    
            [self recordNetworkEntry:entry];
        
            metricsRecorded = YES;
        } else {
            NSLog(@"Not recording network metrics -- paused");
        }
    } else {
        ApigeeLogWarnMessage(kApigeeMonitoringClientTag, @"Unable to record network metrics. Agent not initialized or active");
    }
    
    return metricsRecorded;
}

- (BOOL)recordNetworkFailureForUrl:(NSString*)url
                         startTime:(uint64_t)startTime
                           endTime:(uint64_t)endTime
                             error:(NSString*)errorDescription
{
    BOOL metricsRecorded = NO;
    
    if(self.isInitialized && self.isActive)
    {
        if (![self isPaused]) {
            ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
            [entry populateWithURLString:url];
            [entry populateStartTime:startTime ended:endTime];
    
            // error occurred
            entry.numErrors = @"1";
            entry.transactionDetails = errorDescription;
    
            [self recordNetworkEntry:entry];
        
            metricsRecorded = YES;
        } else {
            NSLog(@"Not recording network metrics -- paused");
        }
    } else {
        ApigeeLogWarnMessage(kApigeeMonitoringClientTag, @"Unable to record network metrics. Agent not initialized or active");
    }
    
    return metricsRecorded;
}

- (NSString*)uniqueIdentifierForApp
{
    return [self.appIdentification uniqueIdentifier];
}

- (ApigeeAppIdentification*)appIdentification
{
    return appIdentification;
}

- (NSString*)baseURLPath
{
    return [NSString stringWithFormat:@"%@/apm/",
            [self baseServerURL]];
}

- (BOOL)addUploadListener:(id<ApigeeUploadListener>)uploadListener
{
    BOOL listenerAdded = NO;
    
    if (self.isInitialized) {
        if (uploadListener != nil) {
            if (!self.listListeners) {
                self.listListeners = [[NSMutableArray alloc] init];
            }
        
            [self.listListeners addObject:uploadListener];
            listenerAdded = YES;
            
            if (self.showDebuggingInfo) {
                [self printDebugMessage:@"added upload listener"];
            }
        } else {
            [self printDebugMessage:@"not adding upload listener (listener is nil)"];
        }
    } else {
        [self printDebugMessage:@"not adding upload listener (monitoring client not initialized successfully)"];
    }
    
    return listenerAdded;
}

- (BOOL)removeUploadListener:(id<ApigeeUploadListener>)uploadListener
{
    BOOL listenerRemoved = NO;
    
    if (self.isInitialized) {
        if( self.listListeners ) {
            if( [self.listListeners containsObject:uploadListener] ) {
                [self.listListeners removeObject:uploadListener];
                listenerRemoved = YES;
            } else {
                [self printDebugMessage:@"not removing upload listener (not found)"];
            }
        } else {
            [self printDebugMessage:@"not removing upload listener (none registered)"];
        }
    } else {
        [self printDebugMessage:@"not removing upload listener (monitoring client not initialized successfully)"];
    }
    
    return listenerRemoved;
}

#pragma mark Pause - Resume

- (BOOL)isPaused
{
    return self.monitoringPaused;
}

- (void)pause
{
    if (![self isPaused]) {
        ApigeeLogInfoMessage(kApigeeMonitoringClientTag, @"PAUSE_AGENT");
        self.monitoringPaused = YES;
        [self cancelTimer];
        
        // discard all outstanding network metrics?
        [[ApigeeQueue networkMetricsQueue] dequeueAll];
    } else {
        ApigeeLogVerboseMessage(kApigeeMonitoringClientTag,@"Pause called when monitoring is already paused");
    }
}

- (void)resume
{
    if ([self isPaused]) {
        self.monitoringPaused = NO;
        ApigeeLogInfoMessage(kApigeeMonitoringClientTag, @"RESUME_AGENT");
        [self establishTimer];
    } else {
        ApigeeLogVerboseMessage(kApigeeMonitoringClientTag,@"Resume called when monitoring is not paused");
    }
}

#pragma mark Support for NSURLSession

- (id)generateIdentifierForDataTask
{
    NSDate* identifier = nil;
    
    if (self.isInitialized) {
        [self.lockDataTasks lock];
        identifier = [NSDate date];
        [self.lockDataTasks unlock];
    }
    
    return identifier;
}

- (void)registerDataTaskInfo:(ApigeeNSURLSessionDataTaskInfo*)dataTaskInfo
              withIdentifier:(id)identifier
{
    if (self.isInitialized) {
        [self.lockDataTasks lock];
        [self.dictRegisteredDataTasks setObject:dataTaskInfo
                                         forKey:identifier];
        [self.lockDataTasks unlock];
    }
}

- (ApigeeNSURLSessionDataTaskInfo*)dataTaskInfoForIdentifier:(id)identifier
{
    ApigeeNSURLSessionDataTaskInfo* sessionDataTaskInfo = nil;
    
    if (self.isInitialized) {
        [self.lockDataTasks lock];
        sessionDataTaskInfo = [self.dictRegisteredDataTasks objectForKey:identifier];
        [self.lockDataTasks unlock];
    }
        
    return sessionDataTaskInfo;
}

- (ApigeeNSURLSessionDataTaskInfo*)dataTaskInfoForTask:(NSURLSessionTask*)task
{
    ApigeeNSURLSessionDataTaskInfo* sessionDataTaskInfo = nil;
 
    if (self.isInitialized) {
        [self.lockDataTasks lock];
        NSArray* listAllValues = [self.dictRegisteredDataTasks allValues];
        for( ApigeeNSURLSessionDataTaskInfo* taskInfo in listAllValues )
        {
            if( taskInfo.sessionDataTask == task )
            {
                sessionDataTaskInfo = taskInfo;
                break;
            }
        }
        [self.lockDataTasks unlock];
    }
    
    return sessionDataTaskInfo;
}

- (void)removeDataTaskInfoForIdentifier:(id)identifier
{
    if (self.isInitialized) {
        [self.lockDataTasks lock];
        [self.dictRegisteredDataTasks removeObjectForKey:identifier];
        [self.lockDataTasks unlock];
    }
}

- (void)removeDataTaskInfoForTask:(NSURLSessionTask*)task
{
    if (self.isInitialized) {
        [self.lockDataTasks lock];
        NSArray* listAllValues = [self.dictRegisteredDataTasks allValues];
        for( ApigeeNSURLSessionDataTaskInfo* taskInfo in listAllValues )
        {
            if( taskInfo.sessionDataTask == task )
            {
                [self.dictRegisteredDataTasks removeObjectForKey:taskInfo.key];
                break;
            }
        }
        [self.lockDataTasks unlock];
    }
}

- (void)recordStartTimeForSessionDataTask:(NSURLSessionDataTask*)dataTask
{
    if (self.isInitialized) {
        if( dataTask )
        {
            [self.lockDataTasks lock];
            NSArray* listDataTaskInfoKeys = [self.dictRegisteredDataTasks allKeys];
    
            for( NSDate* date in listDataTaskInfoKeys )
            {
                ApigeeNSURLSessionDataTaskInfo* dataTaskInfo =
                    [self.dictRegisteredDataTasks objectForKey:date];
                if( dataTaskInfo && (dataTaskInfo.sessionDataTask == dataTask) )
                {
                    [dataTaskInfo.networkEntry recordStartTime];
                    [self.lockDataTasks unlock];
                    return;
                }
            }
            [self.lockDataTasks unlock];
        }
    }
}

#pragma mark UI Event Tracking

- (void)logUIEvent:(NSString*)uiEvent
{
    [ApigeeLogger infoFrom:NULL tag:@"UI_EVENT" message:uiEvent];
}

- (void)screenVisibilityChanged:(ApigeeUIEventScreenVisibility*)screenEvent
{
    [self logUIEvent:[screenEvent trackingEntry]];
}

- (void)buttonPressed:(ApigeeUIEventButtonPress*)buttonPressEvent
{
    [self logUIEvent:[buttonPressEvent trackingEntry]];
}

- (void)switchToggled:(ApigeeUIEventSwitchToggled*)switchToggledEvent
{
    [self logUIEvent:[switchToggledEvent trackingEntry]];
}

- (void)segmentSelected:(ApigeeUIEventSegmentSelected*)segmentSelectedEvent
{
    [self logUIEvent:[segmentSelectedEvent trackingEntry]];
}

- (BOOL)invokeOnMainThread
{
    return NO;
}

@end


@implementation ApigeeMonitoringClient (NetworkActivityTracking)

- (void) updateLastNetworkTransmissionTime:(NSString*) networkTransmissionTime
{
    if (self.isInitialized) {
        if ([networkTransmissionTime length] > 0) {
            // the time is represented in milliseconds as a string
        
            // get the value as a 64-bit integer
            int64_t msNetworkTransTime = [networkTransmissionTime longLongValue];
        
            // convert that to an NSDate
            NSDate *dateNetworkTransTime = [NSDate dateFromMilliseconds:msNetworkTransTime];
        
            // convert date
            CFTimeInterval secondsTime =
                [ApigeeNetworkEntry dateToSecondsTime:dateNetworkTransTime];
        
            self.lastNetworkTransmissionTime = secondsTime;
        }
    }
}

@end

