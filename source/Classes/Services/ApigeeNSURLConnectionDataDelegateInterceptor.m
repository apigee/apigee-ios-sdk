/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "NSDate+Apigee.h"
#import "ApigeeQueue+NetworkMetrics.h"
#import "ApigeeURLConnection.h"
#import "ApigeeNetworkEntry.h"
#import "ApigeeNSURLConnectionDataDelegateInterceptor.h"
#import "NSURLConnection+Apigee.h"
#import "ApigeeMonitoringClient.h"

// swap these definitions to see logging of activity
#define INTERCEPTOR_LOG(logMessage)
//#define INTERCEPTOR_LOG(logMessage) ApigeeLogVerbose(@"Interceptor",logMessage);


@interface ApigeeNSURLConnectionDataDelegateInterceptor() <NSURLConnectionDelegate,
    NSURLConnectionDataDelegate,
    NSURLConnectionDownloadDelegate>

@property (strong) id target;
@property (strong) ApigeeNetworkEntry *networkEntry;
@property (assign, nonatomic) NSUInteger dataSize;

@end

@implementation ApigeeNSURLConnectionDataDelegateInterceptor

@synthesize dataSize;

- (id) initAndInterceptFor:(id) target withRequest:(NSURLRequest*)request
{
    INTERCEPTOR_LOG(@"initAndInterceptFor:withRequest:");
    
    self = [super init];
    
    if (self) {
        self.target = target;
        self.dataSize = 0;
        _connectionAlive = YES;
        
        ApigeeNetworkEntry *theNetworkEntry = [[ApigeeNetworkEntry alloc] init];
        [theNetworkEntry recordStartTime];
        [theNetworkEntry populateWithRequest:request];
        self.networkEntry = theNetworkEntry;
    }
    
    return self;
}

- (BOOL)isConnectionAlive
{
    return _connectionAlive;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    NSString* selectorAsString = NSStringFromSelector(aSelector);
    BOOL weRespond = NO;
    BOOL targetResponds = NO;
    BOOL answerResponds = NO;
 
    if( [selectorAsString isEqualToString:@"connection:didFailWithError:"] ||
        [selectorAsString isEqualToString:@"connectionDidFinishLoading:"] ||
        [selectorAsString isEqualToString:@"connection:didReceiveResponse:"])
    {
        answerResponds = YES;
    }
    else if( [selectorAsString hasPrefix:@"connection"] )
    {
        if( self.target )
        {
            // since we're the delegate from the NSURLConnection's perspective,
            // both us (the interceptor) and the real delegate must be able
            // to respond to the message for us to say that we respond to the
            // message
            weRespond = [[self class] instancesRespondToSelector:aSelector];
            targetResponds = [self.target respondsToSelector:aSelector];
            answerResponds = weRespond && targetResponds;
            
            if( !weRespond && targetResponds )
            {
                NSLog( @"+++++ HOLE: real delegate responds but we don't: '%@'", selectorAsString);
            }
        }
    }
    else
    {
        answerResponds = [[self class] instancesRespondToSelector:aSelector];
    }

    return answerResponds;
}

#pragma mark - NSURLConnectionDelegate

- (void) connection:(NSURLConnection *) connection didFailWithError:(NSError *) error
{
    INTERCEPTOR_LOG(@"connection:didFailWithError:");

    _connectionAlive = NO;
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    
    if (![monitoringClient isPaused]) {
        [self.networkEntry recordEndTime];
       
    
        if (self.target && [self.target respondsToSelector:@selector(connection:didFailWithError:)]) {
            [self.target connection:connection didFailWithError:error];
        }
    
        [self.networkEntry populateWithError:error];
        [monitoringClient recordNetworkEntry:self.networkEntry];
    } else {
        NSLog(@"Not capturing network metrics -- paused");
    }
    
    self.networkEntry = nil;
}

- (BOOL) connectionShouldUseCredentialStorage:(NSURLConnection *) connection
{
    INTERCEPTOR_LOG(@"connectionShouldUseCredentialStorage");

    if (self.target && [self.target respondsToSelector:@selector(connectionShouldUseCredentialStorage:)]) {
        return [self.target connectionShouldUseCredentialStorage:connection];
    }
    
    return NO;
}

- (void)connection:(NSURLConnection *) connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *) challenge
{
    INTERCEPTOR_LOG(@"connection:willSendRequestForAuthenticationChallenge:");

    if (self.target && [self.target respondsToSelector:@selector(connection:willSendRequestForAuthenticationChallenge:)]) {
        [self.target connection:connection willSendRequestForAuthenticationChallenge:challenge];
    }
}

// Deprecated authentication delegates - should these be supported?
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    INTERCEPTOR_LOG(@"connection:canAuthenticateAgainstProtectionSpace:");

    if (self.target && [self.target respondsToSelector:@selector(connection:canAuthenticateAgainstProtectionSpace:)]) {
        return [self.target connection:connection canAuthenticateAgainstProtectionSpace:protectionSpace];
    }
    
    return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    INTERCEPTOR_LOG(@"connection:didReceiveAuthenticationChallenge:");

    if (self.target && [self.target respondsToSelector:@selector(connection:didReceiveAuthenticationChallenge:)]) {
        [self.target connection:connection didReceiveAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    INTERCEPTOR_LOG(@"connection:didCancelAuthenticationChallenge:");

    if (self.target && [self.target respondsToSelector:@selector(connection:didCancelAuthenticationChallenge:)]) {
        [self.target connection:connection didCancelAuthenticationChallenge:challenge];
    }
}


#pragma mark - NSURLConnectionDataDelegate

- (NSURLRequest *) connection:(NSURLConnection *) connection willSendRequest:(NSURLRequest *) request redirectResponse:(NSURLResponse *) response
{
    INTERCEPTOR_LOG(@"connection:willSendRequest:redirectResponse:");

    if (self.target && [self.target respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)]) {
        return [self.target connection:connection willSendRequest:request redirectResponse:response];
    } else {
        return request;
    }
}

