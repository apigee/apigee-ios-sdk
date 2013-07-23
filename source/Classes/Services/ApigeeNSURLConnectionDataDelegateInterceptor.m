//
//  ApigeeNSURLConnectionDataDelegateInterceptor.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "NSDate+Apigee.h"
#import "ApigeeQueue+NetworkMetrics.h"
#import "ApigeeURLConnection.h"
#import "ApigeeNetworkEntry.h"
#import "ApigeeNSURLConnectionDataDelegateInterceptor.h"
#import "NSURLConnection+Apigee.h"

@interface ApigeeNSURLConnectionDataDelegateInterceptor() <NSURLConnectionDelegate,
    NSURLConnectionDataDelegate,
    NSURLConnectionDownloadDelegate>

@property (strong) id target;
@property (strong) NSDate *start;
@property (strong) ApigeeNetworkEntry *networkEntry;

@end

@implementation ApigeeNSURLConnectionDataDelegateInterceptor

@synthesize createTime;

- (id) initAndInterceptFor:(id) target withRequest:(NSURLRequest*)request
{
    self = [super init];
    
    if (self) {
        self.target = target;
        self.createTime = [NSDate date];
        _connectionAlive = YES;
        
        ApigeeNetworkEntry *theNetworkEntry = [[ApigeeNetworkEntry alloc] init];
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
        [selectorAsString isEqualToString:@"connectionDidFinishLoading:"] )
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
    //ApigeeLogVerbose(@"Interceptor", @"connection:didFailWithError:");

    _connectionAlive = NO;
    
    NSDate *ended = [NSDate date];
    
    if (self.target && [self.target respondsToSelector:@selector(connection:didFailWithError:)]) {
        [self.target connection:connection didFailWithError:error];
    }
    
    NSDate *started = [connection startTime];
    
    if( ! started )
    {
        started = self.createTime;
    }
    
    [self.networkEntry populateStartTime:started ended:ended];
    [self.networkEntry populateWithError:error];
    [ApigeeQueue recordNetworkEntry:self.networkEntry];
    self.networkEntry = nil;
}

- (BOOL) connectionShouldUseCredentialStorage:(NSURLConnection *) connection
{
    //ApigeeLogVerbose(@"Interceptor", @"connectionShouldUseCredentialStorage");

    if (self.target && [self.target respondsToSelector:@selector(connectionShouldUseCredentialStorage:)]) {
        return [self.target connectionShouldUseCredentialStorage:connection];
    }
    
    return NO;
}

- (void)connection:(NSURLConnection *) connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *) challenge
{
    //ApigeeLogVerbose(@"Interceptor", @"connection:willSendRequestForAuthenticationChallenge:");

    if (self.target && [self.target respondsToSelector:@selector(connection:willSendRequestForAuthenticationChallenge:)]) {
        [self.target connection:connection willSendRequestForAuthenticationChallenge:challenge];
    }
}

// Deprecated authentication delegates - should these be supported?
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    //ApigeeLogVerbose(@"Interceptor", @"connection:canAuthenticateAgainstProtectionSpace:");

    if (self.target && [self.target respondsToSelector:@selector(connection:canAuthenticateAgainstProtectionSpace:)]) {
        return [self.target connection:connection canAuthenticateAgainstProtectionSpace:protectionSpace];
    }
    
    return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    //ApigeeLogVerbose(@"Interceptor", @"connection:didReceiveAuthenticationChallenge:");

    if (self.target && [self.target respondsToSelector:@selector(connection:didReceiveAuthenticationChallenge:)]) {
        [self.target connection:connection didReceiveAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    //ApigeeLogVerbose(@"Interceptor", @"connection:didCancelAuthenticationChallenge:");

    if (self.target && [self.target respondsToSelector:@selector(connection:didCancelAuthenticationChallenge:)]) {
        [self.target connection:connection didCancelAuthenticationChallenge:challenge];
    }
}


#pragma mark - NSURLConnectionDataDelegate

- (NSURLRequest *) connection:(NSURLConnection *) connection willSendRequest:(NSURLRequest *) request redirectResponse:(NSURLResponse *) response
{
    //ApigeeLogVerbose(@"Interceptor", @"connection:willSendRequest:redirectResponse:");

    if (self.target && [self.target respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)]) {
        return [self.target connection:connection willSendRequest:request redirectResponse:response];
    } else {
        return request;
    }
}

