NOTICE
======
This SDK has not been released yet -- it should not be used for active development.

Apigee iOS SDK Overview
=======================

There are 2 main areas of functionality provided: (1) App Services (Usergrid), and (2) App Monitoring.  App Services provides server-side storage functionality.  App Monitoring provides crash reporting, error tracking, application configuration management, and network performance monitoring.  You may use both of these areas or decide to just use one of them.


NOTE -- app monitoring is temporarily disabled until the back-end systems are configured.

Linking in Xcode
----------------
Add the following flags to "Other Linker Flags" in "Build Settings":
<pre>
	-ObjC -all_load
</pre>

Add the following frameworks:

* CoreLocation.framework
* CoreTelephony.framework
* SystemConfiguration.framework
* Security.framework

Technical Details
-----------------
- The majority of the Objective-C classes make use of ARC. This framework is targeted for iOS 5.0 and newer.


Building From Source
--------------------
To build from source, issue this command from the /source directory of your repository:

<pre>
	./Scripts/framework.sh
</pre>


Compatibility with iOS 7
------------------------
We have done some testing with iOS 7 and have not encountered any problems. There is some new functionality related to networking that will be added.


Explicitly Setting Xcode Version
--------------------------------
The build script makes use of the default installation of Xcode.  If you need to configure the build to use a
different version of Xcode, please uncomment the code that assigns the path for DEVELOPER_DIR in source/Scripts/dist.sh.


New Functionality for Usergrid
------------------------------
New classes (ApigeeCollection, ApigeeEntity, ApigeeDevice, ApigeeGroup) to make working with entities and collections easier. The functionality has been modeled after our JavaScript and PHP SDKs.

Migrating from Usergrid
-----------------------
1. All classes named with 'UG' prefix are now named with 'Apigee' prefix (UGClassName becomes ApigeeClassName)
2. UGClient is now named ApigeeDataClient
3. Initialization is performed with ApigeeClient (new class)
