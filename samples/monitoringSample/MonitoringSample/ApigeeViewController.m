//
//  ApigeeViewController.m
//  MonitoringSample
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <ApigeeiOSSDK/Apigee.h>

#import "ApigeeAppDelegate.h"
#import "ApigeeViewController.h"

static NSString* kLoggingTag = @"Sample App";



@interface ApigeeViewController ()

@property (strong, nonatomic) ApigeeMonitoringClient* monitoringClient;
@property (strong, nonatomic) IBOutlet UISegmentedControl* logLevelControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl* errorLevelControl;
@property (strong, nonatomic) NSArray* listLoggingMessages;
@property (strong, nonatomic) NSArray* listErrorMessages;
@property (strong, nonatomic) NSArray* listUrls;
@property (assign, nonatomic) NSInteger loggingLevelIndex;
@property (assign, nonatomic) NSInteger errorLevelIndex;
@property (strong, nonatomic) NSURLConnection* connection;

#ifdef __IPHONE_7_0
@property (strong, nonatomic) NSURLSession* urlSession;
@property (strong, nonatomic) NSURLSessionTask* urlSessionTask;
#endif

@property (strong, nonatomic) NSMutableDictionary* dictDataForUrl;
@property (assign) BOOL isIOS7OrHigher;
@property (assign) BOOL useNSURLSessionWithBlocks;

@end

@implementation ApigeeViewController

@synthesize monitoringClient;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.errorLevelIndex = 0;
    self.loggingLevelIndex = 0;
    
    BOOL useNSURLSessionIfAvailable = YES;
    
    self.isIOS7OrHigher = NO;  // we'll set to YES programmatically if true
    self.useNSURLSessionWithBlocks = YES;
    
    if( useNSURLSessionIfAvailable && NSClassFromString(@"NSURLSession") )
    {
        if( self.useNSURLSessionWithBlocks )
        {
            NSLog(@"Using NSURLSession (blocks) for networking");
        } else {
            NSLog(@"Using NSURLSession (delegate) for networking");
        }
        
        self.isIOS7OrHigher = YES;
    } else {
        NSLog(@"Using NSURLConnection for networking");
    }
    
    self.dictDataForUrl = [[NSMutableDictionary alloc] init];
    
    [self.logLevelControl setSelectedSegmentIndex:self.loggingLevelIndex];
    [self.errorLevelControl setSelectedSegmentIndex:self.errorLevelIndex];
    
    self.listLoggingMessages =
        [NSArray arrayWithObjects:@"user denied access to location",
            @"battery level low",
            @"device paired with bluetooth keyboard",
            @"error: server does not recognize payload",
            @"shake to refresh enabled",
            @"device registered for push notifications",
            @"error: font name not found",
            @"device running older level of iOS, disabling feature X",
            @"data cache refreshed from server",
            @"error: something weird happened",
            @"security policy updated from server",
            @"local notifications enabled",
            nil];
    
    self.listErrorMessages =
        [NSArray arrayWithObjects:@"unable to connect to database",
            @"unable to save user preference",
            @"encryption of payload failed",
            @"unzipping of server response failed",
            @"authentication failed",
            @"update server not found",
            nil];
    
    self.listUrls =
        [NSArray arrayWithObjects:@"http://www.cnn.com",
            @"http://www.abcnews.com",
            @"http://www.cbsnews.com",
            @"http://www.bbc.co.uk",    // one in Europe
            nil];

    ApigeeAppDelegate* appDelegate =
        (ApigeeAppDelegate*) [[UIApplication sharedApplication] delegate];

#error configure your org name and app name here
    NSString* orgName = @"<YOUR_ORG_NAME>";
    NSString* appName = @"<YOUR_APP_NAME>";
    NSString* baseURL = nil; //@"http://apigee-internal-prod.jupiter.apigee.net";
    
    ApigeeMonitoringOptions* monitoringOptions = [[ApigeeMonitoringOptions alloc] init];
    monitoringOptions.monitoringEnabled = YES;
    monitoringOptions.autoPromoteLoggedErrors = YES;
    monitoringOptions.interceptNSURLSessionCalls = YES;
    //monitoringOptions.showDebuggingInfo = YES;
    
    appDelegate.apigeeClient = [[ApigeeClient alloc]
                                initWithOrganizationId:orgName
                                applicationId:appName
                                baseURL:baseURL
                                options:monitoringOptions];
    self.monitoringClient = [appDelegate.apigeeClient monitoringClient];
}

- (NSString*)randomStringFromList:(NSArray*)list
{
    const int numItems = [list count];
    
    if( numItems > 0 )
    {
        const u_int32_t randomIndex = arc4random_uniform(numItems);
        return [list objectAtIndex:randomIndex];
    }
    
    return NULL;
}

- (IBAction)forceCrashPressed:(id)sender
{
    // purposefully go beyond end of list to generate a crash
    NSString* x = [self.listUrls objectAtIndex:50];
    NSLog( @"%@", x );
}

- (IBAction)generateLoggingEntryPressed:(id)sender
{
    NSString* logMessage = [self randomStringFromList:self.listLoggingMessages];
    
    if( self.loggingLevelIndex == 0 )
    {
        ApigeeLogVerbose(kLoggingTag, logMessage);
    }
    else if( self.loggingLevelIndex == 1 )
    {
        NSLog(logMessage);
    }
    else if( self.loggingLevelIndex == 2 )
    {
        ApigeeLogInfo(kLoggingTag, logMessage);
    }
    else if( self.loggingLevelIndex == 3 )
    {
        ApigeeLogWarn(kLoggingTag, logMessage);
    }
}