- (void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *) response
{
    INTERCEPTOR_LOG(@"connection:didReceiveResponse:");

    [self.networkEntry populateWithResponse:response];

    if (self.target && [self.target respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [self.target connection:connection didReceiveResponse:response];
    }
}

- (void) connection:(NSURLConnection *) connection didReceiveData:(NSData *) data
{
    INTERCEPTOR_LOG(@"connection:didReceiveData:");
    
    if ([data length] > 0) {
        self.dataSize += [data length];
    }

    if (self.target && [self.target respondsToSelector:@selector(connection:didReceiveData:)]) {
        [self.target connection:connection didReceiveData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data lengthReceived:(long long)lengthReceived
{
    INTERCEPTOR_LOG(@"connection:didReceiveData:lengthReceived:");
    
    if (self.target && [self.target respondsToSelector:@selector(connection:didReceiveData:lengthReceived:)]) {
        [self.target connection:connection didReceiveData:data lengthReceived:lengthReceived];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveDataArray:(NSArray *)dataArray
{
    INTERCEPTOR_LOG(@"connection:didReceiveDataArray:");

    if (self.target && [self.target respondsToSelector:@selector(connection:didReceiveDataArray:)]) {
        [self.target connection:connection didReceiveDataArray:dataArray];
    }
}

- (NSInputStream *) connection:(NSURLConnection *) connection needNewBodyStream:(NSURLRequest *) request
{
    INTERCEPTOR_LOG(@"connection:needNewBodyStream:");

    if (self.target && [self.target respondsToSelector:@selector(connection:needNewBodyStream:)]) {
        return [self.target connection:connection needNewBodyStream:request];
    }
    
    return nil;
}

- (void) connection:(NSURLConnection *) connection didSendBodyData:(NSInteger)bytesWritten
                                                totalBytesWritten:(NSInteger)totalBytesWritten
                                        totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    INTERCEPTOR_LOG(@"connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:");

    if (self.target && [self.target respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.target connection:connection
                didSendBodyData:bytesWritten
              totalBytesWritten:totalBytesWritten
      totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

- (NSCachedURLResponse *) connection:(NSURLConnection *) connection willCacheResponse:(NSCachedURLResponse *) cachedResponse
{
    INTERCEPTOR_LOG(@"connection:willCacheResponse:");

    if (self.target && [self.target respondsToSelector:@selector(connection:willCacheResponse:)]) {
        return [self.target connection:connection willCacheResponse:cachedResponse];
    }
    
    return cachedResponse;
}

- (void) connectionDidFinishLoading:(NSURLConnection *) connection
{
    INTERCEPTOR_LOG(@"connectionDidFinishLoading:");

    _connectionAlive = NO;

    [self.networkEntry recordEndTime];
    
    if (self.target && [self.target respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        [self.target connectionDidFinishLoading:connection];
    }
    
    [self.networkEntry populateWithResponseDataSize:self.dataSize];
    [[ApigeeMonitoringClient sharedInstance] recordNetworkEntry:self.networkEntry];
    self.networkEntry = nil;
}

- (void) connection:(NSURLConnection *)connection
       didWriteData:(long long)bytesWritten
  totalBytesWritten:(long long)totalBytesWritten
 expectedTotalBytes:(long long)expectedTotalBytes
{
    INTERCEPTOR_LOG(@"connection:didWriteData:totalBytesWritten:expectedTotalBytes:");

    if (self.target && [self.target respondsToSelector:@selector(connection:didWriteData:totalBytesWritten:expectedTotalBytes:)]) {
        [self.target connection:connection
                     didWriteData:bytesWritten
                totalBytesWritten:totalBytesWritten
               expectedTotalBytes:expectedTotalBytes];
    }
}

- (void) connectionDidResumeDownloading:(NSURLConnection *)connection
                      totalBytesWritten:(long long)totalBytesWritten
                     expectedTotalBytes:(long long)expectedTotalBytes
{
    INTERCEPTOR_LOG(@"connectionDidResumeDownloading:totalBytesWritten:expectedTotalBytes:");

    if (self.target && [self.target respondsToSelector:@selector(connectionDidResumeDownloading:totalBytesWritten:expectedTotalBytes:)]) {
        [self.target connectionDidResumeDownloading:connection
                                    totalBytesWritten:totalBytesWritten
                                   expectedTotalBytes:expectedTotalBytes];
    }
}

- (void) connectionDidFinishDownloading:(NSURLConnection *)connection
                         destinationURL:(NSURL *)destinationURL
{
    INTERCEPTOR_LOG(@"connectionDidFinishDownloading:destinationURL:");

    if (self.target && [self.target respondsToSelector:@selector(connectionDidFinishDownloading:destinationURL:)]) {
        [self.target connectionDidFinishDownloading:connection
                                       destinationURL:destinationURL];
    }
}

- (void)recordStartTime
{
    [self.networkEntry recordStartTime];
}

@end
