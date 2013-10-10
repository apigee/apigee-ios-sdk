//
//  ApigeeURLConnection.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeNSURLConnectionDataDelegateInterceptor.h"
#import "ApigeeURLConnection.h"
#import "ApigeeNetworkEntry.h"
#import "ApigeeQueue+NetworkMetrics.h"
#import "ApigeeMonitoringClient.h"

@interface ApigeeURLConnection()

@property (strong) ApigeeNSURLConnectionDataDelegateInterceptor *interceptor;

@end

@implementation ApigeeURLConnection

+ (NSURLConnection *) connectionWithRequest:(NSURLRequest *) request delegate:(id < NSURLConnectionDelegate >) delegate
{
    return [[ApigeeURLConnection alloc] initWithRequest:request delegate:delegate];
}

+ (NSData *) sendSynchronousRequest:(NSURLRequest *) request
                       returningResponse:(NSURLResponse **)response
                                   error:(NSError **)error
{
    NSDate *startTime = [NSDate date];
    
    //TODO: pass in non-null error object even if caller hasn't (so that
    // we can relay the error information to the server)
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:response
                                                             error:error];
    
    NSDate* endTime = [NSDate date];
    
    ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
    [entry populateStartTime:startTime ended:endTime];
    [entry populateWithRequest:request];
    
    if (response && *response) {
        NSURLResponse *theResponse = *response;
        [entry populateWithResponse:theResponse];
    }
    
    [entry populateWithResponseData:responseData];
    
    if (error && *error) {
        NSError *theError = *error;
        [entry populateWithError:theError];
    }
    
    [[ApigeeMonitoringClient sharedInstance] recordNetworkEntry:entry];
    
    return responseData;
}

+ (void)sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
{
    NSDate *startTime = [NSDate date];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                                                          
                               NSDate *endTime = [NSDate date];
                                                          
                               // invoke our caller's completion handler
                               if (handler) {
                                   handler(response,data,error);
                               }
                                                          
                               ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
                               [entry populateStartTime:startTime ended:endTime];
                               [entry populateWithRequest:request];
                               [entry populateWithResponse:response];
                               [entry populateWithResponseData:data];
                               
                                if (error) {
                                    [entry populateWithError:error];
                                }
                               
                               [[ApigeeMonitoringClient sharedInstance] recordNetworkEntry:entry];
                               
                            }];
}

- (id) initWithRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate >)delegate
{
    self.interceptor = [[ApigeeNSURLConnectionDataDelegateInterceptor alloc] initAndInterceptFor:delegate
                                                                                     withRequest:request];
    return [super initWithRequest:request delegate:self.interceptor];
}

- (id) initWithRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate >)delegate startImmediately:(BOOL)startImmediately
{
    self.interceptor = [[ApigeeNSURLConnectionDataDelegateInterceptor alloc] initAndInterceptFor:delegate
                                                                                     withRequest:request];
    return [super initWithRequest:request delegate:self.interceptor startImmediately:startImmediately];
}

- (void) start
{
    _started = [NSDate date];
    
    [super start];
}

@end
