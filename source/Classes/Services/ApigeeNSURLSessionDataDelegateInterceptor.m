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

#import "ApigeeNSURLSessionDataDelegateInterceptor.h"
#import "ApigeeMonitoringClient.h"
#import "ApigeeNSURLSessionDataTaskInfo.h"
#import "ApigeeNetworkEntry.h"
#import "ApigeeQueue+NetworkMetrics.h"

@interface ApigeeNSURLSessionDataDelegateInterceptor ()

@property (strong) id target;
@property (strong) NSURL* url;
@property (strong) NSURLRequest* request;

@end


@implementation ApigeeNSURLSessionDataDelegateInterceptor

@synthesize target;

- (id) initAndInterceptFor:(id)theTarget
{
    self = [super init];
    if( self )
    {
        self.target = theTarget;
    }
    
    return self;
}

#pragma mark NSURLSessionDelegate methods

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    //NSLog(@"interceptor URLSession:didBecomeInvalidWithError:");
    
    if (self.target &&
        [self.target respondsToSelector:@selector(URLSession:didBecomeInvalidWithError:)])
    {
        [self.target URLSession:session didBecomeInvalidWithError:error];
    }
}

- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    //NSLog(@"interceptor URLSession:didReceiveChallenge:completionHandler:");
    
    if (self.target &&
        [self.target respondsToSelector:@selector(URLSession:didReceiveChallenge:completionHandler:)])
    {
        [self.target URLSession:session
            didReceiveChallenge:challenge
              completionHandler:completionHandler];
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,NULL);
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    //NSLog(@"interceptor URLSessionDidFinishEventsForBackgroundURLSession:");
    
    if (self.target &&
        [self.target respondsToSelector:@selector(URLSessionDidFinishEventsForBackgroundURLSession:)])
    {
        [self.target URLSessionDidFinishEventsForBackgroundURLSession:session];
    }
}

