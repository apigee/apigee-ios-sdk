InstaOps iOS SDK Instructions
=============================

The SDK is packaged as a zip file containing both: the public headers (.h) and a static archive (.a), and a framework (.framework) to link your application against.  To setup a project to use the InstaOps SDK, extract the zip file on your machine and follow the instructions below.  You may use either the static archive (libInstaOpsSDK.a) or the framework (InstaOpsSDK.framework), but not both.

0. Extract the zip file. You should see the following structure
<pre>
    ApigeeMobileAnalytics-[major].[minor]
                        /Library
                               /Headers
                               /libInstaOpsSDK.a 
                        /Framework
                        /iOSIntegrationGuide.html
                        /README.txt
</pre>

Option 1: Adding InstaOpsSDK static library to your project
-----------------------------------------------------------
1. Launch your project in Xcode
2. Create a group in your Xcode project to contain the headers and library for InstaOps
3. Right click the new group in your Xcode project and choose _Add Files to [Project Name]_
4. Navigate to the ApigeeMobileAnalytics-[major].[minor] folder on your disk and select the Headers folder (allow groups to be created for folders)
5. In Project Navigator, click on your project file, and then the Build Phases tab. Expand _Link Binary With Libraries_
6. Click the '+' button on the bottom. On the dialog presented, choose _Add Other_
7. Once again, navigate to the instaops-sdk-[major].[minor] folder on your disk and select the libInstaOpsSDK.a file
8. In Xcode, you can optionally drag the library file in Project Navigator to the group created for InstaOps

Option 2: Adding InstaOpsSDK framework to your project
------------------------------------------------------
1. Copy InstaOpsSDK.framework into directory in your project for third party dependencies. 
2. Launch your project in Xcode
3. In Project Navigator, click on your project file, and then the Build Phases tab. Expand _Link Binary With Libraries_
4. Click the '+' button on the bottom. On the dialog presented, choose _Add Other_
5. Navigate to the directory containing the framework extracted in the first step, and choose the InstaOpsSDK.framework
9. In Xcode, you can optionally drag the framework into the Frameworks group created by Xcode


Required Frameworks
-------------------

You must have the following frameworks linked with your project in order to build.  Although the SDK requires the frameworks at compile time, runtime configuration determines if a framework is actually used (i.e., location is only captured if runtime configuration specifies to):

* Foundation.framework
* UIKit.framework
* SystemConfiguration.framework
* CoreGraphics.framework
* CoreLocation.framework
* CoreTelephony.framework

Build Settings
--------------
If the following flags aren't already present, update the _Other Linker Flags_ in the Build Settings:

1. In the search field for the Build Settings pane, type _Other Linker Flags_
2. Double click the field for _Other Linker Flags_
3. Click the plus button and add _-all\_load_
4. Repeat the process and add _-ObjC_

_Other Linker Flags_ should now read: _-ObjC -all\_load_

