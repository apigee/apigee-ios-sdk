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
@property (weak, nonatomic) NSString* urlString;
@property (strong, nonatomic) NSArray* listLoggingMessages;
@property (strong, nonatomic) NSArray* listErrorMessages;
@property (strong, nonatomic) NSArray* listUrls;
@property (assign, nonatomic) NSInteger loggingLevelIndex;
@property (assign, nonatomic) NSInteger errorLevelIndex;
@property (strong, nonatomic) NSURLConnection* connection;
@property (strong, nonatomic) NSURLSession* urlSession;
@property (strong, nonatomic) NSURLSessionTask* urlSessionTask;
@property (strong, nonatomic) NSMutableDictionary* dictDataForUrl;
@property (assign) BOOL isIOS7OrHigher;

@end

@implementation ApigeeViewController

@synthesize monitoringClient;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.errorLevelIndex = 0;
    self.loggingLevelIndex = 0;
    
    self.isIOS7OrHigher = NO;
    
    if( NSClassFromString(@"NSURLSession") )
    {
        NSLog(@"Using NSURLSession for networking");
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
            @"shake to refresh enabled",
            @"device registered for push notifications",
            @"device running older level of iOS, disabling feature X",
            @"data cache refreshed from server",
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
            @"http://www.bbc.co.uk",       // one in Europe
            nil];

    ApigeeAppDelegate* appDelegate =
        (ApigeeAppDelegate*) [[UIApplication sharedApplication] delegate];

//#error configure your org name and app name here
    NSString* orgName = @"pdardeau";
    NSString* appName = @"sandbox";
    NSString* baseURL = @"http://apigee-internal-prod.jupiter.apigee.net";
    
    ApigeeMonitoringOptions* monitoringOptions = [[ApigeeMonitoringOptions alloc] init];
    monitoringOptions.monitoringEnabled = YES;
    
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
        ApigeeLogDebug(kLoggingTag, logMessage);
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

- (IBAction)captureNetworkPerformanceMetricsPressed:(id)sender
{
    if( self.connection == nil )
    {
        NSString* urlAsString = [self randomStringFromList:self.listUrls];
        
        // if we have more than 1 url in the list, make sure that the new one
        // is different from the last one that we used
        if( ([self.urlString length] > 0) &&
           ([self.listUrls count] > 1) &&
           [urlAsString isEqualToString:self.urlString] )
        {
            do {
                urlAsString = [self randomStringFromList:self.listUrls];
            } while( [urlAsString isEqualToString:self.urlString] );
        }
        
        self.urlString = urlAsString;
        NSURL* url = [NSURL URLWithString:self.urlString];
        
        if( self.isIOS7OrHigher )
        {
            //**********************  NSURLSession  ************************
            //if( ! self.urlSession )
            //{
            NSURLSessionConfiguration* config =
                [NSURLSessionConfiguration defaultSessionConfiguration];
            self.urlSession = [NSURLSession sessionWithConfiguration:config
                                                            delegate:self
                                                       delegateQueue:nil];
            //}
            
            self.urlSessionTask = [self.urlSession dataTaskWithURL:url];
            /*
             completionHandler:^(NSData* data,NSURLResponse* response,NSError* error) {
             //NSLog(@"completion handler called for dataTaskWithRequest");
             
             if( response != nil )
             {
             if( [response isKindOfClass:[NSHTTPURLResponse class]] )
             {
             NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*) response;
             NSInteger statusCode = httpResponse.statusCode;
             NSLog( @"HTTP status code = %d", statusCode);
             }
             
             NSURL* url = [response URL];
             NSString* urlAsString = [url absoluteString];
             NSLog( @"url = %@", urlAsString);
             } else {
             NSLog( @"response is nil");
             }
             
             if( error != nil )
             {
             NSString* description = [error localizedDescription];
             NSLog( @"error: %@", description);
             }
             }];
             */
            
            [self.urlSessionTask resume];
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

#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    //NSLog( @"response received (%@)", self.urlString );
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    //NSLog( @"data received (%@)", self.urlString );
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    NSLog( @"connection failed with error: %@ (%@)", [error localizedDescription], self.urlString );
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    //NSLog( @"connection finished loading (%@)", self.urlString );
    self.connection = nil;
    self.urlString = nil;
}

#pragma mark NSURLSessionDelegate methods

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    //NSLog(@"app URLSession:didBecomeInvalidWithError:");
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    //NSLog(@"app URLSession:didReceiveChallenge:completionHandler:");
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    //NSLog(@"app URLSessionDidFinishEventsForBackgroundURLSession:");
}

#pragma mark NSURLSessionDataDelegate methods

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    //NSLog(@"app URLSession:dataTask:didBecomeDownloadTask:");
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    //NSLog(@"app URLSession:dataTask:didReceiveData:");
    NSURLRequest* request = dataTask.currentRequest;
    NSURL* url = request.URL;
    NSString* urlAsString = url.absoluteString;
    
    NSMutableData* dataForUrl = [self.dictDataForUrl valueForKey:urlAsString];
    
    if (!dataForUrl) {
        dataForUrl = [[NSMutableData alloc] init];
        [self.dictDataForUrl setValue:dataForUrl forKey:urlAsString];
    }
    
    [dataForUrl appendData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    //NSLog(@"app URLSession:dataTask:didReceiveResponse:completionHandler:");
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    //NSLog(@"app URLSession:dataTask:willCacheResponse:completionHandler:");
    completionHandler(NULL);  // don't cache
}

#pragma mark NSURLSessionTaskDelegate methods

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    //NSLog(@"app URLSession:task:didCompleteWithError:");
    
    NSURLRequest* request = task.currentRequest;
    NSURL* url = request.URL;
    NSString* urlAsString = url.absoluteString;
    
    NSMutableData* dataForUrl = [self.dictDataForUrl valueForKey:urlAsString];
    NSLog(@"size data received = %d (%@)", [dataForUrl length], urlAsString);
    [self.dictDataForUrl removeObjectForKey:urlAsString];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    //NSLog(@"app URLSession:task:didReceiveChallenge:completionHandler:");
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    //NSLog(@"app URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:");
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
    //NSLog(@"app URLSession:task:needNewBodyStream:");
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    //NSLog(@"app URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:");
    completionHandler(request);
}

@end
