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
    
    BOOL connectionSucceeded = YES;
    
    NSString *url = [request.URL absoluteString];
    
    ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] initWithURL:url
                                                                    started:startTime
                                                                      ended:endTime];
    
    if (responseData) {
        if (response && *response) {
            NSURLResponse *theResponse = *response;
            if ([theResponse isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) theResponse;
                NSInteger statusCode = httpResponse.statusCode;
                entry.httpStatusCode = [NSString stringWithFormat:@"%d", statusCode];
            }
            else
            {
                // not HTTP
                entry.httpStatusCode = nil;
            }
        }
        else
        {
            connectionSucceeded = NO;
        }
        
        entry.responseDataSize = [NSString stringWithFormat:@"%d", [responseData length]];
    }
    else
    {
        connectionSucceeded = NO;
    }
    
    if (!connectionSucceeded) {
        entry.numErrors = @"1";
        if (error && *error) {
            NSError *theError = *error;
            entry.transactionDetails = [theError localizedDescription];
        }
    }
    
    [ApigeeQueue recordNetworkEntry:entry];
    
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
                                                          
                               NSString *url = [request.URL absoluteString];
                                                          
                               ApigeeNetworkEntry *entry =
                                    [[ApigeeNetworkEntry alloc] initWithURL:url
                                                                      started:startTime
                                                                        ended:endTime];
                                                          
                               if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
                                   NSInteger statusCode = httpResponse.statusCode;
                                   entry.httpStatusCode = [NSString stringWithFormat:@"%d", statusCode];
                                   
                                   //TODO: examine HTTP status code for errors (ex: 5xx or 4xx)
                                   // and report an error if there's an HTTP error
                               }
                                                          
                               if (data && !error) {
                                   // succeeded
                                   entry.responseDataSize = [NSString stringWithFormat:@"%d", [data length]];
                               }
                               else if(!data && error) {
                                   // failed
                                   entry.numErrors = @"1";
                                   entry.transactionDetails = [error localizedDescription];
                               }
                               
                               [ApigeeQueue recordNetworkEntry:entry];
                               
                            }];
}

- (id) initWithRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate >)delegate
{
    self.interceptor = [[ApigeeNSURLConnectionDataDelegateInterceptor alloc] initAndInterceptFor:delegate];
    self.interceptor.url = request.URL;
    return [super initWithRequest:request delegate:self.interceptor];
}

- (id) initWithRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate >)delegate startImmediately:(BOOL)startImmediately
{
    self.interceptor = [[ApigeeNSURLConnectionDataDelegateInterceptor alloc] initAndInterceptFor:delegate];
    self.interceptor.url = request.URL;
    return [super initWithRequest:request delegate:self.interceptor startImmediately:startImmediately];
}

- (void) start
{
    _started = [NSDate date];
    
    [super start];
}

@end