You can read more about why the flags are needed [here](https://developer.apple.com/library/mac/#qa/qa2006/qa1490.html).

Runtime Configuration
---------------------

**Accessing the Framework APIs**

To access types provided by the framework in your source code, just inculde the framework header file.  If you have linked your project against the framework, add the following line to the top of any file that needs access to framework definitions such as the logging API:

<pre>
  //
  //  MyClass.m
  //  MyProject
  //
  //  Created by me on 9/12/12.
  //  Copyright (c) 2012 My Company. All rights reserved.
  //

  ...

  #import &ltInstaOpsSDK/InstaOps.h&gt;

  ...
</pre>

If you linked the library (.a) and included the headers manually, omit the '&lt;/&gt;' notation for frameworks and just import the master header like any header from your own project:
<pre>

  //
  //  MyClass.m
  //  MyProject
  //
  //  Created by me on 9/12/12.
  //  Copyright (c) 2012 My Company. All rights reserved.
  //

  ...

  #import "InstaOps.h"

  ...
</pre>


**Client Configuration**

To start the framework, initialize the SDK with the the configuration keys created for your application from the Apigee Mobile Analytics portal.  The keys are:

* Environment
* App Id
* Consumer Key
* Secret Key

If you don't already have a class extension defined for your app delegate, add the following:
 
<pre>
  ...
  #import "InstaOpsAppMonitor.h"

  @interface MyAppDelegate()

  @property (strong, nonatomic) InstaOpsAppMonitor *iopsAppMonitor;

  @end

</pre>

In the didFinishLaunchingWithOptions:(NSDictionary *)launchOptions callback, add the following call:

<pre>
  - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

      ...
      iopsAppMonitor = [[InstaOpsAppMonitor alloc] initWithAppId:@"[app_id_from_console]"
                                                     consumerKey:@"[consumer_key_from_console]"
                                                       secretKey:@"[secret_key_from_console]"
                                                     environment:@"[environment_from_console]"];
</pre>

**Crash Reporting**

The default initializer will enable crash reporting and submission by default.  If you want to disable the crash reporting feature, simply use the alternate initializer:

<pre>
  - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

      ...
      iopsAppMonitor = [[InstaOpsAppMonitor alloc] initWithAppId:@"[app_id_from_console]"
                                                     consumerKey:@"[consumer_key_from_console]"
                                                       secretKey:@"[secret_key_from_console]"
                                                     environment:@"[environment_from_console]"
                                                  crashReporting:NO];
</pre>


**Automatic Network Instrumentation and Reporting**

The default initializer will enable automatic interception of network calls for performance tracking.  This feature instruments all
network calls made using NSURLConnection (directly or indirectly).  If you want to disable the automatic network instrumentation feature, simply use the alternate initializer:

<pre>
  - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

      ...
      iopsAppMonitor = [[InstaOpsAppMonitor alloc] initWithAppId:@"[app_id_from_console]"
                                                     consumerKey:@"[consumer_key_from_console]"
                                                       secretKey:@"[secret_key_from_console]"
                                                     environment:@"[environment_from_console]"
                                                  crashReporting:YES
										   interceptNetworkCalls:NO];
</pre>

If you disable automatic network instrumentation, please see the section _Manual Network Instrumentation_ for manual instrumentation of network calls.

_Note: It is recommended that you maintain the reference for the instance of the InstaOpsAppMonitor on your application delegate, and share this reference via the delegate to any parts of your application that need to query the active settings.  Running multiple instance of the app monitor is not supported._

API Guide
---------

**Custom Configuration Parameters**

To access custom configuration parameters (set via the console), obtain a reference to the InstaOpsAppMonitor instance for your application, and then loop through the following collection available via the activeSettings property:

<pre>

  for (InstaOpsCustomConfigParam *param in self.appMonitor.activeSettings.customConfigParams) {
     ... = param.category;
     ... = param.key;
     ... = param.value;
  }

</pre>


**Logging**

If you only care about capturing output from NSLog statements that are currently in your application, make sure the "Log Capture Levels" on the portal is set to Debug.


**Advanced Logging**

The logging API is designed to allow you to capture various levels of information based on the "Log Capture Levels" configuration setting on the portal for your application.  The levels function similarly to log levels from many of the frameworks you have likely used.  Log level filtering is determined by the each level which includes itself, and any preceding level, starting with Assert. The available levels are:

  * InstaOpsLogAssert 
  * InstaOpsLogError 
  * InstaOpsLogWarn 
  * InstaOpsLogInfo
  * InstaOpsLogDebug
  * InstaOpsLogVerbose

For example, choosing a log level of Warn would include logging statements made at Assert, Error, and Warn levels.
 
Import the _InstaOpsLogger.h_ file in your implementation.  You can log in one of two ways.  The easiest is to use the macros:

<pre>
  InstaOpsLogAssert(TAG, ...)
  InstaOpsLogError(TAG, ...)
  InstaOpsLogWarn(TAG, ...)
  InstaOpsLogInfo(TAG, ...)
  InstaOpsLogDebug(TAG, ...)
  InstaOpsLogVerbose(TAG, ...)

  where TAG is the category used to identify a susbsystem or class of messages, and ... is the standard variable argument list as per NSLog.
</pre>

<pre>
  Example:

     InstaOpsLogAssert(@"Tag", @"A message containing %d arguments: %@", 2, @"my second argument");

</pre>

You can also use the Objective-C API supporting the macros, however you will not get the function context for free.  Use this API if you don't need the calling context in your log messages, or if you are logging from within a block (the function names generated by the runtime are a bit nasty):

<pre>
  + (InstaOpsLogger *) logger;

  ...

  - (void) assert:(NSString *) tag format:(NSString *) format, ...)
  - (void) error:(NSString *) tag format:(NSString *) format, ...)
  - (void) warn:(NSString *) tag format:(NSString *) format, ...)
  - (void) info:(NSString *) tag format:(NSString *) format, ...)
  - (void) debug:(NSString *) tag format:(NSString *) format, ...)
  - (void) verbose:(NSString *) tag format:(NSString *) format, ...)

@end

</pre>

<pre>
  Example:

     [[[InstaOpsLogger] logger] info:@"My Tag" format:@"My message constructed from %d arguments: %@", 2, @"the rest of the message"];

</pre>

**Manual Network Instrumentation**

Although the SDK provides functionality (by default) to automatically capture network performance metrics for all calls made through NSURLConnection, you may decide that you want to selectively capture network performance metrics.  To manually capture network performance metrics, use the InstaOps categories provided for NSString, NSData, and NSURLConnection, as well as a subclass of NSURLConnection (InstaOpsURLConnection).  These categories are documented below.

In each case, the overhead for recording the network latency is minimal.  Timestamps are recorded around the calls, and pushed to a background thread that will push the data to the portal.  While capturing metrics is minimal, it cannot be done without overhead.

***InstaOpsUIWebView***

