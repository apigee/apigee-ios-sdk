//
//  ApigeeHTTPClient.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//
#import "ApigeeHTTPClient.h"
#import "ApigeeHTTPResult.h"

@interface ApigeeHTTPClient ()
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSURLConnection *connection;
@end

@implementation ApigeeHTTPClient

static int activityCount = 0;
static NSRecursiveLock *networkActivityLock = nil;

+ (void) retainNetworkActivityIndicator {
#if TARGET_OS_IPHONE
    [networkActivityLock lock];
    activityCount++;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [networkActivityLock unlock];
#endif
}

+ (void) releaseNetworkActivityIndicator {
#if TARGET_OS_IPHONE
    [networkActivityLock lock];
    activityCount--;
    if (activityCount == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    [networkActivityLock unlock];
#endif
}

- (id) initWithRequest:(NSMutableURLRequest *)request
{
    if (self = [super init]) {
        self.request = request;

#if TARGET_OS_IPHONE
        static dispatch_once_t lock_token;
        dispatch_once(&lock_token, ^{
            networkActivityLock = [[NSRecursiveLock alloc] init];
        });
#endif
    }
    return self;
}

- (ApigeeHTTPResult *) connect {
    NSHTTPURLResponse *response;
    NSError *error;
    ApigeeHTTPResult *result = [[ApigeeHTTPResult alloc] init];
    result.data = [NSURLConnection sendSynchronousRequest:self.request returningResponse:&response error:&error];
    result.response = response;
    result.error = error;
    if (self.completionHandler) {
        self.completionHandler(result);
    }
    return result;
}

- (void) connectWithCompletionHandler:(ApigeeHTTPCompletionHandler)completionHandler
                      progressHandler:(ApigeeHTTPProgressHandler)progressHandler
{
   	[self.request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    self.data = nil;
    self.response = nil;
	self.completionHandler = completionHandler;
    self.progressHandler = progressHandler;
	self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    [ApigeeHTTPClient retainNetworkActivityIndicator];
}

- (void) connectWithCompletionHandler:(ApigeeHTTPCompletionHandler) completionHandler
{
    [self connectWithCompletionHandler:completionHandler progressHandler:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	self.response = response;
    if (self.progressHandler) {
        self.progressHandler(0.0);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)newData
{
    if (!self.data) {
        self.data = [NSMutableData dataWithData:newData];
    } else {
        [self.data appendData:newData];
    }
    if (self.progressHandler) {
        long long expectedLength = [self.response expectedContentLength];
        if (expectedLength > 0) {
            CGFloat progress = ((CGFloat) [self.data length]) / expectedLength;
            self.progressHandler(progress);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.completionHandler) {
        ApigeeHTTPResult *result = [[ApigeeHTTPResult alloc] init];
        result.response = self.response;
        result.data = self.data;
        result.error = error;
        self.completionHandler(result);
    }
	self.connection = nil;
    self.data = nil;
    [ApigeeHTTPClient releaseNetworkActivityIndicator];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.progressHandler) {
        self.progressHandler(1.0);
    }
    if (self.completionHandler) {
        ApigeeHTTPResult *result = [[ApigeeHTTPResult alloc] init];
        result.response = self.response;
        result.data = self.data;
        result.error = nil;
        //[self.data writeToFile:@"/tmp/data" atomically:NO];
        self.completionHandler(result);
    }
    self.connection = nil;
    self.data = nil;
    [ApigeeHTTPClient releaseNetworkActivityIndicator];
}

- (void) cancel {
    if (self.connection) {
        [self.connection cancel];
    }
    self.connection = nil;
}

- (BOOL) isRunning {
    return (self.connection != nil);
}

- (CGFloat) progress {
    long long expectedLength = [self.response expectedContentLength];
    if (expectedLength > 0) {
        return ((CGFloat) [self.data length]) / expectedLength;
    } else {
        return 0.0;
    }
}

@end

