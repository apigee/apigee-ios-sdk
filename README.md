NOTICE
======
This SDK has not been released yet -- it should not be used for active development.

Apigee iOS SDK Overview
=======================

There are 2 main areas of functionality provided: (1) AppServices (UserGrid), and (2) Mobile Analytics.  App Services provides server-side storage functionality.  Mobile Analytics provides crash reporting, error tracking, application configuration management, and network performance monitoring.  You may use both of these areas or decide to just use one of them.


NOTE -- mobile analytics is temporarily disabled until the back-end systems are configured.

Linking in Xcode
----------------
Add the following flags to "Other Linker Flags" in "Build Settings":
<pre>
	-ObjC -all_load
</pre>

Add the following frameworks:

* CoreGraphics.framework
* CoreLocation.framework
* CoreTelephony.framework
* SystemConfiguration.framework
* Security.framework

Technical Details
-----------------
- The majority of the Objective-C classes make use of ARC (iOS 4.3 and newer)


Building From Source
--------------------
To build from source, issue this command from the top-level directory of your repository:

<pre>
	./source/Scripts/framework.sh
</pre>


Compatibility with iOS 7
------------------------
We have done some testing with iOS 7 beta and have not encountered any problems. There is some new functionality related to networking that will be added.


Building With Xcode 5 DP
------------------------
Uncomment the code that assigns the path for DEVELOPER_DIR in Scripts/dist.sh.  You may need to adjust the path for your system.


New Functionality for UserGrid
------------------------------
New classes (ApigeeCollection, ApigeeEntity, ApigeeDevice, ApigeeGroup) to make working with entities and collections easier. The functionality has been modeled after our JavaScript and PHP SDKs.

Migrating from UserGrid
-----------------------
1. All classes named with 'UG' prefix are now named with 'Apigee' prefix (UGClassName becomes ApigeeClassName)
2. UGClient is now named ApigeeDataClient
3. Initialization is performed with ApigeeClient (new class)