UIWebView has been extended in order to measure the latency on the network calls made loaded via this control.  No functionality or behavior to the original control was overridden.  Simply, the delegate that is set is used to time the start and finish of the request.  In order to use the control, either create an instance programmatically and add it as a subview to your view controllers main view, or, drag a UIWebView into your view, go to the identity inspector, and change the class from UIWebView to InstaOpsUIWebView. No other calls are needed.  Just use the control as you normally would, and latency metrics will be pushed to your portal for calls loaded through the control.

***NSString***

A category to NSString is provided mirror functionality for initializing a string from a URL, while capturing latency metrics for the underlying network calls made to do so.  The following methods are available:

<pre>
+ (id) stringWithTimedContentsOfURL:(NSURL *) url encoding:(NSStringEncoding) enc error:(NSError **) error;
+ (id) stringWithTimedContentsOfURL:(NSURL *) url usedEncoding:(NSStringEncoding *) enc error:(NSError **) error;
- (id) initWithTimedContentsOfURL:(NSURL *) url encoding:(NSStringEncoding) enc error:(NSError **) error;
- (id) initWithTimedContentsOfURL:(NSURL *) url usedEncoding:(NSStringEncoding *) enc error:(NSError **) error;
- (BOOL) timedWriteToURL:(NSURL *) url atomically:(BOOL) useAuxiliaryFile encoding:(NSStringEncoding) enc error:(NSError **) error;
</pre>

***NSData***

A category to NSData is provided mirror functionality for initializing a raw data from a URL, while capturing latency metrics for the underlying network calls made to do so.  The following methods are available:

<pre>
+ (id) timedDataWithContentsOfURL:(NSURL *) url options:(NSDataReadingOptions) readOptionsMask error:(NSError **) errorPtr;
+ (id) timedDataWithContentsOfURL:(NSURL *) url;
- (id) initWithTimedContentsOfURL:(NSURL *) url options:(NSDataReadingOptions) readOptionsMask error:(NSError **) errorPtr;
- (id) initWithTimedContentsOfURL:(NSURL *) url;
- (BOOL) timedWriteToURL:(NSURL *) url atomically:(BOOL) atomically;
- (BOOL) timedWriteToURL:(NSURL *) url options:(NSDataWritingOptions) writeOptionsMask error:(NSError **) errorPtr;
</pre>

***NSURLConnection***

A category to NSURLConnection is provided to mirror functionality for making network requests while capturing latency metrics for the underlying network calls.  The following methods are available:

<pre>
+ (NSURLConnection*) timedConnectionWithRequest:(NSURLRequest *) request delegate:(id < NSURLConnectionDelegate >) delegate;
+ (NSData *) timedSendSynchronousRequest:(NSURLRequest *) request returningResponse:(NSURLResponse **) response error:(NSError **) error;
+ (void) timedSendAsynchronousRequest:(NSURLRequest *) request queue:(NSOperationQueue *) queue completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*)) handler;
- (id) initTimedConnectionWithRequest:(NSURLRequest *) request delegate:(id < NSURLConnectionDelegate >) delegate;
- (id) initTimedConnectionWithRequest:(NSURLRequest *) request delegate:(id < NSURLConnectionDelegate >) delegate startImmediately:(BOOL) startImmediately;
</pre>

A subclass of the NSURLConnection is also provided.  As with InstaOpsUIWebView, InstaOpsURLConnection doesn't override any behavior of the parent class.  Instead, it makes use of the NSURLConnectionDataDelegate protocol to capture the metrics.  The subclass calls the delegate set just as in the case of NSURLConnection, but records information from the necessary callbacks in the protocol before forwarding the message to your original delegate.  The delegate property on the subclass is optional as with NSURLConnection.  Latency metrics are captured with or without the delegate being set.

Symbolicating a crash report
----------------------------

Symbolication of a crash report produced by InstaOps involves converting the recorded location in the memory space where execution failed into the corresponding line of source code that produced the instructions that caused the application to crash.

In order to symbolicate a crash report, you need to have the original binary and the debugging symbols (dSYM package) for the version of the application that produced the crash report. 

1. Copy the .app and .dSYM packages for the version of your application into a folder.
2. Copy the crash report ([UUID].crash file downloaded above) into the folder containing the .app and dSYM packages.
3. Copy in the symbolicatecrash.pl script distributed with the framework.  You may have to set the "DEVELOPER_DIR" environment variable if the script execution fails.  As of Xcode 4.5, this should be set as follows:
  <pre>>$ export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"</pre>

4. Make sure the script is executable.  Open a terminal prompt in the directory containing the script, crash report, and binaries:
  <pre>>$ chmod 755 symbolicationcrash.pl
5. Execute the script and redirect the output to a file:
  <pre>>$ symbolicationcrash [UUID].crash [App Name].dSYM > symbolicated_report.txt

The symbolicated_report.txt should now replace addresses in the call stack with source files and line numbers.

Note: Only addresses corresponding to source code from your application will be replaced.  Core Apple framework calls are not symbolicated.

Congratulations
---------------
You are all set now. May Apigee Mobile Analytics help you take your mobile app success to the next level !!  If you have any issues please contact support at [SUPPORT EMAIL]
