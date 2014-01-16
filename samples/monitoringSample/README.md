##Overview
This iOS sample application demonstrates basic integration of monitoring functionality from Apigee's iOS SDK.

##Running the App
In order to compile and run this application, you must first add ApigeeiOSSDK.framework to this application.

Also, please configure the org name and app name values as appropriate in ApigeeViewController.m.

##Using Crash Reporting
Please note that to test crash reporting with this app, you must do the following:

1. Run the app on an iOS device. Crash reporting will not work in the Xcode simulator.
2. Once the app is installed, close and restart it once before trying the crash feature. This will ensure the crash is properly logged to App Services.