- (void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *) response
{
    //ApigeeLogVerbose(@"Interceptor", @"connection:didReceiveResponse:");

    [self.networkEntry populateWithResponse:response];

    if (self.target && [self.target respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [self.target connection:connection didReceiveResponse:response];
    }
}

- (void) connection:(NSURLConnection *) connection didReceiveData:(NSData *) data
{
    //ApigeeLogVerbose(@"Interceptor", @"connection:didReceiveData:");

    if (self.target && [self.target respondsToSelector:@selector(connection:didReceiveData:)]) {
        [self.target connection:connection didReceiveData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data lengthReceived:(long long)lengthReceived
{
    //ApigeeLogVerbose(@"Interceptor", @"connection:didReceiveData:lengthReceived:");

    if (self.target && [self.target respondsToSelector:@selector(connection:didReceiveData:lengthReceived:)]) {
        [self.target connection:connection didReceiveData:data lengthReceived:lengthReceived];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveDataArray:(NSArray *)dataArray
{
    //ApigeeLogVerbose(@"Interceptor", @"connection:didReceiveDataArray:");

    if (self.target && [self.target respondsToSelector:@selector(connection:didReceiveDataArray:)]) {
        [self.target connection:connection didReceiveDataArray:dataArray];
    }
}

- (NSInputStream *) connection:(NSURLConnection *) connection needNewBodyStream:(NSURLRequest *) request
{
    //ApigeeLogVerbose(@"Interceptor", @"connection:needNewBodyStream:");

    if (self.target && [self.target respondsToSelector:@selector(connection:needNewBodyStream:)]) {
        return [self.target connection:connection needNewBodyStream:request];
    }
    
    //#warning does this need to be initialized with the URL on the request?
    //return [[NSInputStream alloc] initWithURL:request.URL];
    
    return nil;
}

- (void) connection:(NSURLConnection *) connection didSendBodyData:(NSInteger)bytesWritten
                                                totalBytesWritten:(NSInteger)totalBytesWritten
                                        totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    //ApigeeLogVerbose(@"Interceptor", @"connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:");

    if (self.target && [self.target respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.target connection:connection
                didSendBodyData:bytesWritten
              totalBytesWritten:totalBytesWritten
      totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

- (NSCachedURLResponse *) connection:(NSURLConnection *) connection willCacheResponse:(NSCachedURLResponse *) cachedResponse
{
    //ApigeeLogVerbose(@"Interceptor", @"connection:willCacheResponse:");

    if (self.target && [self.target respondsToSelector:@selector(connection:willCacheResponse:)]) {
        return [self.target connection:connection willCacheResponse:cachedResponse];
    }
    
    return cachedResponse;
}

- (void) connectionDidFinishLoading:(NSURLConnection *) connection
{
    //ApigeeLogVerbose(@"Interceptor", @"connectionDidFinishLoading:");

    _connectionAlive = NO;

    NSDate *ended = [NSDate date];
    
    if (self.target && [self.target respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        //ApigeeLogVerbose(@"Interceptor", @"calling connectionDidFinishLoading on real delegate");
        [self.target connectionDidFinishLoading:connection];
    }
    // the following code might be helpful for debugging
    /*
    else
    {
        ApigeeLogVerbose(@"Interceptor", @"NOT calling connectionDidFinishLoading on real delegate");

        if( self.target )
        {
            ApigeeLogVerbose(@"Interceptor", @"have real delegate -- must not respond to method");
        }
        else
        {
            ApigeeLogVerbose(@"Interceptor", @"real delegate is nil");
        }
        
    }
     */
    
    NSDate *started = [connection startTime];

    if( ! started )
    {
        started = self.createTime;
    }

    [self.networkEntry populateStartTime:started ended:ended];
    [ApigeeQueue recordNetworkEntry:self.networkEntry];
    self.networkEntry = nil;
}

- (void) connection:(NSURLConnection *)connection
       didWriteData:(long long)bytesWritten
  totalBytesWritten:(long long)totalBytesWritten
 expectedTotalBytes:(long long)expectedTotalBytes
{
    //ApigeeLogVerbose(@"Interceptor", @"connection:didWriteData:totalBytesWritten:expectedTotalBytes:");

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
    //ApigeeLogVerbose(@"Interceptor", @"connectionDidResumeDownloading:totalBytesWritten:expectedTotalBytes:");

    if (self.target && [self.target respondsToSelector:@selector(connectionDidResumeDownloading:totalBytesWritten:expectedTotalBytes:)]) {
        [self.target connectionDidResumeDownloading:connection
                                    totalBytesWritten:totalBytesWritten
                                   expectedTotalBytes:expectedTotalBytes];
    }
}

- (void) connectionDidFinishDownloading:(NSURLConnection *)connection
                         destinationURL:(NSURL *)destinationURL
{
    //ApigeeLogVerbose(@"Interceptor", @"connectionDidFinishDownloading:destinationURL:");

    if (self.target && [self.target respondsToSelector:@selector(connectionDidFinishDownloading:destinationURL:)]) {
        [self.target connectionDidFinishDownloading:connection
                                       destinationURL:destinationURL];
    }
}


@end
