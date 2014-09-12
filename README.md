Apigee iOS SDK Overview
=======================

[![Build Status](https://travis-ci.org/apigee/apigee-ios-sdk.svg)](https://travis-ci.org/apigee/apigee-ios-sdk)

There are 2 main areas of functionality provided: (1) App Services (Usergrid), and (2) App Monitoring.  App Services provides server-side storage functionality.  App Monitoring provides crash reporting, error tracking, application configuration management, and network performance monitoring.  You may use both of these areas or decide to just use one of them.


Installing the SDK
------------------

1. Add `ApigeeiOSSDK.framework` to your project.

2. Add the following iOS frameworks to your project:

	```objective-c
	CoreLocation.framework
	Security.framework
	CoreTelephony.framework
	QuartzCore.framework
	SystemConfiguration.framework
	UIKit.framework
	```

3. Add the following flags to 'Other Linker Flags' in 'Build Settings':

	```objective-c
	-ObjC -all_load
	```
	Confirm that flags are set for both 'DEBUG' and 'RELEASE'.

4. Import the SDK in your code:

	```objective-c
	#import <ApigeeiOSSDK/Apigee.h>
	```

5. Declare the following properties in `AppDelegate.h`:

	```objective-c
	@property (strong, nonatomic) ApigeeClient *apigeeClient; //object for initializing the App Services SDK
	@property (strong, nonatomic) ApigeeMonitoringClient *monitoringClient; //client object for Apigee App Monitoring methods
	@property (strong, nonatomic) ApigeeDataClient *dataClient;	//client object for App Services data methods
	```

6. Instantiate the 'ApigeeClient' class inside the 'didFinishLaunching' method of 'AppDelegate.m':

	```objective-c
	//Instantiate the AppDelegate
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//Sepcify your App Services organization and application names
	NSString *orgName = @"YOUR-ORG";
	NSString *appName = @"YOUR-APP";
	//Instantiate ApigeeClient to initialize the SDK
	appDelegate.apigeeClient = [[ApigeeClient alloc]
	                            initWithOrganizationId:orgName
	                            applicationId:appName];
	//Retrieve instances of ApigeeClient.monitoringClient and ApigeeClient.dataClient
	self.monitoringClient = [appDelegate.apigeeClient monitoringClient]; //used to call App Monitoring methods
	self.dataClient = [appDelegate.apigeeClient dataClient]; //used to call data methods
	```

Technical Details
-----------------
- The majority of the Objective-C classes make use of ARC.
- Targeted for iOS 5.0 and newer.
- Requires Xcode 5.0.2 (or newer) to build from source.


Building From Source
--------------------
To build from source, issue this command from the `/source` directory of your repository:

```bash
	./Scripts/framework.sh
```

Running Unit Tests
--------------------
To run unit tests you can either use the Xcode IDE or Xcode's command line tools:

    - From within the Xcode IDE, under the Product menu select Test.

    - Using the command line issue the following command from the `\source` directory of your repository:

    ```xcodebuild -project ApigeeiOSSDK.xcodeproj -scheme “ApigeeiOSSDK Tests” -configuration Debug -sdk iphonesimulator clean build test```


Compatibility with iOS 7
------------------------
- We have tested with iOS 7 and there are no known incompatibilities.
- We do have support for NSURLSession in our capture of network performance metrics.


Explicitly Setting Xcode Version
--------------------------------
The build script makes use of the default installation of Xcode.  If you need to configure the build to use a
different version of Xcode, please uncomment the code that assigns the path for DEVELOPER_DIR in source/Scripts/dist.sh.


New Functionality for Usergrid
------------------------------
New classes (`ApigeeCollection`, `ApigeeEntity`, `ApigeeDevice`, `ApigeeGroup`) to make working with entities and collections easier. The functionality has been modeled after our JavaScript and PHP SDKs.

Migrating from Usergrid
-----------------------
1. All classes named with '`UG`' prefix are now named with '`Apigee`' prefix (`UGClassName` becomes `ApigeeClassName`)
2. `UGClient` is now named `ApigeeDataClient`
3. Initialization is performed with `ApigeeClient` (new class)