- (IBAction)generateErrorPressed:(id)sender
{
    NSString* errorMessage = [self randomStringFromList:self.listErrorMessages];
    
    if( self.errorLevelIndex == 0 )
    {
        ApigeeLogError(kLoggingTag, errorMessage);
    }
    else if( self.errorLevelIndex == 1 )
    {
        ApigeeLogAssert(kLoggingTag, errorMessage);
    }
}

- (void)logError:(NSError*)error
{
    NSString* logMessage = [NSString stringWithFormat:@"error: %@",
                            [error localizedDescription]];
    NSLog(@"%@", logMessage);
}

- (void)logError:(NSError*)error forUrl:(NSString*)urlAsString
{
    NSString* logMessage = [NSString stringWithFormat:@"error: %@ %@",
                            urlAsString,
                            [error localizedDescription]];
    NSLog(@"%@", logMessage);
}

- (IBAction)captureNetworkPerformanceMetricsPressed:(id)sender
{
    if( self.connection == nil )
    {
        NSString* urlAsString = [self randomStringFromList:self.listUrls];
        NSURL* url = [NSURL URLWithString:urlAsString];
        
        if( self.isIOS7OrHigher )
        {
#ifdef __IPHONE_7_0
            //**********************  NSURLSession  ************************
            if( ! self.urlSession )
            {
                NSURLSessionConfiguration* config =
                    [NSURLSessionConfiguration defaultSessionConfiguration];
                
                if( self.useNSURLSessionWithBlocks )
                {
                    // using blocks -- don't set a delegate
                    self.urlSession = [NSURLSession sessionWithConfiguration:config
                                                                    delegate:nil
                                                               delegateQueue:nil];
                } else {
                    // not using blocks -- set ourselves as the delegate
                    self.urlSession = [NSURLSession sessionWithConfiguration:config
                                                                    delegate:self
                                                               delegateQueue:nil];
                }
            }
            
            if( self.useNSURLSessionWithBlocks )
            {
                __weak ApigeeViewController* weakSelf = self;
                
                self.urlSessionTask =
                    [self.urlSession dataTaskWithURL:url
                                   completionHandler:^(NSData* data,NSURLResponse* response,NSError* error)
                {
                    NSString* urlAsString = [[response URL] absoluteString];

                    if( error != nil )
                    {
                        [weakSelf logError:error forUrl:urlAsString];
                    } else {
                        NSLog(@"NSURLSession (blocks): size data received = %d bytes (%@)",
                              [data length],
                              urlAsString);
                    }
                }];
            } else {
                // not using blocks -- use delegate approach
                self.urlSessionTask = [self.urlSession dataTaskWithURL:url];
            }

            // start the request
            [self.urlSessionTask resume];
#endif
        }
        else
        {
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            
            //**********************  NSURLConnection  *********************
            self.connection = [[NSURLConnection alloc] initWithRequest:request
                                                              delegate:self];
        }
    }
}

- (IBAction)logLevelSettingChanged:(id)sender
{
    self.loggingLevelIndex = [self.logLevelControl selectedSegmentIndex];
}

- (IBAction)errorLevelSettingChanged:(id)sender
{
    self.errorLevelIndex = [self.errorLevelControl selectedSegmentIndex];
}

- (NSMutableData*)dataForUrl:(NSString*)urlAsString
{
    NSMutableData* dataForUrl = [self.dictDataForUrl valueForKey:urlAsString];
    
    if (!dataForUrl) {
        dataForUrl = [[NSMutableData alloc] init];
        [self.dictDataForUrl setValue:dataForUrl forKey:urlAsString];
    }

    return dataForUrl;
}

- (void)removeDataObjectForUrl:(NSString*)urlAsString
{
    [self.dictDataForUrl removeObjectForKey:urlAsString];
}

- (NSString*)urlAsStringForRequest:(NSURLRequest*)request
{
    return [[request URL] absoluteString];
}

- (NSString*)urlAsStringForConnection:(NSURLConnection*)connection
{
    return [self urlAsStringForRequest:[connection currentRequest]];
}

#ifdef __IPHONE_7_0
- (NSString*)urlAsStringForTask:(NSURLSessionTask*)task
{
    return [self urlAsStringForRequest:task.currentRequest];
}
#endif

#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    NSString* urlAsString = [self urlAsStringForConnection:connection];
    NSMutableData* dataForUrl = [self dataForUrl:urlAsString];
    [dataForUrl appendData:data];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    NSString* urlAsString = [self urlAsStringForConnection:connection];
    [self logError:error forUrl:urlAsString];
    [self removeDataObjectForUrl:urlAsString];
    self.connection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    NSString* urlAsString = [self urlAsStringForConnection:connection];
    NSMutableData* dataForUrl = [self dataForUrl:urlAsString];
    NSLog(@"NSURLConnection: data received = %d bytes (%@)",
          [dataForUrl length],
          urlAsString);
    self.connection = nil;
}

#ifdef __IPHONE_7_0
#pragma mark NSURLSessionDelegate methods

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    [self logError:error];
}

#pragma mark NSURLSessionDataDelegate methods

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    NSString* urlAsString = [self urlAsStringForTask:dataTask];
    NSMutableData* dataForUrl = [self dataForUrl:urlAsString];
    [dataForUrl appendData:data];
}

#pragma mark NSURLSessionTaskDelegate methods

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSString* urlAsString = [self urlAsStringForTask:task];
    NSMutableData* dataForUrl = [self dataForUrl:urlAsString];
    NSLog(@"NSURLSession (delegate): size data received = %d bytes (%@)",
          [dataForUrl length],
          urlAsString);
    [self removeDataObjectForUrl:urlAsString];
}
#endif

@end
