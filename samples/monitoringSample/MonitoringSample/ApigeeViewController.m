//
//  ApigeeViewController.m
//  MonitoringSample
//
//  Created by Paul Dardeau on 9/4/13.
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <ApigeeiOSSDK/Apigee.h>
#import <ApigeeiOSSDK/ApigeeClient.h>
#import <ApigeeiOSSDK/ApigeeMonitoringClient.h>

#import "ApigeeViewController.h"

static NSString* kLoggingTag = @"Sample App";


@interface ApigeeViewController ()

@property (strong, nonatomic) ApigeeClient* apigeeClient;
@property (strong, nonatomic) IBOutlet UISegmentedControl* logLevelControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl* errorLevelControl;
@property (weak, nonatomic) NSString* urlString;
@property (strong, nonatomic) NSArray* listLoggingMessages;
@property (strong, nonatomic) NSArray* listErrorMessages;
@property (strong, nonatomic) NSArray* listUrls;
@property (assign, nonatomic) NSInteger loggingLevelIndex;
@property (assign, nonatomic) NSInteger errorLevelIndex;
@property (strong, nonatomic) NSURLConnection* connection;

@end

@implementation ApigeeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.errorLevelIndex = 0;
    self.loggingLevelIndex = 0;
    
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
    
    NSString* orgName = @"pdardeau";
    NSString* appName = @"sandbox";
    NSString* baseURL = @"http://apigee-internal-prod.jupiter.apigee.net";
    
    self.apigeeClient = [[ApigeeClient alloc]
                            initWithOrganizationId:orgName
                            applicationId:appName
                            baseURL:baseURL];
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
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
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
                                                 
@end