#pragma mark NSURLSessionDataDelegate methods

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    //NSLog(@"interceptor URLSession:dataTask:didReceiveResponse:completionHandler:");
    
    if( response != nil )
    {
        ApigeeMonitoringClient* monitoringClient =
            [ApigeeMonitoringClient sharedInstance];
        ApigeeNSURLSessionDataTaskInfo* sessionDataTaskInfo =
            [monitoringClient dataTaskInfoForTask:dataTask];
        
        if( sessionDataTaskInfo )
        {
            [sessionDataTaskInfo.networkEntry populateWithResponse:response];
        }
    }

    if (self.target &&
        [self.target respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)])
    {
        [self.target URLSession:session
                       dataTask:dataTask
             didReceiveResponse:response
              completionHandler:completionHandler];
    } else {
        completionHandler(NSURLSessionResponseAllow); // allow response to proceed
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    //NSLog(@"interceptor URLSession:dataTask:didBecomeDownloadTask:");

    // remove the dataTask from monitoring as it's transitioning to a download task
    ApigeeMonitoringClient* monitoringClient =
        [ApigeeMonitoringClient sharedInstance];
    [monitoringClient removeDataTaskInfoForTask:dataTask];
    
    if (self.target &&
        [self.target respondsToSelector:@selector(URLSession:dataTask:didBecomeDownloadTask:)])
    {
        [self.target URLSession:session
                       dataTask:dataTask
          didBecomeDownloadTask:downloadTask];
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    //NSLog(@"interceptor URLSession:dataTask:didReceiveData:");
    
    if( data && ([data length] > 0) ) {
        ApigeeMonitoringClient* monitoringClient =
            [ApigeeMonitoringClient sharedInstance];
        ApigeeNSURLSessionDataTaskInfo* sessionDataTaskInfo =
            [monitoringClient dataTaskInfoForTask:dataTask];
    
        if( sessionDataTaskInfo )
        {
            sessionDataTaskInfo.dataSize += [data length];
        }
    }

    if (self.target &&
        [self.target respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)])
    {
        [self.target URLSession:session
                       dataTask:dataTask
                 didReceiveData:data];
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    //NSLog(@"interceptor URLSession:dataTask:willCacheResponse:completionHandler:");
    
    if (self.target &&
        [self.target respondsToSelector:@selector(URLSession:dataTask:willCacheResponse:completionHandler:)])
    {
        [self.target URLSession:session
                       dataTask:dataTask
              willCacheResponse:proposedResponse
              completionHandler:completionHandler];
    } else {
        completionHandler(proposedResponse);  // let default behavior apply
    }
}

#pragma mark NSURLSessionTaskDelegate methods

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    //NSLog(@"interceptor URLSession:task:didCompleteWithError:");
    
    ApigeeMonitoringClient* monitoringClient =
        [ApigeeMonitoringClient sharedInstance];
    
    ApigeeNSURLSessionDataTaskInfo* sessionDataTaskInfo =
        [monitoringClient dataTaskInfoForTask:task];
    
    if( sessionDataTaskInfo )
    {
        [sessionDataTaskInfo.networkEntry recordEndTime];
        [sessionDataTaskInfo.networkEntry populateWithResponseDataSize:sessionDataTaskInfo.dataSize];
        [sessionDataTaskInfo.networkEntry populateWithError:error];
        
        [monitoringClient recordNetworkEntry:sessionDataTaskInfo.networkEntry];
        
        [monitoringClient removeDataTaskInfoForTask:task];
    }

    if (self.target &&
        [self.target respondsToSelector:@selector(URLSession:task:didCompleteWithError:)])
    {
        [self.target URLSession:session
                           task:task
           didCompleteWithError:error];
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    //NSLog(@"interceptor URLSession:task:didReceiveChallenge:completionHandler:");
    
    if (self.target &&
        [self.target respondsToSelector:@selector(URLSession:task:didReceiveChallenge:completionHandler:)])
    {
        [self.target URLSession:session
                           task:task
            didReceiveChallenge:challenge
              completionHandler:completionHandler];
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,NULL);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    //NSLog(@"interceptor URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:");
    
    if (self.target &&
        [self.target respondsToSelector:@selector(URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)])
    {
        [self.target URLSession:session
                           task:task
                didSendBodyData:bytesSent
                 totalBytesSent:totalBytesSent
       totalBytesExpectedToSend:totalBytesExpectedToSend];
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
    //NSLog(@"interceptor URLSession:task:needNewBodyStream:");
    
    if (self.target &&
        [self.target respondsToSelector:@selector(URLSession:task:needNewBodyStream:)])
    {
        [self.target URLSession:session
                           task:task
              needNewBodyStream:completionHandler];
    } else {
        NSInputStream* inputStream = nil;
        
        if (task.originalRequest.HTTPBodyStream &&
            [task.originalRequest.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)])
        {
            inputStream = [task.originalRequest.HTTPBodyStream copy];
        }
        
        completionHandler(inputStream);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    //NSLog(@"interceptor URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:");
    
    if (self.target &&
        [self.target respondsToSelector:@selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:)])
    {
        [self.target URLSession:session
                           task:task
     willPerformHTTPRedirection:response
                     newRequest:request
              completionHandler:completionHandler];
        
    } else {
        completionHandler(request);  // allow the redirect
    }
}

#pragma mark NSURLSessionDownloadDelegate methods

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    if (self.target &&
        [self.target respondsToSelector:@selector(URLSession:downloadTask:didFinishDownloadingToURL:)])
    {
        [self.target URLSession:session
                   downloadTask:downloadTask
      didFinishDownloadingToURL:location];
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    if (self.target &&
        [self.target respondsToSelector:@selector(URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:)])
    {
        [self.target URLSession:session
                   downloadTask:downloadTask
              didResumeAtOffset:fileOffset
             expectedTotalBytes:expectedTotalBytes];
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (self.target &&
        [self.target respondsToSelector:@selector(URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)])
    {
        [self.target URLSession:session
                   downloadTask:downloadTask
                   didWriteData:bytesWritten
              totalBytesWritten:totalBytesWritten
      totalBytesExpectedToWrite:totalBytesExpectedToWrite];
        
    }
}

@end
